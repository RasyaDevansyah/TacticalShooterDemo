extends CharacterBody3D


@export var speed = 5.0
@export var camera : Camera3D
@export var cam_speed : float = 5
@export var cam_rotation_amount : float = 1

var mouse_input : Vector2
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _input(event):
	if !camera:
		return
	if event is InputEventMouseMotion:
		camera.rotation.x -= event.relative.y * cam_speed
		camera.rotation.x = clamp(camera.rotation.x, -1.25, 1.5)
		self.rotation.y -= event.relative.x * cam_speed
		mouse_input = event.relative

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
