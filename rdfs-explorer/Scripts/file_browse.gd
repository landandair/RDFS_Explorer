extends HBoxContainer

# Read
signal get_info(node_id: String)
signal get_file(node_id: String)
# Write
signal upload_data(file_name: String, file_data: PackedByteArray, parent: String)
signal make_directory(name, parent: String)
signal remove_node(id: String)
signal show_add_file(state: bool)

var current_node_dict = {}
var tree_item_dict = {}
var hovered_item = null
var file_list = Array()

var download = preload("res://themes/icons/floppy-icon-size_32_grey.png")
var retrieve = preload("res://themes/icons/file-restore-icon-size_32_grey.png")
var file_icon = preload("res://themes/icons/file-icon-size_32_grey.png")
var folder_icon = preload("res://themes/icons/folder-icon-size_32_grey.png")
var source_icon = preload('res://themes/icons/source-repository-icon-size_32_grey.png')

@onready var tree = $Tree
@onready var menu = $Context_menu
@onready var new_folder = $new_folder
@onready var confirm_delete = $confirm_delete
@onready var file_dialog = $FileDialog
@onready var timer = $Timer

func _ready() -> void:
	get_viewport().files_dropped.connect(on_files_dropped)
# Display node info in screen
func _on_node_info_received(node_dict: Dictionary) -> void:
	tree.clear()
	var base_item = tree.create_item()
	tree.set_column_expand_ratio(0, 4)
	#base_item.set_text(0, "Files")
	#base_item.set_text(1, "Size")
	current_node_dict = node_dict
	recursive_tree_maker(base_item, current_node_dict.keys())
			
func recursive_tree_maker(parent: TreeItem, nodes):
	for node_hash in nodes:
		if node_hash in current_node_dict:
			var node = current_node_dict.get(node_hash)
			if node.get('parent') not in nodes or (node.get('parent') in tree_item_dict.values() and node_hash not in tree_item_dict.values()):				
				var item = parent.create_child()
				tree_item_dict[item] = node_hash
				var is_stored = node.get('is_stored')
				item.set_text(0, node.get('name'))
				match int(node.get('type')):
					0: # Source
						item.set_text(1, "Root")
						item.set_icon(0, source_icon)
					1: # File
						item.set_text(1, get_human_readable_size(node.get('size', -1)))
						item.set_icon(0, file_icon)
						if is_stored:
							item.add_button(1, download)
						else:
							item.add_button(1, retrieve)
					2: # Directory
						item.set_text(1, "%d item(s)" % len(node.get('children', [])))
						item.set_icon(0, folder_icon)
					3: # Chunk
						item.set_text(1, get_human_readable_size(node.get('size', -1)))
				recursive_tree_maker(item, node.get('children'))


func get_human_readable_size(bytes: int) -> String:
	if bytes < 1024:
		return str(bytes) + " B"
	elif bytes < 1024 * 1024:
		return "%.2f KB" % (bytes / 1024.0)
	elif bytes < 1024 * 1024 * 1024:
		return "%.2f MB" % (bytes / (1024.0 * 1024.0))
	else:
		return "%.2f GB" % (bytes / (1024.0 * 1024.0 * 1024.0))

# Tree button click means download or request
func _on_tree_button_clicked(item: TreeItem, _column: int, id: int, _mouse_button_index: int) -> void:
	var node_hash = tree_item_dict[item]
	if node_hash:
		if id == 0:
			get_file.emit(node_hash)

# Double click request data for that node
func _on_tree_item_activated() -> void:
	var node_hash = tree_item_dict.get(tree.get_selected(), '')
	if node_hash:
		get_info.emit(node_hash)

# Single click sets the Info bar to show all info
func _on_tree_item_selected() -> void:
	set_hovered_item(tree.get_selected())
	#var node_hash = tree_item_dict[tree.get_selected()]
	#if node_hash:
		#var node_dict = current_node_dict[node_hash]

func on_files_dropped(files):
	set_hovered_item(tree.get_item_at_position(get_local_mouse_position()))
	if not hovered_item:
		set_hovered_item(tree.get_selected())
	if hovered_item:
		var node_hash = tree_item_dict[hovered_item]
		if _is_type_dir(hovered_item):
			for path in files:
				file_list.append([path, node_hash])
			timer.start()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if hovered_item and event.button_index == MOUSE_BUTTON_RIGHT:
			set_hovered_item(tree.get_item_at_position(get_local_mouse_position()))
			if not hovered_item:
				set_hovered_item(tree.get_selected())
			menu.show()
			menu.position = get_global_mouse_position()

func _on_context_menu_index_pressed(index: int) -> void:
	match index:
		0: # cancel
			pass
		1: # New folder
			new_folder.parent = tree_item_dict[hovered_item]
			new_folder.show()
			new_folder.position = menu.position
		2: # Delete
			var removal_hash = tree_item_dict[hovered_item]
			confirm_delete.node_hash = removal_hash
			confirm_delete.show()
			confirm_delete.position = menu.position
			


func _on_new_folder_name_submitted(folder_name: String, parent: String) -> void:
	make_directory.emit(folder_name, parent)


func _on_confirm_delete_confirm_deleted(node_hash: String) -> void:
	remove_node.emit(node_hash)


func _on_add_file_pressed() -> void:
	file_dialog.show()


func _on_file_dialog_file_selected(path: String) -> void:
	on_files_dropped([path])


func _on_timer_timeout() -> void:
	if file_list:
		var path_hash = file_list.pop_front()
		var path = path_hash.get(0)
		var node_hash = path_hash.get(1)
		var bytes = FileAccess.get_file_as_bytes(path)
		if bytes:
			upload_data.emit(path.get_file(), bytes, node_hash)
	else:
		timer.stop()

func set_hovered_item(item):
	hovered_item = item
	if hovered_item and _is_type_dir(hovered_item):
		show_add_file.emit(true)
	else:
		show_add_file.emit(false)

func _is_type_dir(tree_item) -> bool:
	var node_hash = tree_item_dict[tree_item]
	if node_hash:
		var node_dict = current_node_dict[node_hash]
		var type = int(node_dict.get('type'))
		if type == 0 or type == 2:  # Source or dir
			return true
	return false
	
