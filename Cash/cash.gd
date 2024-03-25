extends RigidBody3D


func despawn():
	await get_tree().create_timer(1).timeout
	queue_free()
