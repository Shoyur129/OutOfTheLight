extends Node

var last_location = null  # Start with no checkpoint set
var player

func _ready() -> void:
    player = get_parent().get_node("Player")
