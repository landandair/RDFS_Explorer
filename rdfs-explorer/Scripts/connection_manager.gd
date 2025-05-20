extends TabContainer
# Manage all api calls by signals and return those values through update signals

var http = HTTPClient.new()
var host = '127.0.0.1'
var port = 1234

signal source_upate(source_dict: Dictionary)
signal nodes_list(node_dict: Dictionary)
signal node_info_received(node_dict: Dictionary)

func _ready() -> void:
	var err = http.connect_to_host(host, port)
	if err == OK:
		print('Connected to host')
		while http.get_status() == HTTPClient.STATUS_CONNECTING or http.get_status() == HTTPClient.STATUS_RESOLVING:
			http.poll()
			print("Connecting...")
			await get_tree().process_frame
			
		assert(http.get_status() == HTTPClient.STATUS_CONNECTED)
		self.remove_node('1234')

func _process(delta: float) -> void:
	http.poll()
	if http.get_status() == HTTPClient.STATUS_CONNECTION_ERROR or http.get_status() == HTTPClient.STATUS_DISCONNECTED:
		http.connect_to_host(host, port)

func make_req(url, header=['Content-type: json'], body='') -> Error:
	if http.get_status() == HTTPClient.STATUS_CONNECTED:
		return http.request(HTTPClient.METHOD_GET, url, header, body)
	return ERR_CANT_CONNECT


func get_response_body() -> PackedByteArray:
	while http.get_status() == HTTPClient.STATUS_REQUESTING:
		# Keep polling for as long as the request is being processed.
		await get_tree().process_frame
	var rb = PackedByteArray() # Array that will hold the data.
	if http.has_response():
		# If there is a response...
		var headers = http.get_response_headers_as_dictionary() # Get response headers.
		#print("code: ", http.get_response_code()) # Show response code.
		#print("**headers:\\n", headers) # Show headers.
#
		## Getting the HTTP Body
		#if http.is_response_chunked():
			## Does it use chunks?
			#print("Response is Chunked!")
		#else:
			## Or just plain Content-Length
			#var bl = http.get_response_body_length()
			#print("Response Length: ", bl)

		# This method works for both anyway


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

# Request root node json data
func get_root() -> void:
	var res = self.make_req('/')
	if res == OK:
		var bin = await self.get_response_body()
		print(bin.get_string_from_ascii())

# Make an http form and send it to the http peer for upload
func upload_data(name: String, file_data: PackedByteArray, parent: String) -> void:
	pass

# Make http post to make a directory
func make_directory(name, parent: String) -> void:
	pass

# Make http request to remove a node
func remove_node(id: String) -> void:
	print('/deleteNode/%s' % id)
	var res = self.make_req('/deleteNode/%s' % id)
	if res == OK:
		var bin = await self.get_response_body()
		print(bin.get_string_from_ascii())

func send_image_binary() -> void:
	# Create some random bytes to generate our boundary value
	var crypto = Crypto.new()
	var random_bytes = crypto.generate_random_bytes(16)
	var boundary = '--GODOT%s' % random_bytes.hex_encode()

	# Setup the header Content-Type with our bundary
	var headers = [
		'Content-Type: multipart/form-data;boundary=%s' % boundary
	]

	# Load the image and get the png buffer
	var image = load("res://letter.png").get_image() as Image
	var buffer = image.save_png_to_buffer()

	# Create our body
	var body = PackedByteArray()
	append_line(body, "--{{boundary}}".format({"boundary": boundary}, "{{_}}"))
	append_line(body, 'Content-Disposition: form-data; name="api_key"')
	append_line(body, '')
	append_line(body, "MY_API_KEY") # The API key you have
	append_line(body, "--{{boundary}}".format({"boundary": boundary}, "{{_}}"))
	append_line(body, 'Content-Disposition: form-data; name="image"; filename="my_image.png"')
	append_line(body, 'Content-Type: image/png')
	append_line(body, 'Content-Transfer-Encoding: binary')
	append_line(body, '')
	append_bytes(body, buffer)
	append_line(body, "--{{boundary}}--".format({"boundary": boundary}, "{{_}}"))

func append_line(buffer:PackedByteArray, line:String) -> void:
	buffer.append_array(line.to_utf8_buffer())
	buffer.append_array('\r\n'.to_utf8_buffer())


func append_bytes(buffer:PackedByteArray, bytes:PackedByteArray) -> void:
	buffer.append_array(bytes)
	buffer.append_array('\r\n'.to_utf8_buffer())
