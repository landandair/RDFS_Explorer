extends TabContainer
# Manage all api calls by signals and return those values through update signals

var http = HTTPClient.new()
var host = '127.0.0.1'
var port = 1234

@onready var file_dialog = $FileDialog

signal source_upate(source_dict: Dictionary)
signal nodes_list(node_dict: Dictionary)
signal node_info_received(node_dict: Dictionary)

var current_file_data = PackedByteArray()

func _ready() -> void:
	var err = http.connect_to_host(host, port)
	if err == OK:
		print('Connected to host')
		while http.get_status() == HTTPClient.STATUS_CONNECTING or http.get_status() == HTTPClient.STATUS_RESOLVING:
			http.poll()
			print("Connecting...")
			await get_tree().process_frame
			
		assert(http.get_status() == HTTPClient.STATUS_CONNECTED)
	get_file('3e164dcd7800653828e2844cedcca00c7495c6afd78e00a3704be852')

func _process(delta: float) -> void:
	http.poll()
	if http.get_status() == HTTPClient.STATUS_CONNECTION_ERROR or http.get_status() == HTTPClient.STATUS_DISCONNECTED:
		http.connect_to_host(host, port)

# Request root node json data
func get_root() -> void:
	var res = self.make_req('/')
	if res == OK:
		await self.get_headers()
		var bin = await self.get_response_body()
		print(bin.get_string_from_ascii())

# Get info about a node from the server in json format
func get_info(node_id: String) -> void:
	var res = self.make_req('/getNode/{node_id}'.format({"node_id": node_id}))
	if res == OK:
		await self.get_headers()
		var bin = await self.get_response_body()
		var out = Dictionary(JSON.parse_string(bin.get_string_from_utf8()))
		print("Make a signal that broadcasts ", out)

# Get source information about local server to know which nodes are ours
func get_source() -> void:
	var res = self.make_req('/getSrc')
	if res == OK:
		await self.get_headers()
		var bin = await self.get_response_body()
		var out = bin.get_string_from_utf8()
		print("Make a signal that broadcasts ", out)

# Get file from server make a prompt to save it
func get_file(node_id: String) -> void:
	var res = self.make_req('/getFile/{node_id}'.format({"node_id": node_id}))
	if res == OK:
		var headers = await self.get_headers()
		var bin = await self.get_response_body()
		if 'Content-Disposition' in headers:
			var regex = RegEx.new()
			regex.compile("attachment; filename=(.+)")
			var result = regex.search(headers['Content-Disposition'])
			var file_name = result.get_string(1)  # None means no response
			file_dialog.current_file = file_name
			current_file_data = bin
			file_dialog.show()

# Make an http form and send it to the http peer for upload for uploading a file
func upload_data(file_name: String, file_data: PackedByteArray, parent: String) -> void:
	# Load the buffer into a form data
	var bound_head = self.make_multipart_header()
	var boundary = bound_head[0]
	var headers = bound_head[1]
	# Create our body
	var body = PackedByteArray()
	append_line(body, "--{{boundary}}".format({"boundary": boundary}, "{{_}}"))
	append_line(body, 'Content-Disposition: form-data; name="parent"')
	append_line(body, '')
	append_line(body, parent) # The API key you have
	append_line(body, "--{{boundary}}".format({"boundary": boundary}, "{{_}}"))
	append_line(body, 'Content-Disposition: form-data; name="file"; filename="{file_name}"'.format({"file_name": file_name}))
	append_line(body, 'Content-Type: file')
	append_line(body, 'Content-Transfer-Encoding: binary')
	append_line(body, '')
	append_bytes(body, file_data)
	append_line(body, "--{{boundary}}--".format({"boundary": boundary}, "{{_}}"))
	body = body.get_string_from_utf8()
	var res = self.make_post('/uploadData', headers, body)
	if res == OK:
		await self.get_headers()
		var bin = await self.get_response_body()
		print(bin.get_string_from_ascii())

