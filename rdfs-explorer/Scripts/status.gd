extends VBoxContainer

signal get_status()
signal cancel_request(hash: String)

var status_item = preload("res://Scenes/status_item.tscn")
@onready var status_block = $ScrollContainer/Status_Block

func _on_reload_pressed() -> void:
	get_status.emit()

# Call to update on change in visibility to shown
func _on_visibility_changed() -> void:
	if self.is_visible_in_tree():
		get_status.emit()

# Got new status, update list
func _status_update(status_dict: Dictionary) -> void:
	# Clear children
	var children = status_block.get_children()
	for child in children:
		child.free()
		
	for node_hash in status_dict:
		var node_dict = status_dict.get(node_hash)
		var node_status: StatusItem = status_item.instantiate()
		var progress = node_dict.get('progress')
		var node_name = node_dict.get('name')
		var sources = node_dict.get('sources')
		var status = 'Waiting for source...'
		if progress > 0:
			status = 'Downloading'
		elif len(sources) > 1:
			status = 'Awaiting Link'
		node_status.progress = progress*100
		node_status.node_name = node_name
		node_status.status = status
		status_block.add_child(node_status)
		
