extends Node2D

@onready var card_scene: PackedScene = preload("res://scenes/Card.tscn")
@onready var game_scene: PackedScene = preload("res://scenes/Game Number.tscn")

@onready var player1_hand: Hand = $Player1
@onready var player2_hand: Hand = $Player2

@onready var spawn_point3 = $"."

@onready var game_numbers = game_scene.instantiate()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_point3.add_child(game_numbers)
	for i in range(4):
		var card: Card = card_scene.instantiate()
		player1_hand.add_card(card)
		card = card_scene.instantiate()
		player2_hand.add_card(card)
		
	player2_hand.update_turn()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_steals(turn: int):
	if (turn % 4) == 0:
		player1_hand.add_steal()
		player2_hand.add_steal()

func _on_button_pressed() -> void:
	var card: Card = card_scene.instantiate()
	player1_hand.add_card(card)
	if player1_hand.turn:
		player1_hand.update_turn()
		player2_hand.update_turn()

func _on_button_2_pressed() -> void:
	var card: Card = card_scene.instantiate()
	player2_hand.add_card(card)
	if player2_hand.turn:
		player1_hand.update_turn()
		player2_hand.update_turn()

func _on_player_1_card_activated(card: Variant) -> void:
	if player1_hand.turn:
		play_card(player1_hand, card)
		
	elif player2_hand.steals > 0:
		steal_card(player2_hand, player1_hand, card)

func _on_player_2_card_activated(card: Variant) -> void:
	if player2_hand.turn:
		play_card(player2_hand, card)
		
	elif player1_hand.steals > 0:
		steal_card(player1_hand, player2_hand, card)

func play_card(player: Hand, card: Card) -> void:
	player.remove_card(card)
	game_numbers.calculate_new_number(card.card_value)
	update_steals(game_numbers.round_num)
	update_turn()
	
func steal_card(stealer: Hand, robbed: Hand, card: Card) -> void:
	robbed.remove_card(card)
	stealer.add_card(card)
	stealer.remove_steal()
	update_turn()
	
func update_turn():
	player1_hand.update_turn()
	player2_hand.update_turn()
