extends Control

@onready var health_label: Label = $Label

func _ready() -> void:
    _update_health()

    var player = get_tree().get_first_node_in_group("player")
    if player and player.has_signal("health_changed"):
        player.health_changed.connect(_on_player_health_changed)

func _on_player_health_changed(new_health: int) -> void:
    health_label.text = str(new_health)

func _update_health() -> void:
    health_label.text = str(GameState.playerhealth)