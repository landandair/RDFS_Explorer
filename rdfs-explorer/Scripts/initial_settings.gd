extends CenterContainer

@export var ip = ''
@export var port = 8000

@onready var port_box = $VBoxContainer/HBoxContainer/port
@onready var ip_box = $VBoxContainer/HBoxContainer/ip


signal connect(ip: String, port: int)

func _ready() -> void:
	ip_box.text = ip
	port_box.text = '%d' % port

func _on_ip_text_changed(new_text: String) -> void:
	ip = new_text


func _on_port_text_changed(new_text: String) -> void:
	port = new_text.to_int()


func _on_connect_pressed() -> void:
	connect.emit(ip, port)


func _on_text_submitted(_new_text: String) -> void:
	connect.emit(ip, port)
