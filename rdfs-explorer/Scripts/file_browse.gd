extends HBoxContainer

signal get_info(node_id: String)
signal get_file(node_id: String)
signal upload_data(file_name: String, file_data: PackedByteArray, parent: String)
signal make_directory(name, parent: String)
signal remove_node(id: String)

func _on_node_info_received(node_dict: Dictionary) -> void:
	pass # Replace with function body.
