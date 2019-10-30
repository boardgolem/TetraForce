extends Entity

var movetimer_length = 100
var movetimer = 0

puppet var puppet_pos = position
puppet var puppet_spritedir = spritedir
puppet var puppet_anim = "idleDown"

func _ready():
	movedir = entity_helper.rand_direction()
	connect("update_position", self, "_on_update_position")
	connect("update_spritedir", self, "_on_update_spritedir")
	connect("update_animation", self, "_on_update_animation")

func _physics_process(delta):
	if !is_scene_owner():
		return
	
	loop_movement()
	loop_damage()
	loop_spritedir()
	
	if movetimer > 50:
		anim_switch("walk")
	else:
		movedir = Vector2.ZERO
		anim_switch("idle")
	
	if movetimer > 0:
		movetimer -= 1
	if (movetimer == 0 || is_on_wall()) && hitstun == 0:
		movedir = entity_helper.rand_direction()
		movetimer = movetimer_length
	
	if movetimer == 25:
		use_item("res://items/arrow.tscn", "A")
		for peer in network.map_peers:
			rpc_id(peer, "use_item", "res://items/arrow.tscn", "A")

func _on_update_position(value):
	rset_map("puppet_pos", value)

func _on_update_spritedir(value):
	rset_map("puppet_spritedir", value)

func _on_update_animation(value):
	rset_map("puppet_anim", value)

func puppet_update():
	position = puppet_pos
	spritedir = puppet_spritedir
	if anim.current_animation != puppet_anim:
		anim.play(puppet_anim)
	sprite.flip_h = (spritedir == "Left")

func _process(delta):
	loop_network()
