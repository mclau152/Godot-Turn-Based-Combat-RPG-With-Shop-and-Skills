extends Node2D

@onready var player = $Player
@onready var enemy = $Enemy
@onready var attack_button = $AttackButton
@onready var player_hp_bar = $PlayerHPBar
@onready var enemy_hp_bar = $EnemyHPBar
@onready var player_hp_label = $PlayerHPLabel
@onready var enemy_hp_label = $EnemyHPLabel
@onready var player_mp_label = $PlayerMPLabel
@onready var player_mp_bar = $PlayerMPBar
@onready var hp_potion_label = $HPPotionLabel
@onready var hp_potion_button = $HPPotionButton
@onready var mp_potion_label = $MPPotionLabel
@onready var mp_potion_button = $MPPotionButton
@onready var stab_button = $StabButton
@onready var stars_button = $StarsButton
@onready var damage_text_scene = preload("res://DamageText.tscn")
@onready var wait_panel = $PleaseWaitPanel
@onready var game_over_panel = $GameOverPanel
@onready var try_again_button = $GameOverPanel/TryAgainButton
@onready var victory_panel = $VictoryPanel
@onready var victory_button = $VictoryPanel/VictoryButton
@onready var experience_gained_label = $VictoryPanel/ExperienceGainedLabel
@onready var gold_gained_label = $VictoryPanel/GoldGainedLabel

# Load player and enemy stats
var player_stats = load("res://Player_Stats.tres")
var enemy_stats = load("res://Enemy_Stats.tres")

# Define movement variables
var player_move_distance = 50
var enemy_move_distance = 50
var move_duration = 0.5  # Time in seconds for movement

func _ready() -> void:
	wait_panel.hide()
	attack_button.pressed.connect(_on_attack_button_pressed)
	try_again_button.pressed.connect(_on_try_again_button_pressed)
	victory_button.pressed.connect(_on_victory_button_pressed)
	stab_button.pressed.connect(_on_stab_button_pressed)
	stars_button.pressed.connect(_on_stars_button_pressed)
	update_mp_display()
	
	hp_potion_button.pressed.connect(_on_hp_potion_button_pressed)
	mp_potion_button.pressed.connect(_on_mp_potion_button_pressed)
	update_potion_display()

	update_hp_labels()
	game_over_panel.hide()
	victory_panel.hide()
	#player_stats.PlayerCurrentHP = player_stats.PlayerMaxHP
	enemy_stats.EnemyCurrentHP = enemy_stats.EnemyMaxHP
	update_hp_bars()
	update_hp_labels()

func update_potion_display() -> void:
	hp_potion_label.text = "HP Potions: " + str(player_stats.PlayerHPPotions)
	mp_potion_label.text = "MP Potions: " + str(player_stats.PlayerMPPotions)
	hp_potion_button.disabled = player_stats.PlayerHPPotions <= 0
	mp_potion_button.disabled = player_stats.PlayerMPPotions <= 0

func _on_hp_potion_button_pressed() -> void:
	if player_stats.PlayerHPPotions > 0:
		player_stats.PlayerHPPotions -= 1
		player_stats.PlayerCurrentHP = min(player_stats.PlayerCurrentHP + 80, player_stats.PlayerMaxHP)
		update_hp_bars()
		update_hp_labels()
		update_mp_display()
		update_potion_display()
		if enemy_stats.EnemyCurrentHP > 0:
			await move_enemy()
			apply_damage_to_player()

func _on_mp_potion_button_pressed() -> void:
	
	if player_stats.PlayerMPPotions > 0:
		player_stats.PlayerMPPotions -= 1
		player_stats.PlayerCurrentMP = min(player_stats.PlayerCurrentMP + 80, player_stats.PlayerMaxMP)
		update_hp_bars()  # This also updates MP bar
		update_hp_labels()  # This also updates MP label
		update_potion_display()
		update_mp_display()
		if enemy_stats.EnemyCurrentHP > 0:
			await move_enemy()
			apply_damage_to_player()


func _on_attack_button_pressed() -> void:
	wait_panel.show()
	await move_player()
	apply_damage_to_enemy()
	await get_tree().create_timer(0.5).timeout
	if enemy_stats.EnemyCurrentHP > 0:
		await move_enemy()
		apply_damage_to_player()
	wait_panel.hide()

func move_player() -> void:
	var player_original_position = player.position
	var player_target_position = player_original_position + Vector2(player_move_distance, 0)

	var tween = create_tween()
	tween.tween_property(player, "position", player_target_position, move_duration)
	tween.tween_property(player, "position", player_original_position, move_duration)
	await tween.finished

func move_enemy() -> void:
	wait_panel.show()
	var enemy_original_position = enemy.position
	var enemy_target_position = enemy_original_position - Vector2(enemy_move_distance, 0)

	var tween = create_tween()
	tween.tween_property(enemy, "position", enemy_target_position, move_duration)
	tween.tween_property(enemy, "position", enemy_original_position, move_duration)
	await tween.finished
	wait_panel.hide()

func apply_damage_to_enemy() -> void:
	var base_damage = player_stats.PlayerStrength + player_stats.PlayerWeaponDamage - enemy_stats.EnemyArmor
	var damage_multiplier = randf_range(0.7, 1.3)
	var player_damage = base_damage * damage_multiplier
	player_damage = max(player_damage, 0)
	enemy_stats.EnemyCurrentHP -= player_damage
	enemy_hp_bar.value = enemy_stats.EnemyCurrentHP
	show_damage_text(enemy, player_damage)
	update_hp_labels()
	check_enemy_defeated()

