@tool
class_name Deck extends Node2D

signal mouse_click(card: Card, animation: AnimationPlayer)

@onready var card_scene: PackedScene = preload("res://scenes/Card.tscn")

@onready var tip: Label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tip.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_mouse_entered() -> void:
	tip.visible = true


func _on_button_mouse_exited() -> void:
	tip.visible = false


func _on_button_pressed() -> void:
	var card: Card = card_scene.instantiate()
	$Card.setValue(card.card_value)
	$AnimationPlayer.play("draw")
	mouse_click.emit(card, $AnimationPlayer)
	$AudioStreamPlayer2D.play()
