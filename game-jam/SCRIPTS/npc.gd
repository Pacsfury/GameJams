extends CharacterBody2D

var is_dragging: bool = false
var mouse_offset: Vector2 = Vector2.ZERO
const SPEED := 200.0

var direction: float = 1.0

@onready var globalcamera: Camera2D = %globalcam
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var game: Node = %"Game Manager"
@onready var HUD: Control = %HUD

enum types {npc, bomb}
@export var type = types.npc

@export var gravity: float = 980.0
@export var friction: float = 2.0

func _physics_process(delta: float) -> void:
	if is_dragging:
		var target_position = get_global_mouse_position() - mouse_offset
		velocity = (target_position - global_position) / delta
		self.collision_mask = 2
	else:
		self.collision_mask = 1
		if not is_on_floor():
			velocity.y += gravity * delta
		else:
			if is_on_wall():
				direction = -direction
		
		velocity.x = direction * SPEED
	
	_update_animations()
	
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var normal = collision.get_normal()
		var touching: bool = false
		
		if normal.y > -0.7 and (touching == false) and not is_on_floor() and not is_dragging: 
			if self.type == types.npc:
				game.add_points(1 * game.mult)
			if self.type == types.bomb:
				game.add_points(-1 * game.mult)
			touching = true
			if game.points +0.0 / game.mult > 9999:
				game.mult += 1
				HUD.update_mult()
			
		elif not normal.y > -0.7:
			touching = false

func _update_animations() -> void:
	if velocity.x > 0:
		sprite.flip_h = false  
	elif velocity.x < 0:
		sprite.flip_h = true  
		
	if is_dragging:
		sprite.play("mid")
	elif not is_on_floor():
		sprite.play("mid")
	else:
		sprite.play("move")

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			is_dragging = true
			mouse_offset = get_global_mouse_position() - global_position
			velocity = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_released():
			if is_dragging:
				is_dragging = false
				velocity = velocity.limit_length(1500)
