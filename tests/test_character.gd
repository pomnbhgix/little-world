extends CharacterBody3D

@export var planet:Node3D;

func _physics_process(delta):
	
	var gravity_direction = -(planet.global_transform.origin - self.global_transform.origin).normalized()

	self.global_transform.basis.y = gravity_direction
	self.global_transform.basis.x = -self.global_transform.basis.z.cross(gravity_direction)
	self.global_transform.basis = self.global_transform.basis.orthonormalized()
	
	up_direction = gravity_direction;
	
	var velo = Vector3.FORWARD * 5;
	
	print_debug(is_on_floor())
	
	if is_on_floor():
		velo.y -= 10 * delta;
	
	velocity = global_transform.basis * velo

	move_and_slide()
