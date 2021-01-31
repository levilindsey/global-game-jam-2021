tool
extends Node2D

onready var music = $"/root/Music"

export (String, FILE, "*.tscn") var next_level

func _ready():
    add_to_group("levels")
    music.play_background()

# TODO: Add level transitions here
