@tool
extends AnimationPlayer

@export var particle : PackedScene:
	set(value):
		particle = value
		play_particle()


func _on_animation_started(anim_name):
	print(anim_name)
	print("end")


func play_particle():
	if particle && current_animation != "":
		print("create_particle")
		var particle_inst = particle.instantiate()
		particle_inst.emitting = true
		add_child(particle_inst)
		await animation_finished
		particle_inst.queue_free()
