extends HBoxContainer

signal reload()

@onready var add_file = $add_file

func _on_button_pressed() -> void:
	reload.emit()


func _on_file_browse_show_add_file(state: bool) -> void:
	if state:
		add_file.show()
	else:
		add_file.hide()
