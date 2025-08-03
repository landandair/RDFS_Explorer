extends ScrollContainer

signal get_info(node_id: String)
signal get_source()

@onready var source_disp = $Source_Display
var source_entry = preload("res://Scenes/source_entry.tscn")
var found_hashes = []
var favorites_list = []  # TODO: MUST be loaded from save and saved to file on close
var our_source = ''

func _ready() -> void:
	get_source.emit()
	get_info.emit('')

# We receive our source hash so we know what to add files under
func _on_source_upate(source: String) -> void:
	our_source = source


func _node_info_received(node_dict: Dictionary) -> void:
	for node_hash in node_dict:
		var node = node_dict[node_hash]
		if node.get('type') == 0 and node_hash not in found_hashes: # Check if root
			found_hashes.append(node_hash)
			var node_name = node.get('name')
			var node_entry = source_entry.instantiate()
			node_entry.node_name = node_name
			node_entry.node_hash = node_hash
			node_entry.connect('favorite_toggled', _favorite_toggled)
			node_entry.connect('open_pressed', _open_pressed)
			source_disp.add_child(node_entry)
	sort_nodes()

func _favorite_toggled(node_hash: String, is_favorite: bool):
	if is_favorite:
		favorites_list.append(node_hash)
	elif node_hash in favorites_list:
		favorites_list.erase(node_hash)
	sort_nodes()

func _open_pressed(node_hash: String):
	get_info.emit(node_hash)

func sort_nodes():
	var sorted_nodes := source_disp.get_children()

	sorted_nodes.sort_custom(
		source_entry_compare
	)
	for i in sorted_nodes.size():
		source_disp.move_child(sorted_nodes[i], i)
		

func source_entry_compare(a: Node, b: Node) -> bool:
	# Sort nodes in list in a sensible manner
	if a.node_hash == our_source:
		return true
	elif b.node_hash == our_source:
		return false
	elif a.is_favorite:
		return true
	elif b.is_favorite:
		return false
	else:
		return a.node_name.naturalnocasecmp_to(b.node_name) < 0
