@tool
class_name Card extends Node2D

signal mouse_entered(card: Card)
signal mouse_exited(card: Card)

@export var card_value: String

@onready var value_label: Label = $Number/Label
@onready var card: Sprite2D = $BaseCard

@onready var list_eq = ["+","-","x",":"]
@onready var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setValue(_new_card_value())

func setValue(value: String) -> void:
	card_value = value
	
	value_label.set_text(card_value)

func activate():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	setValue(card_value)

func _new_card_value():
	var eq = list_eq.pick_random()
	var num
	if eq == "+" or eq == "-":
		num = str(rng.randi_range(1, 9))
	elif eq == "x" or eq == ":":
		num = str(rng.randi_range(1, 5))
	
	return str(eq + " " + num)

func highlight():
	card.scale = Vector2(1.1,1.1)

func unhighlight():
	card.scale = Vector2(1,1)
	
func _on_area_2d_mouse_entered() -> void:
	mouse_entered.emit(self)


func _on_area_2d_mouse_exited() -> void:
	mouse_exited.emit(self)


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	pass # Replace with function body.
