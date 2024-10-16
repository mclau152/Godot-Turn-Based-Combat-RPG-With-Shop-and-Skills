extends Node2D

@onready var stats_button = $StatPointsButton
@onready var gold_label = $GoldLabel
@onready var buy_hp_potion_button = $BuyHPPotionButton
@onready var buy_mp_potion_button = $BuyMPPotionButton
@onready var hp_potions_label = $HPPotionsLabel
@onready var mp_potions_label = $MPPotionsLabel

var player_stats = load("res://Player_Stats.tres")
var enemy_stats = load("res://Enemy_Stats.tres")

const HP_POTION_COST = 25
const MP_POTION_COST = 15

func _ready():
	connect_buttons()
	update_ui()

func connect_buttons() -> void:
	stats_button.pressed.connect(next_stats)
	buy_hp_potion_button.pressed.connect(buy_hp_potion)
	buy_mp_potion_button.pressed.connect(buy_mp_potion)

func update_ui() -> void:
	gold_label.text = 'Gold: ' + str(player_stats.Gold)
	hp_potions_label.text = 'HP Potions: ' + str(player_stats.PlayerHPPotions)
	mp_potions_label.text = 'MP Potions: ' + str(player_stats.PlayerMPPotions)
	buy_hp_potion_button.disabled = player_stats.Gold < HP_POTION_COST
	buy_mp_potion_button.disabled = player_stats.Gold < MP_POTION_COST

func next_stats() -> void:
	get_tree().change_scene_to_file("res://stat_points.tscn")

func buy_hp_potion() -> void:
	if player_stats.Gold >= HP_POTION_COST:
		player_stats.Gold -= HP_POTION_COST
		player_stats.PlayerHPPotions += 1
		update_ui()

func buy_mp_potion() -> void:
	if player_stats.Gold >= MP_POTION_COST:
		player_stats.Gold -= MP_POTION_COST
		player_stats.PlayerMPPotions += 1
		update_ui()
