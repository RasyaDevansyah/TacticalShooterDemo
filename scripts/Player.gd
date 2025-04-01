extends CharacterBody3D


@export var speed = 5.0
@export var cam : Node3D
@export var spring : SpringArm3D
@export var cam_speed : float = 0.001
@export var cam_rotation_amount : float = 0.07

@export var lean_length : float = 0.9
@export var cam_lean_left : float = 0.14
@export var cam_lean_right : float = 0.14
@export var weapon_lean_left : float = 0.014
@export var weapon_lean_right : float = 0.014

@export var weapon_holder : Node3D
@export var weapon_sway_amount : float = 0.01
@export var weapon_rotation_amount : float = 0.007

@export var footstepsSFX : AudioStreamPlayer


var mouse_input : Vector2
const JUMP_VELOCITY = 4.5
var def_weapon_holder_pos : Vector3

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	footstepsSFX.play()
	def_weapon_holder_pos = weapon_holder.position
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event):
	if !cam:
		return
	if event is InputEventMouseMotion:
		cam.rotation.x -= event.relative.y * cam_speed
		cam.rotation.x = clamp(cam.rotation.x, -1.25, 1.5)
		self.rotation.y -= event.relative.x * cam_speed
		mouse_input = event.relative


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
	
	if Input.is_action_pressed("leanLeft"):
		cam_tilt(-1, cam_lean_left, -lean_length,  delta)
		weapon_tilt(-1, weapon_lean_left, delta)
	elif Input.is_action_pressed("leanRight"):
		cam_tilt(1, cam_lean_right, lean_length , delta)
		weapon_tilt(1, weapon_lean_right, delta)
	else:
		cam_tilt(input_dir.x, cam_rotation_amount, float(0), delta)
		weapon_tilt(input_dir.x, weapon_rotation_amount, delta)
	
	
	footsteps(velocity.length())
	weapon_sway(delta)
	weapon_bob(velocity.length(), delta)

func footsteps(vel):
	if vel:
		footstepsSFX.stream_paused = false
	else:
		footstepsSFX.stream_paused = true
		
	

func cam_tilt(input_x, rot, spring_length, delta):
	if cam:
		cam.rotation.z = lerp(cam.rotation.z, -input_x * rot, 10 * delta)
	if spring:
		spring.spring_length = lerp(spring.spring_length, spring_length, 10 * delta)

func weapon_tilt(input_x, rot,  delta):
	if weapon_holder:
		weapon_holder.rotation.z = lerp(weapon_holder.rotation.z, -input_x * rot * 10, 10 * delta)

func weapon_sway(delta):
	mouse_input = lerp(mouse_input, Vector2.ZERO, 10 * delta)
	weapon_holder.rotation.x = lerp(weapon_holder.rotation.x, mouse_input.y * weapon_rotation_amount, 10 * delta)
	weapon_holder.rotation.y = lerp(weapon_holder.rotation.y, mouse_input.x * weapon_rotation_amount, 10 * delta)

func weapon_bob(vel : float, delta):
	if weapon_holder:
		if vel > 0:
			var bob_amount : float = 0.01
			var bob_freq : float = 0.01
			weapon_holder.position.y = lerp(weapon_holder.position.y, def_weapon_holder_pos.y + sin(Time.get_ticks_msec() * bob_freq) * bob_amount, 10 * delta)
			weapon_holder.position.x = lerp(weapon_holder.position.x, def_weapon_holder_pos.x + sin(Time.get_ticks_msec() * bob_freq * 0.5) * bob_amount, 10 * delta)
		else:
			weapon_holder.position.y = lerp(weapon_holder.position.y, def_weapon_holder_pos.y, 10 * delta)
			weapon_holder.position.x = lerp(weapon_holder.position.x, def_weapon_holder_pos.x, 10 * delta)
