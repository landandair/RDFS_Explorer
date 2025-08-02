extends HBoxContainer

# Read
signal get_info(node_id: String)
signal get_file(node_id: String)
# Write
signal upload_data(file_name: String, file_data: PackedByteArray, parent: String)
signal make_directory(name, parent: String)
signal remove_node(id: String)

var tree_item_dict = {}
var download = preload("res://icon.svg")
var File_Entry = preload("res://Scenes/file_entry.tscn")
@onready var tree = $Tree

# Display node info in screen
func _on_node_info_received(node_dict: Dictionary) -> void:
	tree.clear()
	var base_item = tree.create_item()
	tree.set_column_expand_ratio(0, 4)
	#base_item.set_text(0, "Files")
	#base_item.set_text(1, "Size")
	recursive_tree_maker(base_item, node_dict, node_dict.keys())
			
func recursive_tree_maker(parent: TreeItem, node_dict: Dictionary, nodes):
	for hash in nodes:
		if hash in node_dict:
			var node = node_dict.get(hash)
			if node.get('parent') not in nodes or (node.get('parent') in tree_item_dict.values() and hash not in tree_item_dict.values()):				
				var item = parent.create_child()
				tree_item_dict[item] = hash
				item.set_text(0, node.get('name'))
				match int(node.get('type')):
					0: # Source
						item.set_text(1, "Root")
					1: # File
						item.set_text(1, get_human_readable_size(node.get('size', -1)))
						item.add_button(1, download)
					2: # Directory
						item.set_text(1, "%d item(s)" % len(node.get('children', [])))
					3: # Chunk
						item.set_text(1, get_human_readable_size(node.get('size', -1)))
				recursive_tree_maker(item, node_dict, node.get('children'))


func get_human_readable_size(bytes: int) -> String:
	if bytes < 1024:
		return str(bytes) + " B"
	elif bytes < 1024 * 1024:
		return "%.2f KB" % (bytes / 1024.0)
	elif bytes < 1024 * 1024 * 1024:
		return "%.2f MB" % (bytes / (1024.0 * 1024.0))
	else:
		return "%.2f GB" % (bytes / (1024.0 * 1024.0 * 1024.0))


func _on_tree_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	var hash = tree_item_dict[item]
	if hash:
		if id == 0:
			get_file.emit(hash)


func _on_tree_item_activated() -> void:
	var hash = tree_item_dict[tree.get_selected()]
	if hash:
		get_info.emit(hash)
