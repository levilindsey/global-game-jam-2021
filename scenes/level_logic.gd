extends Node2D

const _TILEMAP_SCALE := 0.15

onready var music = $"/root/Music"

export (String, FILE, "*.tscn") var next_level

func _ready():
    add_to_group("levels")
    music.play_background()
    _scale_tilemaps()

func _scale_tilemaps() -> void:
    var tilemaps: Array = Utils.get_children_by_type(self, TileMap, true)
    for tilemap in tilemaps:
        tilemap.scale = Vector2(_TILEMAP_SCALE, _TILEMAP_SCALE)

# TODO: Add level transitions here
