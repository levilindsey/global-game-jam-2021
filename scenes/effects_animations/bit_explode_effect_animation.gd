extends EffectAnimation
class_name BitExplodeEffectAnimation

const FRAME_SIZE_DEFAULT := Vector2(100, 100)
const OFFSET_DEFAULT := Vector2(0, 0)
const SCALE_MULTIPLIER := 0.09

func calc_position(bit, horizontal_sign: int) -> Vector2:
    var x_offset: float = -horizontal_sign * bit.get_radius()
    return bit.position + Vector2(x_offset, 0) + OFFSET_DEFAULT * Vector2(horizontal_sign, 1)

func calc_scale(bit) -> float:
    return bit.get_radius() * SCALE_MULTIPLIER
