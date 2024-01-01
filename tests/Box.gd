extends RigidBody3D


func _physics_process(delta):
	pass
	
func _integrate_forces(state):
	apply_central_impulse(Vector3(0.1,0,0))
