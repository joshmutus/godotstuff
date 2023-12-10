extends CharacterBody2D

var wheel_base = 70
var steering_angle = 15
var engine_power = 800
var friction = -0.6
var drag = -0.001
var braking = -450
var max_speed_reverse = 250
var slip_speed = 400
var traction_fast = 0.0
var traction_slow = 0.8
var steer_direction
var acceleration = Vector2.ZERO

var surfaces = {0: "grass", 1: "asphalt", 2: "dirt", 3: "mud"}


func _process(delta):
	acceleration = Vector2.ZERO
	get_input()
	apply_friction()
	print("velocity, ", velocity.length())
	calculate_steering(delta)
	velocity += acceleration * delta
	move_and_slide()


func apply_friction():
	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		print(col.get_collider().name)
	if velocity.length() < 10:
		velocity = Vector2.ZERO
	var friction_force = velocity * friction
	var drag_force = velocity * velocity.length() * drag
	acceleration += drag_force + friction_force


func get_input():
	var turn = 0
	if Input.is_action_pressed("steer_right"):
		turn += 1
	if Input.is_action_pressed("steer_left"):
		turn -= 1

	steer_direction = turn * deg_to_rad(steering_angle)

	if Input.is_action_pressed("gas"):
		velocity = transform.x * engine_power
	if Input.is_action_pressed("brake"):
		acceleration = transform.x * braking


func lin_interp(num1, num2):
	return (num1 + num2) / 2


func calculate_steering(delta):
	var rear_wheel = position - transform.x * wheel_base / 2
	var front_wheel = position + transform.x * wheel_base / 2
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	var new_heading = (front_wheel - rear_wheel).normalized()
	var traction = traction_slow
	%fw_rect.color = Color(1.0, 1.0, 1.0, 1.0)
	if velocity.length() > slip_speed:
		%fw_rect.color = Color(1.0, 0.0, 0.0, 1.0)
		traction = traction_fast
		print("slipping traction: ", traction)
	var d = new_heading.dot(velocity.normalized())
	if d > 0:
		# velocity = new_heading*velocity.length()
		velocity = velocity.lerp(new_heading * velocity.length(), traction)
		print(rad_to_deg(new_heading.angle()), new_heading * velocity.length() - velocity)
	if d < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)
	rotation = new_heading.angle()


func _ready():
	pass  # Replace with function body.
