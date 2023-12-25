extends CharacterBody3D

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	handle_input()


func _physics_process(delta):
	locomotion(delta)


func _input(event):
	if event is InputEventMouseMotion:
		var camera_speed_this_frame = CAMERA_MOUSE_ROTATION_SPEED
		rotate_camera(event.relative * camera_speed_this_frame)


func locomotion(delta):
	#var pos = camera_base.get_global_transform().basis 
	var pos = camera.global_transform.basis 
	var direction = pos.z * -motion.x + pos.x * motion.y
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if jump and is_on_floor():
		velocity.y = JUMP_VELOCITY

	cur_speed = lerp(cur_speed, RUN_SPEED if sprint else WALK_SPEED, 0.2)
	var target_velocity = direction * cur_speed
	
	velocity.x = target_velocity.x
	velocity.z = target_velocity.z
	
	move_and_slide()


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
		camera_rot.rotation.x - move.y, CAMERA_X_ROT_MIN, CAMERA_X_ROT_MAX
	)
