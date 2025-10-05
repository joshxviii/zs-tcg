@tool
extends Button

@onready var profile_icon : Sprite2D = $icon/profile
@onready var profile_bg : Sprite2D = $icon/card_bg
@onready var profile_border : Sprite2D = $icon/card_border
@onready var amount_text : Label = $amount_text
@onready var name_text : Label = $name
@onready var lock : ColorRect = $icon/locked

const max_id := 299
const max_pack_id := 24

@export var locked := true:
	set(value):
		locked=value
		if locked:
			lock.visible = true
			disabled = true
			mouse_filter=Control.MOUSE_FILTER_IGNORE
			item_name = "LOCKED"
		else:
			lock.visible = false
			disabled = false
			mouse_filter=Control.MOUSE_FILTER_STOP

@export var deck_item:= false:
	set(value):
		deck_item=value
		if deck_item:
			modulate = Color.WHITE
			locked=false

@export var item_name : String = "LOCKED":
	set(value):
		item_name=value
		name_text.text = item_name

@export var amount := 0:
	set(value):
		if value<1:
			amount=0
			amount_text.visible = false
			modulate = Color.WEB_GRAY
			release_focus()
		else:
			amount=value
			amount_text.visible = true
			modulate = Color.WHITE
		amount_text.text = "x" + str(amount)
@export var pack_id := 0:
	set(value):
		if value<=0: pack_id = 0
		elif value>max_pack_id: pack_id = max_pack_id
		else: pack_id=value
		profile_bg.frame = pack_id
		profile_border.frame = pack_id

@export var id := 0:
	set(value):
		if value<=0: id = 0
		elif value>max_id: id = max_id
		else: id=value
		profile_icon.frame = id

func _ready() -> void:
	profile_icon.offset = Vector2(6,8)
	profile_bg.offset = Vector2(6,8)
	profile_border.offset = Vector2(6,8)
	profile_icon.hframes = max_id
	profile_bg.hframes = max_pack_id
	profile_border.hframes = max_pack_id
