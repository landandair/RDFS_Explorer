extends HBoxContainer

signal get_info(node_id: String)

func _on_button_pressed() -> void:
	get_info.emit('')
