extends CharacterBody3D

@export var planet:Node3D;
@export var debuger:Node;
# input
var motion := Vector2()
var sprint = false
var jump = false

# Camera
const CAMERA_CONTROLLER_ROTATION_SPEED := 3.0
const CAMERA_MOUSE_ROTATION_SPEED := 0.001
const CAMERA_X_ROT_MIN := deg_to_rad(-89.9)
const CAMERA_X_ROT_MAX := deg_to_rad(70)
@export var camera_base: Node3D
@export var camera_rot: Node3D
@export var camera: Camera3D

# locomotion
const MOTION_INTERPOLATE_SPEED = 10.0
const WALK_SPEED = 6.0
const RUN_SPEED = 10.0
const JUMP_VELOCITY = 4.5
var cur_speed = 0.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _process(_delta):
	handle_input()

func _physics_process(delta):
	locomotionv1(delta)
	# # Add the gravity.
	# if not is_on_floor():
	# 	velocity.y -= gravity * delta

	# # Handle jump.
	# if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	# 	velocity.y = JUMP_VELOCITY

	# # Get the input direction and handle the movement/deceleration.
	# # As good practice, you should replace UI actions with custom gameplay actions.
	# var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	# var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	# if direction:
	# 	velocity.x = direction.x * SPEED
	# 	velocity.z = direction.z * SPEED
	# else:
	# 	velocity.x = move_toward(velocity.x, 0, SPEED)
	# 	velocity.z = move_toward(velocity.z, 0, SPEED)

	# move_and_slide()

func _input(event):
	if event is InputEventMouseMotion:
		var camera_speed_this_frame = CAMERA_MOUSE_ROTATION_SPEED
		rotate_camera(event.relative * camera_speed_this_frame)


func handle_input():
	motion = Input.get_vector(&"move_back", &"move_forward",
			&"move_left", &"move_right")
	sprint = Input.is_action_pressed("sprint")
	jump = Input.is_action_pressed("jump")

func rotate_camera(move):
	camera_base.rotate_y(-move.x)
	# After relative transforms, camera needs to be renormalized.
	camera_base.orthonormalize()
	camera_rot.rotation.x = clamp(
		camera_rot.rotation.x + move.y, CAMERA_X_ROT_MIN, CAMERA_X_ROT_MAX
	)

var first = true;

func get_planet_position():
	if planet:
		return planet.global_transform.origin
	else:
		return Vector3.ZERO

func locomotionv2(_delta):
	
	var right = camera.global_transform.basis.x
	var forward = Vector3.UP.cross(right)
	
	var direction = forward * motion.x + right * motion.y

	velocity = direction.normalized() *5
	#if not is_on_floor():
		#velocity -= gravity_direction * delta
	self.global_transform.origin += direction.normalized() * 0.1
	debuger.draw_line([self.global_transform.origin,self.global_transform.origin + velocity.normalized() * 10.0])
	print_debug((self.global_transform.origin-get_planet_position()).length())
	#set_velocity(velocity)
	#move_and_slide()

func locomotionv1(delta):

	#var gravity_direction = (self.global_transform.origin - get_planet_position()).normalized()

	var gravity_direction = -(get_planet_position() - self.global_transform.origin).normalized()

	set_up_direction(gravity_direction)
	
	self.global_transform.basis.y = gravity_direction
	self.global_transform.basis.x = -self.global_transform.basis.z.cross(gravity_direction)
	self.global_transform.basis = self.global_transform.basis.orthonormalized()
	
	var right = camera.global_transform.basis.x
	var forward = gravity_direction.cross(right)
	
	var direction = forward * motion.x + right * motion.y

	debuger.draw_line([self.global_transform.origin,self.global_transform.origin + direction.normalized() * 10.0])
	
	velocity = direction.normalized() * 1
	velocity -= gravity_direction * delta
	
	#self.global_transform.origin += direction.normalized() * 0.1
	
	#if not is_on_floor():
		
	#print_debug(is_on_floor())
	
	
	move_and_slide()
	#set_velocity(velocity)

	# var dot = Vector3.UP.dot(gravity_direction)

	# var rotate_quaternion = Quaternion()
	# var forward = Vector3.ZERO;
	# var right = Vector3.ZERO;

	# if dot < -0.999999:
	# 	var tmpvec3 = Vector3(1,0,0).cross(Vector3.UP)
	# 	if tmpvec3.length() < 0.000001:
	# 		tmpvec3 = Vector3(0,1,0).cross(Vector3.UP)
	# 	tmpvec3 = tmpvec3.normalized()
	# 	rotate_quaternion = Quaternion(tmpvec3.x,tmpvec3.y,tmpvec3.z,0)
	# 	forward = -Vector3.FORWARD
	# 	right = camera.global_transform.basis.x
		
	# elif dot > 0.999999:
	# 	rotate_quaternion = Quaternion(0,0,0,1)
	# 	forward = Vector3.FORWARD
	# 	right = camera.global_transform.basis.x
	
	# else :
	# 	var tmpvec3 = Vector3.UP.cross(gravity_direction)
	# 	rotate_quaternion = Quaternion(tmpvec3.x,tmpvec3.y,tmpvec3.z,1 + dot)
	# 	forward = gravity_direction.cross(-camera.global_transform.basis.x)
	# 	right = gravity_direction.cross(-camera.global_transform.basis.z)


	# self.basis = rotate_quaternion
	# var direction = forward * -motion.x #+ right * -motion.y
	# up_direction = gravity_direction
	
	
	
	#debuger.draw_line([self.global_transform.origin,self.global_transform.origin + direction*100.0])
	#print_debug(direction)
	#var pos = camera.global_transform.basis 
	#var direction = pos.z * -motion.x + pos.x * motion.y
	#
	#debuger.draw_line([self.global_transform.origin,self.global_transform.origin + direction*10.0])
	#
	#print_debug(forward)

	#velocity = direction.normalized() * 1.0

	#velocity -= gravity_direction * 0.01
	#print_debug(self.global_transform.origin)
	#move_and_slide()
#var aim = $Player.get_global_transform().basis
#var forward = -aim.z
#var backward = aim.z
#var left = -aim.x
#var right = aim.x
	#
	## Add the gravity.
	#if not is_on_floor():
		#velocity.y -= gravity * delta
#
	## Handle Jump.
	#if jump and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	#cur_speed = lerp(cur_speed, RUN_SPEED if sprint else WALK_SPEED, 0.2)
	#var target_velocity = direction * cur_speed
	#
	#velocity.x = target_velocity.x
	#velocity.z = target_velocity.z

func custom_quaternion(from:Vector3,to:Vector3)->Quaternion:
	var dot = from.dot(to)
	
	if dot < -0.999999:
		var tmpvec3 = Vector3(1,0,0).cross(from)
		if tmpvec3.length() < 0.000001:
			tmpvec3 = Vector3(0,1,0).cross(from)
		tmpvec3 = tmpvec3.normalized()
		return Quaternion(tmpvec3.x,tmpvec3.y,tmpvec3.z,0)
	
	elif dot > 0.999999:
		return Quaternion(0,0,0,1)
		
	else:
		var tmpvec3 = from.cross(to)
		return Quaternion(tmpvec3.x,tmpvec3.y,tmpvec3.z,1 + dot)

