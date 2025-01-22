extends Node2D

@onready var round_num = 0
@onready var player_1_points = 0
@onready var player_2_points = 0

@onready var rng = RandomNumberGenerator.new()
@onready var game_number = rng.randi_range(1, 9)
@onready var player_1_number = rng.randi_range(11, 50)
@onready var player_2_number = rng.randi_range(11, 50)

@onready var game_number_label = $NormalGame/GameNumber
@onready var player_1_label = $"NormalGame/Player 1/Goal"
@onready var player_2_label = $"NormalGame/Player 2/Goal"
@onready var round_num_label = $NormalGame/CardsPlayed
@onready var victor_label = $End/Label

@onready var player_1_point_1 = $"NormalGame/Player 1/Point 1"
@onready var player_1_point_2 = $"NormalGame/Player 1/Point 2"
@onready var player_2_point_1 = $"NormalGame/Player 2/Point 1"
@onready var player_2_point_2 = $"NormalGame/Player 2/Point 2"

@onready var game_panel = $NormalGame
@onready var end_panel = $End

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	end_panel.visible = false
	player_1_label.set_text("Goal: " + str(player_1_number))
	player_2_label.set_text("Goal: " + str(player_2_number))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	game_number_label.set_text(str(game_number))
	round_num_label.set_text("Cards played: " + str(round_num))
	
	_check_for_winner()
	_update_points()

func _check_for_winner() -> void:
	if player_1_number == game_number:
		end_game("Player 1")
		
	elif player_2_number == game_number:
		end_game("Player 2")
		
	elif round_num >= 12:
		if player_1_points > player_2_points:
			end_game("Player 1")
		else:
			end_game("Player 2")
			
func _update_points() -> void:
	if player_1_points >= 1:
		$"NormalGame/Player 1/Point 1/Point".modulate = Color(0,1,0)
	if player_1_points >= 2:
		$"NormalGame/Player 1/Point 2/Point".modulate = Color(0,1,0)
		
	if player_2_points >= 1:
		$"NormalGame/Player 2/Point 1/Point".modulate = Color(0,1,0)
	if player_2_points >= 2:
		$"NormalGame/Player 2/Point 2/Point".modulate = Color(0,1,0)

func end_game(winner: String) -> void:
	if !end_panel.visible:
		$End/AudioStreamPlayer2D.play()
	end_panel.visible = true
	victor_label.set_text(str("Winner\n"+winner))

func calculate_new_number(card: Card, turn: int) -> void:
	var eq_list = card.card_value.split(" ")
	
	if turn == 1:
		$Player1.add_child(card)
		card.position = Vector2(0,0)
		$AnimationPlayer.play("player1_card")
		await get_tree().create_timer(1).timeout
		$Player1.remove_child(card)
	else:
		$Player2.add_child(card)
		card.position = Vector2(0,0)
		$AnimationPlayer.play("player2_card")
		await get_tree().create_timer(1).timeout
		$Player2.remove_child(card)
	
	
	if(eq_list[0] == "+"):
		game_number = game_number + int(eq_list[1])
	elif(eq_list[0] == "-"):
		game_number = game_number - int(eq_list[1])
	elif(eq_list[0] == "x"):
		game_number = game_number * int(eq_list[1])
	elif(eq_list[0] == ":"):
		game_number = game_number / int(eq_list[1])
		
	round_num += 1
	
	if (round_num % 4) == 0:
		if abs(game_number - player_1_number) < abs(game_number - player_2_number):
			player_1_points += 1
		elif abs(game_number - player_1_number) > abs(game_number - player_2_number):
			player_2_points += 1

func _on_button_4_pressed() -> void:
	get_tree().reload_current_scene()
