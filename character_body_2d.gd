extends CharacterBody2D

var spawn_points : Array

@export var SPEED: int = 15000
@export var JUMP_VELOCITY: int = 900
@export var TERMINAL_VELOCITY: int = 5000
@export var GRAVITY: int = 3000
@onready var sprite: Sprite2D = $Sprite2D
@onready var idle_texture: Texture = sprite.texture
@onready var walk_animation: AnimationPlayer = $WalkAnimation
@onready var teleport_animation: AnimationPlayer = $TeleportAnimation
@onready var jump_audio: AudioStreamPlayer = $JumpAudio

var max_coyote_time: float = 0.15
var coyote_time: float = max_coyote_time # Represents seconds after touching ground in which the player can jump without using double jump
# Think of coyote time as when coyote walks off ledge in looney tunes and doesn't fall for a bit
var can_move: bool = true
var can_fall: bool = true
var double_jump_active: bool = true

func jump() -> void:
	velocity.y = -JUMP_VELOCITY
	jump_audio.play()

func animation_check():
	# Check for input. If there is an input, play walk animation
	if (Input.is_action_pressed("Left") or Input.is_action_pressed("Right")) and can_move:
		if !walk_animation.is_playing():
			walk_animation.play("Walk")
	# If all other checks failed, stop animation
	elif walk_animation.is_playing():
		walk_animation.stop()

func teleport():
	can_fall = false
	var point: Marker2D = spawn_points.pick_random() # Find random teleportation spot
	teleport_animation.play("portalopen")
	await teleport_animation.animation_finished # Wait for first animation
	position = point.position
	teleport_animation.play("portalclose")
	await teleport_animation.animation_finished # Wait for second animation
	can_fall = true
	return # Allow async calls

# Runs every frame
func _physics_process(delta: float) -> void:
	animation_check()
	if !is_on_floor():
		if coyote_time > 0:
			coyote_time -= delta # Stores how much time is left for player to jump
		if velocity.y < TERMINAL_VELOCITY and can_fall:
			#GET Y VELOCITY
			velocity.y += GRAVITY * delta
	else:
		coyote_time = max_coyote_time
		double_jump_active = true
		
	if can_move:
		# Allow jump if the player is grounded, coyote time not done
		if Input.is_action_just_pressed("Jump"):
			if is_on_floor() or coyote_time > 0:
				jump()
			elif double_jump_active:
				jump()
				double_jump_active = false
			
		#GET X VELOCITY
		if Input.is_action_pressed("Left"):
			velocity.x = -SPEED * delta
			sprite.scale.x = abs(sprite.scale.x) * -1 # Set the x scale of the sprite to negative to make sprite move in correct direction
		elif Input.is_action_pressed("Right"):
			velocity.x = SPEED * delta
			sprite.scale.x = abs(sprite.scale.x)
		else:
			velocity.x = 0
	
	else: # IF THE PLAYER CANNOT MOVE, X VELOCITY IS 0
		velocity.x = 0
	move_and_slide()
	
func _ready() -> void:
	spawn_points = get_tree().get_nodes_in_group("SpawnPoint")
	sprite.visible = true # Fixing weird glitch where sprite stays invisible
