extends KinematicBody2D

export var move_speed = 300

remote var target_position: Vector2 = Vector2()

func _physics_process(delta):
	if is_network_master():
		move_and_collide(move_speed * Vector2(int(Input.is_action_pressed("g_right")) - int(Input.is_action_pressed("g_left")), -int(Input.is_action_pressed("g_up")) + int(Input.is_action_pressed("g_down")))*delta)
		rset_unreliable("target_position", global_position)
	else:
		move_and_collide(target_position - global_position)
