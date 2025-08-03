extends HBoxContainer

signal favorite_toggled(hash: String, toggled_on: bool)
signal open_pressed(hash: String)

@export var node_name = "N/A"
@export var is_favorite = false
@export var node_hash = "N/A"

@onready var node_name_box = $Name
@onready var hash_box = $Hash
@onready var favorite = $CheckBox

func _ready() -> void:
	self.node_name_box.text = node_name
	self.hash_box.text = node_hash
	self.hash_box.tooltip_text = node_hash


func _on_check_box_toggled(toggled_on: bool) -> void:
	is_favorite = toggled_on # Replace with function body.
	favorite_toggled.emit(node_hash, is_favorite)


func _on_open_pressed() -> void:
	open_pressed.emit(node_hash)
