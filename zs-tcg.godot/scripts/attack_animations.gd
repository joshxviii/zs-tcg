@tool
extends AnimationPlayer

var target_position := Vector2.ZERO

@export var particle : PackedScene:
	set(value):
		particle = value
		play_particle()


func _on_animation_started(anim_name):
	#print(anim_name)
	#print("end")
	pass


func play_particle():
	if particle && current_animation != "":
		print("create_particle")
		var particle_inst = particle.instantiate()
		particle_inst.emitting = true
		add_child(particle_inst)
		particle_inst.rotation = get_parent().global_position.angle_to_point(target_position)
		particle_inst.position = get_parent().position
		
		await animation_finished
		particle_inst.queue_free()
