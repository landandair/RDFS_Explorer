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

func _process(delta: float) -> void:
	if http.get_status() == HTTPClient.STATUS_CONNECTION_ERROR or http.get_status() == HTTPClient.STATUS_DISCONNECTED:
		http.connect_to_host(host, port)
		print(http.get_status())
	
	if http.get_status() == HTTPClient.STATUS_CONNECTED:
		print("Making request")
		http.request(HTTPClient.METHOD_GET, '/getSrc', ['Content-type: json'])
	
	while http.get_status() == HTTPClient.STATUS_REQUESTING:
		# Keep polling for as long as the request is being processed.
		http.poll()
		await get_tree().process_frame
		
	if http.has_response():
		# If there is a response...

		var headers = http.get_response_headers_as_dictionary() # Get response headers.
		print("code: ", http.get_response_code()) # Show response code.
		print("**headers:\\n", headers) # Show headers.

		# Getting the HTTP Body

		if http.is_response_chunked():
			# Does it use chunks?
			print("Response is Chunked!")
		else:
			# Or just plain Content-Length
			var bl = http.get_response_body_length()
			print("Response Length: ", bl)

		# This method works for both anyway

		var rb = PackedByteArray() # Array that will hold the data.

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

		print("bytes got: ", rb.size())
		var text = rb.get_string_from_ascii()
		print("Text: ", text)
		http.close()

# Make an http form and send it to the http peer for upload
func upload_data(name: String, file_data: PackedByteArray, parent: String):
	pass

# Make http post to make a directory
func make_directory(name, parent: String):
	pass

# Make http request to remove a directory
func remove_node(id: String):
	pass
