class_name StatusEffect extends Node

var effect_ui_path = "res://objects/ui/status_effect.tscn"

var card:Card2D=null
var id:=0
var strength := 1 	#strength of the effect
var duration := 1: #length in turns (-1 for infinite)
	set(value):
		duration=value
		lifetime=duration
var lifetime := duration
var target_card:Card2D=null
var target_id

enum {
	BLOCK,
	COUNTER,
	DODGE,
	CANDIFY,
	TRANSFORM
}

signal effect_added
func _init(this_card:Card2D,this_id:int,this_duration:=1,this_strength:=1,this_target_card:=card) -> void:
	card=this_card
	id=this_id
	duration=this_duration
	strength=this_strength
	target_card=this_target_card
	target_id = target_card.inst_id
	Global.PLAYAREA.turn_ended.connect(on_turn_end)
	card.death.connect(on_card_death)
	card.hurt.connect(on_card_hurt)
	
	card.current_status_effects.append(self)
	
	match id:
		BLOCK:
			card.defense+=card.max_health
		TRANSFORM:
			var health_ratio=(card.current_health/float(card.max_health))
			if "move_1" in target_card.attributes: card.attributes["move_1"]=target_card.attributes["move_1"]
			if "move_2" in target_card.attributes: card.attributes["move_2"]=target_card.attributes["move_2"]
			card.profile_path=target_card.profile_path
			card.update_attributes()
			card.current_health=card.max_health*health_ratio
			card.atk_animator.play("effect/heal")
		CANDIFY:
			card.profile_path="candy"
			var health_ratio=(card.current_health/float(card.max_health))
			card.attributes.erase("move_1")
			card.attributes.erase("move_2")
			card.selected_move=0
			card.attributes["hp"]=40.0
			card.update_attributes()
			card.current_health=card.max_health*health_ratio
			card.atk_animator.play("effect/heal")
		DODGE:
			card.defense+=card.max_health
		_:pass
		
	effect_added.emit(id,1)
	
	var status_info = load(effect_ui_path).instantiate()
	status_info.id = id
	status_info.effect = self
	card.status_effects_box.add_child(status_info)
	
func on_turn_end(type:int):
	if (type==1 and card.owner_space.is_in_group("play_space")) || (type==0 and card.owner_space.is_in_group("opposing_space")):
		
		if duration>=0: lifetime -= 1
		
		match id:
			_:pass
		
		if lifetime<=0 and duration>=0:
			remove_effect()
			print("TURN OVER " + str(id))
	
func on_card_death():
	remove_effect()
	
func on_card_hurt(amount):
	match id:
		BLOCK:
			remove_effect()
		_:pass
	
signal effect_removed
func remove_effect():
	print("effect_removed")
	
	match id:
		BLOCK:
			card.defense-=card.max_health
		TRANSFORM:
			var health_ratio=(card.current_health/float(card.max_health))
			card.attributes=Global.DB.retrive_attributes("cards",card.id).duplicate()
			card.update_attributes()
			card.current_health=card.max_health*health_ratio
			card.atk_animator.play("effect/heal")
		CANDIFY:
			var health_ratio=(card.current_health/float(card.max_health))
			card.attributes=Global.DB.retrive_attributes("cards",card.id).duplicate()
			card.profile_path=str(card.id)
			card.update_attributes()
			if card.attributes.has("move_1") and card.owner_space.is_in_group("play_space"): card.selected_move = 1
			card.current_health=card.max_health*health_ratio
			card.atk_animator.play("effect/heal")
		DODGE:
			card.defense-=card.max_health
		_:pass
	
	effect_removed.emit(id,0)
	
	if card:
		for status_info in card.status_effects_box.get_children():
			if status_info.id == id:
				status_info.queue_free()
				continue
		
		Global.card_updated.emit(card,Card2D.EFFECT_REMOVED)
		card.current_status_effects.erase(self)
	
	queue_free()

func get_effect_info() -> Dictionary:
	var effect_info = {
		"id":id,
		"strength":strength,
		"duration":duration,
		"target_card_inst_id":target_id
	}
	return effect_info
