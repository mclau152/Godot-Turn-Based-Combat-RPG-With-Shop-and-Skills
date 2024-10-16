extends Label

func set_damage_text(damage: int) -> void:
	text = str(damage)

func fade_out() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, 1.5)  # Fade out over 1.5 seconds
	tween.tween_callback(Callable(self, "queue_free"))  # Remove after fading
