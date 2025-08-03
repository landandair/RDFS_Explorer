extends VBoxContainer

signal get_status()
signal cancel_request(hash: String)

var status_item = preload("res://Scenes/status_item.tscn")
@onready var status_block = $Status_Block

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
		print(node_hash)
		
