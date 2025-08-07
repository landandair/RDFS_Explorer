extends Control

@onready var tab_container = $TabContainer
@onready var initial_settings = $Initial_settings

func _ready() -> void:
	pass
	# TODO: Load save data here


func _on_initial_settings_connect(ip: String, port: int) -> void:
	var res = await tab_container.http_connect(ip, port)
	if res:
		initial_settings.hide()
