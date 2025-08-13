extends PopupPanel

signal name_submitted(name: String, parent: String)
var folder_name := ""
var parent := ""
@onready var line_edit = $VBoxContainer/LineEdit

func _on_line_edit_text_changed(new_text: String) -> void:
	folder_name = new_text


func _on_ok_pressed() -> void:
	_submit_folder()
	_reset_self()


func _on_cancel_pressed() -> void:
	_reset_self()


func _on_line_edit_text_submitted(_new_text: String) -> void:
	_submit_folder()
	_reset_self()

func _submit_folder() -> void:
	if folder_name:
		name_submitted.emit(folder_name, parent)

func _reset_self() -> void:
	folder_name = ""
	line_edit.text = folder_name
	self.hide()

func _on_line_edit_visibility_changed() -> void:
	if line_edit.is_visible_in_tree():
		line_edit.grab_focus()
