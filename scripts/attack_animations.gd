@tool
extends AnimationPlayer

var target_rot := Vector2.RIGHT

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
		var particle_inst = particle.instantiate()
		particle_inst.emitting = true
		get_child(0).add_child(particle_inst)
		particle_inst.rotation = target_rot.angle()
		particle_inst.position = get_parent().position
		
		await animation_finished
		particle_inst.queue_free()
