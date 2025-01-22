extends Node2D

@onready var card_scene: PackedScene = preload("res://scenes/Card.tscn")
@onready var game_scene: PackedScene = preload("res://scenes/Game Number.tscn")

@onready var sound_on = preload("res://sprites/sound_on.png")
@onready var sound_off = preload("res://sprites/sound_off.png")

@onready var player1_hand: Hand = $Player1
@onready var player2_hand: Hand = $Player2

@onready var spawn_point3 = $"."

@onready var game_numbers = $GameNumber

var music_tooggle: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(4):
		var card: Card = card_scene.instantiate()
		player1_hand.add_card(card)
		card = card_scene.instantiate()
		player2_hand.add_card(card)
		
	player2_hand.update_turn()
	
	$Sound/Button.scale = Vector2(0.05, 0.05)
	$Sound/AudioStreamPlayer2D.play()
	AudioServer.set_bus_volume_db(0, -5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_steals(turn: int):
	if (turn % 4) == 3:
		player1_hand.add_steal()
		player2_hand.add_steal()

func _on_player_1_card_activated(card: Variant) -> void:
	if player1_hand.turn:
		play_card(player1_hand, card, 1)
		
	elif player2_hand.steals > 0:
		steal_card(player2_hand, player1_hand, card, "steal_player1")

func _on_player_2_card_activated(card: Variant) -> void:
	if player2_hand.turn:
		play_card(player2_hand, card, 2)
		
	elif player1_hand.steals > 0:
		steal_card(player1_hand, player2_hand, card, "steal_player2")

func play_card(player: Hand, card: Card, turn: int) -> void:
	player.remove_card(card)
	game_numbers.calculate_new_number(card, turn)
	update_steals(game_numbers.round_num)
	update_turn()
	
func steal_card(stealer: Hand, robbed: Hand, card: Card, animation: String) -> void:
	robbed.remove_card(card)
	
	$StealAnimations/Steal_Player.add_child(card)
	card.position = Vector2(0,0)
	$StealAnimations/AnimationPlayer.play(animation)
	await get_tree().create_timer(1).timeout
	$StealAnimations/Steal_Player.remove_child(card)
	
	stealer.add_card(card)
	stealer.remove_steal()
	update_turn()
	
func update_turn():
	player1_hand.update_turn()
	player2_hand.update_turn()


func _on_deck_mouse_click(card: Card, animation_player: AnimationPlayer) -> void:
	await get_tree().create_timer(1).timeout
	if player1_hand.turn:
		animation_player.play("add_to_hand")
		await get_tree().create_timer(1).timeout
		player1_hand.add_card(card)
	else:
		animation_player.play("add_to_hand2")
		await get_tree().create_timer(1).timeout
		player2_hand.add_card(card)
		
	player1_hand.update_turn()
	player2_hand.update_turn()


func _on_button_pressed() -> void:
	if music_tooggle:
		music_tooggle = false
		$Sound/Button.scale = Vector2(0.03, 0.03)
		$Sound/Button.icon = sound_off
		AudioServer.set_bus_volume_db(0, -100)
	else:
		music_tooggle = true
		$Sound/Button.scale = Vector2(0.05, 0.05)
		$Sound/Button.icon = sound_on
		AudioServer.set_bus_volume_db(0, -5)
