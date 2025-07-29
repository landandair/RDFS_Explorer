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

func _ready() -> void:
	# Test code
	var item = tree.create_item()
	var item2 = tree.create_item(item)
	var item3 = tree.create_item(item)
	item.set_text(0, "HI")
	item2.set_text(0, "HI2")
	item2.add_button(0, download)
	item.add_button(0, download)
	item3.set_text(0, "HI3")
	item3.add_button(0, download)
	print(item.get_index(), item2.get_index())

# Display node info in screen
func _on_node_info_received(node_dict: Dictionary) -> void:
	tree.clear()
	var base_item = tree.create_item()
	base_item.set_text(0, "Files")
	print(node_dict)
	recursive_tree_maker(base_item, node_dict, node_dict.keys())
			
func recursive_tree_maker(parent: TreeItem, node_dict: Dictionary, nodes):
	for hash in nodes:
		print(hash)
		if hash in node_dict:
			var node = node_dict.get(hash)
			if node.get('parent') not in node_dict or node.get('parent') in tree_item_dict	.values():
				print('Start Here', hash)
				
				var item = tree.create_item(parent)
				tree_item_dict[item] = hash
				item.set_text(0, node.get('name'))
				if node.get('type') == 1:
					item.add_button(0, download)
				
				recursive_tree_maker(item, node_dict, node.get('children'))


func _on_tree_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	print(item.get_text(0))
	print(id)
