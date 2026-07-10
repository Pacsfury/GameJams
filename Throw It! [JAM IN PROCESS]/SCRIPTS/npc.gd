extends CharacterBody2D

var is_dragging: bool = false
var mouse_offset: Vector2 = Vector2.ZERO
const SPEED := 200.0

var direction: float = 1.0

var idle_timer: Timer

@onready var globalcamera: Camera2D = %globalcam
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var game: Node = %"Game Manager"
@onready var HUD: Control = %HUD

enum types {npc, bomb}
@export var type = types.npc

@export var gravity: float = 980.0
@export var bounciness: float = 0.6 

func _ready() -> void:
	idle_timer = Timer.new()
	idle_timer.wait_time = 40.0
	idle_timer.one_shot = true
	idle_timer.autostart = true
	
	idle_timer.timeout.connect(func(): 
		HUD.get_node("CanvasLayer/surr").show()
		if is_in_group("npcs"):
			self.queue_free()
		
	)
	
	add_child(idle_timer)

func _physics_process(delta: float) -> void:
	if is_dragging:
		var target_position = get_global_mouse_position() - mouse_offset
		velocity = (target_position - global_position) / delta
		
		set_collision_layer_value(1, false)
		set_collision_layer_value(2, true)
		set_collision_mask_value(1, false)
		set_collision_mask_value(2, true)
	else:
		set_collision_layer_value(1, true)
		set_collision_layer_value(2, false)
		set_collision_mask_value(1, true)
		set_collision_mask_value(2, false)
		
		if not is_on_floor():
			velocity.y += gravity * delta
		
		if abs(velocity.x) < SPEED:
			velocity.x = direction * SPEED
	
	_update_animations()
	
	move_and_slide()
	
	if not is_dragging:
		var collision_count = get_slide_collision_count()
		for i in collision_count:
			var collision = get_slide_collision(i)
			var normal = collision.get_normal()
			
			if collision.get_normal().x != 0:
				direction = sign(normal.x)
				velocity.x = normal.x * SPEED * (1.0 + bounciness)
			
			if collision.get_normal().y != 0:
				if normal.y > 0 or abs(velocity.y) > 50:
					velocity.y = normal.y * abs(velocity.y) * bounciness
			
			var touching: bool = false
			if normal.y > -0.7 and not touching and not is_on_floor(): 
				if self.type == types.npc:
					game.add_points(1 * game.mult)
				if self.type == types.bomb:
					game.add_points(-1 * game.mult)
				touching = true
				if game.points + 0.0 / game.mult > 9999:
					game.mult += 1
					HUD.update_mult()

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
			
			if idle_timer and not idle_timer.is_stopped():
				idle_timer.stop()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_released():
			if is_dragging:
				is_dragging = false
				
				velocity = velocity.limit_length(1500)
				
				if velocity.x != 0:
					direction = sign(velocity.x)
				
				if idle_timer:
					idle_timer.start()
