@tool
class_name Hand extends Node2D

signal card_activated(card: Card)

@export var hand_radius: int = 100
@export var angle_limit: float = 30
@export var max_card_spread_angle: float = 15

@onready var steals_label: Label = $Node2D/Label
@onready var collision_shape: CollisionShape2D = $DebugShape

@onready var card_scene: PackedScene = preload("res://scenes/Card.tscn")

@onready var list_eq = ["+","-","x",":"]
@onready var rng = RandomNumberGenerator.new()

@export var turn: bool = true

@onready var steals: int = 1

var hand: Array = []
var touched: Array = []
var current_higlighted_card_idx: int = -1

func add_card(card: Node2D):
	if turn:
		hand.push_back(card)
		add_child(card)
		card.mouse_entered.connect(_handle_card_touched)
		card.mouse_exited.connect(_handle_card_untouched)
		reposition_cards()
	
func remove_card(card: Card) -> Node2D:
	hand.remove_at(hand.find(card))
	touched.remove_at(touched.find(card))
	remove_child(card)
	reposition_cards()
	return card
	
func reposition_cards():
	var card_spread = min(angle_limit / hand.size(), max_card_spread_angle)
	var current_angle = -(card_spread * hand.size())/2 -90
	for card in hand:
		_card_transform_update(card, current_angle)
		current_angle += card_spread
	

func get_card_position(angle: float):
	var x: float = hand_radius * cos(deg_to_rad(angle))
	var y: float = hand_radius * sin(deg_to_rad(angle))

	return Vector2(int(x), int(y))

func _card_transform_update(card: Node2D, angle: float):
	card.set_position(get_card_position((angle)))
	card.set_rotation(deg_to_rad(angle + 90))

func _handle_card_touched(card: Card):
	touched.push_back(card)

func _handle_card_untouched(card: Card):
	touched.remove_at(touched.find(card))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	steals_label.set_text("Steals: " + str(steals))

func _input(event) -> void:
	if event.is_action_pressed("mouse_click") && current_higlighted_card_idx >= 0:
		var card = hand[current_higlighted_card_idx]
		card_activated.emit(card)
		current_higlighted_card_idx = -1
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for card in hand:
		move_child(card,hand.find(card))
		current_higlighted_card_idx = -1
		card.unhighlight()
	
	if !touched.is_empty():
		var highest_touched_idx: int = -1
		for touched_card in touched:
			highest_touched_idx = max(highest_touched_idx, hand.find(touched_card))
		if highest_touched_idx >= 0 && highest_touched_idx < hand.size():
			hand[highest_touched_idx].highlight()
			move_child(hand[highest_touched_idx],hand.size())
			current_higlighted_card_idx = highest_touched_idx
	
	if (collision_shape.shape as CircleShape2D).radius != hand_radius:
		(collision_shape.shape as CircleShape2D).set_radius(hand_radius)

func add_steal():
	steals += 1
	steals_label.set_text("Steals: " + str(steals))
	
func remove_steal():
	steals -= 1
	steals_label.set_text("Steals: " + str(steals))

func contains_card(card: Card):
	return card in hand

func update_turn():
	if turn:
		turn = false
	else:
		turn = true
