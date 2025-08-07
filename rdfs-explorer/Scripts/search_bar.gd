extends HBoxContainer

signal reload()

func _on_button_pressed() -> void:
	reload.emit()
