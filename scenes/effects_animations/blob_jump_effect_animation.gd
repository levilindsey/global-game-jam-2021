extends EffectAnimation
class_name BlobJumpEffectAnimation

const FRAME_SIZE_DEFAULT := Vector2(100, 100)
const OFFSET_DEFAULT := Vector2(25, -26)
const SCALE_MULTIPLIER := 0.09

func calc_position(player, horizontal_sign: int) -> Vector2:
    var x_offset: float = -horizontal_sign * player._get_radius()
    return player.position + Vector2(x_offset, 0) + OFFSET_DEFAULT * Vector2(horizontal_sign, 1)

func calc_scale(player) -> float:
    return player._get_radius() * SCALE_MULTIPLIER
