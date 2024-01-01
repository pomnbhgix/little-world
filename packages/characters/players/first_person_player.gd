extends RigidBody3D

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

# Called when the node enters the scene tree for the first time.
func _process(_delta):
	handle_input()

func _input(event):
	if event is InputEventMouseMotion:
		var camera_speed_this_frame = CAMERA_MOUSE_ROTATION_SPEED
		rotate_camera(event.relative * camera_speed_this_frame)

func _physics_process(delta):
	locomotion(delta)
	
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

func locomotion(delta):
	
	var gravity_direction = -(get_planet_position() - self.global_transform.origin).normalized()

	self.global_transform.basis.y = gravity_direction
	self.global_transform.basis.x = -self.global_transform.basis.z.cross(gravity_direction)
	self.global_transform.basis = self.global_transform.basis.orthonormalized()
	
	var right = camera.global_transform.basis.x
	var forward = Vector3.UP.cross(right)
	var direction = forward * motion.x + right * motion.y
	
	direction -= gravity_direction * delta;
	
	debuger.draw_line([self.global_transform.origin,self.global_transform.origin + direction.normalized() * 10.0])
	print_debug(direction)
	add_constant_force(direction.normalized()* 0.01)

func get_planet_position():
	if planet:
		return planet.global_transform.origin
	else:
		return Vector3.ZERO
