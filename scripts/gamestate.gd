extends Node


var score: int = 0 
var level: int = 1
var playerhealth: int = 5

func add_score():
    score += 1

func reset():
    score = 0
    level = 1
    playerhealth = 5