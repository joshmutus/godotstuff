extends CharacterBody2D

var wheel_base = 70
var steering_angle = 15
var engine_power = 800
var friction = -0.6
var drag = -0.001
var braking = -450
var max_speed_reverse = 250
var slip_speed = 400
var traction_fast = 0.2
var traction_slow = 0.8
var steer_direction
var acceleration = Vector2.ZERO


func _process(delta):
	acceleration = Vector2.ZERO
	get_input()
	apply_friction()
	calculate_steering(delta)
	velocity += acceleration * delta

	move_and_slide()


func apply_friction():
	# for i in get_slide_collision_count():
	# 	var col = get_slide_collision(i)
	# 	print("collision with: ", col.get_property_list())
	if velocity.length() < 5:
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
	# %fw_rect.
	%fw_rect.pivot_offset = %fw_rect.size / 2
	%fw_rect.rotation = steer_direction

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
		# print("slipping traction: ", traction)
	var d = new_heading.dot(velocity.normalized())
	if d > 0:
		# velocity = new_heading*velocity.length()
		velocity = velocity.lerp(new_heading * velocity.length(), traction)
		# print(rad_to_deg(new_heading.angle()), new_heading * velocity.length() - velocity)
	if d < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)
	rotation = new_heading.angle()

func _on_area_entered():
	print("foo")

func _physics_process(delta):
	pass
	# var default_2d_navigation_map_rid: RID = get_world_2d().get_navigation_map()
	# if Input.is_action_pressed("world"):
		# # var space_state = get_world_2d().direct_space_state
		# print(position, position-Vector2(1,1))
		# # use global coordinates, not local to node
		# var query = PhysicsRayQueryParameters2D.create(Vector2(1,1), position)
		# var result = space_state.intersect_ray(query)
		# var coll = result["collider"]
		# print(coll.name, coll.get_type())
		# breakpoint


func _ready():
	pass  # Replace with function body.


func _on_car_area_area_shape_entered(area_rid:RID, area:Area2D, area_shape_index:int, local_shape_index:int):
	print("entered?")