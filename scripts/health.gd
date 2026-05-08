extends Control

@onready var health_label: Label = $Label

func _ready() -> void:
    var player = get_tree().get_first_node_in_group("player")
    if player:
        if player.has_signal("health_changed"):
            player.health_changed.connect(_on_player_health_changed)
        _update_health()

func _on_player_health_changed(new_health: int) -> void:
    health_label.text = str(new_health)

func _update_health() -> void:
    var player = get_tree().get_first_node_in_group("player")
    if player:
        health_label.text = str(player.health)