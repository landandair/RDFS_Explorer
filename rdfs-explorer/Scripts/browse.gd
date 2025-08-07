extends HSplitContainer
# This is a signal buss primarily for sending and receiving signals and turning them into function 
# calls or local scene signals

# For distribution
signal source_upate(source: String)
signal node_info_received(node_dict: Dictionary)
# For passing to network connection
signal get_root()
signal get_info(node_id: String)
signal reload()
signal get_source()
signal get_file(node_id: String)
signal upload_data(file_name: String, file_data: PackedByteArray, parent: String)
signal make_directory(name, parent: String)
signal remove_node(id: String)

func _get_root():
	get_root.emit()

func _get_info(node_id: String):
	get_info.emit(node_id)

func _reload():
	reload.emit()

func _get_source():
	get_source.emit()

func _get_file(node_id: String):
	get_file.emit(node_id)

func _upload_data(file_name: String, file_data: PackedByteArray, parent: String):
	upload_data.emit(file_name, file_data, parent)

func _make_directory(node_name, parent: String):
	make_directory.emit(node_name, parent)

func _remove_node(id: String):
	remove_node.emit(id)

func _on_node_info_received(node_dict: Dictionary) -> void:
	node_info_received.emit(node_dict)

func _on_source_upate(source: String) -> void:
	source_upate.emit(source)
