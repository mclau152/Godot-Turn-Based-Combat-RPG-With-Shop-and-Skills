extends Node2D

@onready var experience_bar = $ExperienceBar
@onready var experience_label = $ExperienceLabel
@onready var level_label = $LevelLabel
@onready var skill_points_label = $SkillPointsLabel
@onready var strength_label = $StrengthLabel
@onready var speed_label = $SpeedLabel
@onready var wisdom_label = $WisdomLabel
@onready var max_hp_label = $MaxHPLabel
@onready var max_mp_label = $MaxMPLabel
@onready var add_strength_button = $AddStrengthButton
@onready var add_speed_button = $AddSpeedButton
@onready var add_wisdom_button = $AddWisdomButton
@onready var add_max_hp_button = $AddMaxHPButton
@onready var add_max_mp_button = $AddMaxMPButton
@onready var next_combat_button = $NextCombatButton
@onready var shop_button = $ShopButton
@onready var ability_points_label = $AbilityPointsLabel
@onready var stab_skill_button = $StabSkillButton
@onready var stars_skill_button = $StarsSkillButton
@onready var stab_skill_label = $StabSkillLabel
@onready var stars_skill_label = $StarsSkillLabel

var player_stats = load("res://Player_Stats.tres")
var enemy_stats = load("res://Enemy_Stats.tres")

func _ready() -> void:
	check_level_up()
	
	update_ui()
	connect_buttons()
	check_level_up()


func check_level_up() -> void:
	while player_stats.PlayerExperience >= player_stats.PlayerMaxExperience:
		player_stats.PlayerLevel += 1
		player_stats.PlayerExperience -= player_stats.PlayerMaxExperience
		player_stats.SkillPoints += 3
		player_stats.AbilityPoints += 1
		player_stats.PlayerMaxExperience *= 1.5
		player_stats.PlayerCurrentHP = player_stats.PlayerMaxHP
		player_stats.PlayerCurrentMP = player_stats.PlayerMaxMP


func update_ui() -> void:
	experience_bar.max_value = player_stats.PlayerMaxExperience
	experience_bar.value = player_stats.PlayerExperience
	experience_label.text = 'Experience: ' + str(player_stats.PlayerExperience) + '/' + str(player_stats.PlayerMaxExperience)
	level_label.text = "Level: " + str(player_stats.PlayerLevel)
	skill_points_label.text = "Skill Points: " + str(player_stats.SkillPoints)
	strength_label.text = "Strength: " + str(player_stats.PlayerStrength)
	speed_label.text = "Speed: " + str(player_stats.PlayerSpeed)
	wisdom_label.text = "Wisdom: " + str(player_stats.PlayerWisdom)
	max_hp_label.text = "Max HP: " + str(player_stats.PlayerMaxHP)
	max_mp_label.text = "Max MP: " + str(player_stats.PlayerMaxMP)
	add_strength_button.disabled = player_stats.SkillPoints == 0
	add_speed_button.disabled = player_stats.SkillPoints == 0
	add_wisdom_button.disabled = player_stats.SkillPoints == 0
	add_max_hp_button.disabled = player_stats.SkillPoints == 0
	add_max_mp_button.disabled = player_stats.SkillPoints == 0
	ability_points_label.text = "Ability Points: " + str(player_stats.AbilityPoints)
	stab_skill_label.text = "Stab Skill: " + str(player_stats.StabSkillLevel)
	stars_skill_label.text = "Stars Skill: " + str(player_stats.StarsSkillLevel)
	stab_skill_button.disabled = player_stats.AbilityPoints == 0
	stars_skill_button.disabled = player_stats.AbilityPoints == 0

func connect_buttons() -> void:
	add_strength_button.pressed.connect(add_strength)
	add_speed_button.pressed.connect(add_speed)
	add_wisdom_button.pressed.connect(add_wisdom)
	add_max_hp_button.pressed.connect(add_max_hp)
	add_max_mp_button.pressed.connect(add_max_mp)
	next_combat_button.pressed.connect(next_combat)
	shop_button.pressed.connect(next_shop)
	stab_skill_button.pressed.connect(upgrade_stab_skill)
	stars_skill_button.pressed.connect(upgrade_stars_skill)

func upgrade_stab_skill() -> void:
	if player_stats.AbilityPoints > 0:
		player_stats.StabSkillLevel += 1
		player_stats.AbilityPoints -= 1
		update_ui()

func upgrade_stars_skill() -> void:
	if player_stats.AbilityPoints > 0:
		player_stats.StarsSkillLevel += 1
		player_stats.AbilityPoints -= 1
		update_ui()

func add_strength() -> void:
	if player_stats.SkillPoints > 0:
		player_stats.PlayerStrength += 1
		player_stats.SkillPoints -= 1
		update_ui()

func add_speed() -> void:
	if player_stats.SkillPoints > 0:
		player_stats.PlayerSpeed += 1
		player_stats.SkillPoints -= 1
		update_ui()

func add_wisdom() -> void:
	if player_stats.SkillPoints > 0:
		player_stats.PlayerWisdom += 1
		player_stats.SkillPoints -= 1
		update_ui()

func add_max_hp() -> void:
	if player_stats.SkillPoints > 0:
		player_stats.PlayerMaxHP += 10
		player_stats.SkillPoints -= 1
		player_stats.PlayerCurrentHP += 10
		update_ui()

func add_max_mp() -> void:
	if player_stats.SkillPoints > 0:
		player_stats.PlayerMaxMP += 10
		player_stats.SkillPoints -= 1
		player_stats.PlayerCurrentMP += 10
		update_ui()

func next_combat() -> void:
	increase_enemy_stats()
	get_tree().change_scene_to_file("res://battle.tscn")
	
func next_shop() -> void:
	get_tree().change_scene_to_file("res://shop.tscn")

func increase_enemy_stats() -> void:
	var multiplier = randf_range(1.02, 1.19)
	enemy_stats.EnemyMaxHP *= multiplier
	enemy_stats.EnemyStrength *= multiplier
	enemy_stats.EnemySpeed *= multiplier
	enemy_stats.EnemyArmor *= multiplier
	enemy_stats.EnemyWeaponDamage *= multiplier
	enemy_stats.EnemyExperience *= multiplier * randf_range(1.1,1.5)
	enemy_stats.EnemyGold *= multiplier * randf_range(1.1,1.5)
	# Reset enemy current HP to new max HP
	enemy_stats.EnemyCurrentHP = enemy_stats.EnemyMaxHP