func apply_damage_to_player() -> void:
	var base_enemy_damage = enemy_stats.EnemyStrength + enemy_stats.EnemyWeaponDamage - player_stats.PlayerArmor
	var enemy_damage_multiplier = randf_range(0.7, 1.3)
	var enemy_damage = base_enemy_damage * enemy_damage_multiplier
	enemy_damage = max(enemy_damage, 0)
	player_stats.PlayerCurrentHP -= enemy_damage
	player_hp_bar.value = player_stats.PlayerCurrentHP
	show_damage_text(player, enemy_damage)
	update_hp_labels()
	check_player_defeated()

func show_damage_text(target: Node2D, damage: float) -> void:
	var damage_text = damage_text_scene.instantiate()
	add_child(damage_text)
	damage_text.position = target.position + Vector2(0, -20)
	damage_text.set_damage_text(int(damage))
	damage_text.fade_out()

func update_hp_labels() -> void:
	player_hp_label.text = str(int(player_stats.PlayerCurrentHP)) + " / " + str(player_stats.PlayerMaxHP)
	enemy_hp_label.text = str(int(enemy_stats.EnemyCurrentHP)) + " / " + str(enemy_stats.EnemyMaxHP)
	player_mp_label.text = str(int(player_stats.PlayerCurrentMP)) + " / " + str(player_stats.PlayerMaxMP)

func update_hp_bars() -> void:
	player_hp_bar.max_value = player_stats.PlayerMaxHP
	player_hp_bar.value = player_stats.PlayerCurrentHP

	enemy_hp_bar.max_value = enemy_stats.EnemyMaxHP
	enemy_hp_bar.value = enemy_stats.EnemyCurrentHP

	player_mp_bar.max_value = player_stats.PlayerMaxMP
	player_mp_bar.value = player_stats.PlayerCurrentMP

func update_mp_display() -> void:
	update_hp_labels()  # This now includes MP label update
	update_hp_bars()    # This now includes MP bar update
	stab_button.disabled = player_stats.PlayerCurrentMP < 10
	stars_button.disabled = player_stats.PlayerCurrentMP < 20


func _on_stab_button_pressed() -> void:
	wait_panel.show()
	if player_stats.PlayerCurrentMP >= 10:
		player_stats.PlayerCurrentMP -= 10
		await move_player()
		apply_stab_damage_to_enemy()
		update_mp_display()
		await get_tree().create_timer(0.5).timeout
		if enemy_stats.EnemyCurrentHP > 0:
			await move_enemy()
			apply_damage_to_player()
		wait_panel.hide()

func _on_stars_button_pressed() -> void:
	wait_panel.show()
	if player_stats.PlayerCurrentMP >= 20:
		player_stats.PlayerCurrentMP -= 20
		await move_player()
		apply_stars_damage_to_enemy()
		update_mp_display()
		await get_tree().create_timer(0.5).timeout
		if enemy_stats.EnemyCurrentHP > 0:
			await move_enemy()
			apply_damage_to_player()
	wait_panel.hide()

func apply_stab_damage_to_enemy() -> void:
	var base_damage = player_stats.PlayerStrength + player_stats.PlayerWeaponDamage - enemy_stats.EnemyArmor
	var stab_multiplier = 1 + randf_range(0.1, 0.2) + (0.05 * player_stats.StabSkillLevel)  # 10-20% increase + 5% per skill level
	var player_damage = base_damage * stab_multiplier
	player_damage = max(player_damage, 0)
	enemy_stats.EnemyCurrentHP -= player_damage
	enemy_hp_bar.value = enemy_stats.EnemyCurrentHP
	show_damage_text(enemy, player_damage)
	update_hp_labels()
	check_enemy_defeated()

func apply_stars_damage_to_enemy() -> void:
	var stars_multiplier = randf_range(3.0, 3.5) + (0.1 * player_stats.StarsSkillLevel)  # 300-350% of wisdom + 10% per skill level
	var player_damage = player_stats.PlayerWisdom * stars_multiplier
	player_damage = max(player_damage, 0)
	enemy_stats.EnemyCurrentHP -= player_damage
	enemy_hp_bar.value = enemy_stats.EnemyCurrentHP
	show_damage_text(enemy, player_damage)
	update_hp_labels()
	check_enemy_defeated()

func check_player_defeated() -> void:
	if player_stats.PlayerCurrentHP <= 0:
		game_over_panel.show()
		attack_button.disabled = true

func check_enemy_defeated() -> void:
	if enemy_stats.EnemyCurrentHP <= 0:
		wait_panel.show()
		victory_panel.show()
		experience_gained_label.text = 'Experience Gained: ' + str(enemy_stats.EnemyExperience)
		gold_gained_label.text = 'Gold Gained: ' + str(enemy_stats.EnemyGold)
		# Disable ALL action buttons
		attack_button.disabled = true
		stab_button.disabled = true
		stars_button.disabled = true
		hp_potion_button.disabled = true
		mp_potion_button.disabled = true

func _on_try_again_button_pressed() -> void:
	# Reset the game state
	player_stats.PlayerCurrentHP = player_stats.PlayerMaxHP
	enemy_stats.EnemyCurrentHP = enemy_stats.EnemyMaxHP
	update_hp_labels()
	player_hp_bar.value = player_stats.PlayerCurrentHP
	enemy_hp_bar.value = enemy_stats.EnemyCurrentHP
	game_over_panel.hide()
	attack_button.disabled = false
	player_stats.PlayerCurrentMP = player_stats.PlayerMaxMP
	update_mp_display()

func add_enemy_experience() -> void:
	player_stats.PlayerExperience += enemy_stats.EnemyExperience
	

func add_enemy_gold() -> void:
	player_stats.Gold += enemy_stats.EnemyGold

func _on_victory_button_pressed() -> void:
	add_enemy_experience()
	add_enemy_gold()
	# Load the stat_points scene
	get_tree().change_scene_to_file("res://stat_points.tscn")
