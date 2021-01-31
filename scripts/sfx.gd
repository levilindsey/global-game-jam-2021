extends Node

# Centralized SFX management.

const MIN_DB = -80.0
const SFX_DB = -8.0

enum {
    DASH,
    DEAD,
    GOAL,
    GROWTH,
    JUMP,
    LAND,
}

const SAMPLES = {
    # Add sfx samples here.
    DASH: preload("res://assets/sfx/blob-dash.wav"),
    DEAD: preload("res://assets/sfx/blob-dead.wav"),
    GOAL: preload("res://assets/sfx/blob-goal.wav"),
    GROWTH: preload("res://assets/sfx/blob-growth.wav"),
    JUMP: preload("res://assets/sfx/blob-jump.wav"),
    LAND: preload("res://assets/sfx/blob-land.wav"),
}

const POOL_SIZE = 8
var pool = []
# Index of the current audio player in the pool.
var next_player = 0

func _ready():
    _init_stream_players()

func _init_stream_players():
    for i in range(POOL_SIZE):
        var player = AudioStreamPlayer.new()
        add_child(player)
        pool.append(player)

func _get_next_player_idx():
    var next = next_player
    next_player = (next_player + 1) % POOL_SIZE
    return next

func play(sample):
    assert(sample in SAMPLES)
    var stream = SAMPLES[sample]
    var idx = _get_next_player_idx()

    var player = pool[idx]
    player.stream = stream
    player.volume_db = lerp(MIN_DB, SFX_DB, Constants.VOLUME_SCALE)
    player.play()