# Make http post to make a directory
func make_directory(name, parent: String) -> void:
		# Load the buffer into a form data
	var bound_head = self.make_multipart_header()
	var boundary = bound_head[0]
	var headers = bound_head[1]
	# Create our body
	var body = PackedByteArray()
	append_line(body, "--{{boundary}}".format({"boundary": boundary}, "{{_}}"))
	append_line(body, 'Content-Disposition: form-data; name="parent"')
	append_line(body, '')
	append_line(body, parent) # The API key you have
	append_line(body, "--{{boundary}}".format({"boundary": boundary}, "{{_}}"))
	append_line(body, 'Content-Disposition: form-data; name="name"')
	append_line(body, '')
	append_line(body, name)
	append_line(body, "--{{boundary}}--".format({"boundary": boundary}, "{{_}}"))
	body = body.get_string_from_utf8()
	var res = self.make_post('/mkdir', headers, body)
	if res == OK:
		await self.get_headers()
		var bin = await self.get_response_body()
		print(bin.get_string_from_ascii())

# Make http request to remove a node
func remove_node(id: String) -> void:
	print('/deleteNode/%s' % id)
	var res = self.make_req('/deleteNode/%s' % id)
	if res == OK:
		await self.get_headers()
		var bin = await self.get_response_body()
		print(bin.get_string_from_ascii())

## HELPER FUNCTIONS

func make_req(url, header=['Content-type: json'], body='') -> Error:
	if http.get_status() == HTTPClient.STATUS_CONNECTED:
		return http.request(HTTPClient.METHOD_GET, url, header, body)
	return ERR_CANT_CONNECT

func make_post(url, header=['Content-type: json'], body='') -> Error:
	if http.get_status() == HTTPClient.STATUS_CONNECTED:
		return http.request(HTTPClient.METHOD_POST, url, header, body)
	return ERR_CANT_CONNECT

func get_response_body() -> PackedByteArray:
	# ensure you ran get_headers before this
	var rb = PackedByteArray() # Array that will hold the data.
	# If there is a response...
	while http.get_status() == HTTPClient.STATUS_BODY:
		# While there is body left to be read
		http.poll()
		# Get a chunk.
		var chunk = http.read_response_body_chunk()
		if chunk.size() == 0:
			await get_tree().process_frame
		else:
			rb = rb + chunk # Append to read buffer.
		# Done!
		var text = rb.get_string_from_ascii()
	return rb

func get_headers() -> Dictionary:
	var headers = {}
	while http.get_status() == HTTPClient.STATUS_REQUESTING:
		# Keep polling for as long as the request is being processed.
		await get_tree().process_frame
	if http.has_response():
		# If there is a response...
		headers = http.get_response_headers_as_dictionary() # Get response headers.
	return headers

func make_multipart_header():
	# Create some random bytes to generate our boundary value
	var crypto = Crypto.new()
	var random_bytes = crypto.generate_random_bytes(16)
	var boundary = '--GODOT%s' % random_bytes.hex_encode()

	# Setup the header Content-Type with our bundary
	var headers = [
		'Content-Type: multipart/form-data;boundary=%s' % boundary
	]
	return [boundary, headers]

func append_line(buffer:PackedByteArray, line:String) -> void:
	buffer.append_array(line.to_utf8_buffer())
	buffer.append_array('\r\n'.to_utf8_buffer())


func append_bytes(buffer:PackedByteArray, bytes:PackedByteArray) -> void:
	buffer.append_array(bytes)
	buffer.append_array('\r\n'.to_utf8_buffer())

# Save current file data to file
func _on_file_dialog_file_selected(path: String) -> void:
	if len(current_file_data):
		var f = FileAccess.open(path, FileAccess.WRITE)
		f.store_buffer(current_file_data)
		f.close()
		current_file_data = PackedByteArray()
