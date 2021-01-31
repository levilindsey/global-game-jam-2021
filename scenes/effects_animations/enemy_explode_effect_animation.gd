extends EffectAnimation
class_name EnemyExplodeEffectAnimation

const FRAME_SIZE_DEFAULT := Vector2(100, 100)
const OFFSET_DEFAULT := Vector2(0, 0)
const SCALE_MULTIPLIER := 0.09

func calc_position(enemy, horizontal_sign: int) -> Vector2:
    var x_offset: float = -horizontal_sign * enemy.get_radius()
    return enemy.position + Vector2(x_offset, 0) + OFFSET_DEFAULT * Vector2(horizontal_sign, 1)

func calc_scale(enemy) -> float:
    return enemy.get_radius() * SCALE_MULTIPLIER
