extends VBoxContainer

export var MAX_PLAYERS := 6
export var MIN_PLAYERS := 2
var cur_players := 2

# Called when the node enters the scene tree for the first time.
func _ready():
	update_visible_players()

func update_visible_players():
	for i in range(MAX_PLAYERS + 1):
		get_parent().get_child(i).visible = i <= cur_players

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Plus_pressed():
	cur_players = clamp(cur_players + 1, MIN_PLAYERS, MAX_PLAYERS)
	update_visible_players()

func _on_Minus_pressed():
	cur_players = clamp(cur_players - 1, MIN_PLAYERS, MAX_PLAYERS)
	update_visible_players()
