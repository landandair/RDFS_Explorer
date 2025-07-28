extends HBoxContainer

# Read
signal get_info(node_id: String)
signal get_file(node_id: String)
# Write
signal upload_data(file_name: String, file_data: PackedByteArray, parent: String)
signal make_directory(name, parent: String)
signal remove_node(id: String)

var File_Entry = preload("res://Scenes/file_entry.tscn")
@onready var tree = $Tree

func _ready() -> void:
	# Test code
	var instance = File_Entry.instantiate()
	tree.add_child(instance)

# Display node info in screen
func _on_node_info_received(node_dict: Dictionary) -> void:
	pass # Replace with function body.
