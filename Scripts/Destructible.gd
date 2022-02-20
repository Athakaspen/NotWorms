extends StaticBody2D


func _ready() -> void:
	$CollisionPoly.polygon = $RenderPoly.polygon


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
