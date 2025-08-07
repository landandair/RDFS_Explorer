extends PopupPanel

signal confirm_deleted(node_hash: String)
var node_hash := ""


func _on_ok_pressed() -> void:
	_submit_delete()
	self.hide()


func _on_cancel_pressed() -> void:
	self.hide()

func  _submit_delete() -> void:
	confirm_deleted.emit(node_hash)
