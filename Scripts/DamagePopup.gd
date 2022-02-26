extends Node2D

# vertical speed per second
var speed : float = 80.0
export(Curve) var alpha_curve

onready var kill_timer = $KillTimer

func set_lifespan(sec : float):
	$KillTimer.wait_time = sec

func set_text(text : String):
	$Label.text = text

func set_color(color : Color):
	$Label.modulate = color

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.position += Vector2.UP * speed * delta
	self.modulate.a = alpha_curve.interpolate(1 - kill_timer.time_left/kill_timer.wait_time)

func _on_KillTimer_timeout():
	self.queue_free()
