extends HBoxContainer

signal cancel_toggled(hash: String)

@export var node_name = "N/A"
@export var status = 'N/A'
@export var node_hash = ""
@export var progress = 0

@onready var Name = $Name
@onready var Status = $Status
@onready var progress_bar = $ProgressBar


func _ready() -> void:
	Name.text = node_name
	Name.tooltip_text = node_hash
	Status.text = status
	progress_bar.value = progress

func _on_cancel_pressed() -> void:
	cancel_toggled.emit(node_hash)
	print("TODO: ADD CANCEL FEATURE API Call")
