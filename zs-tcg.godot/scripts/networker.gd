class_name Network extends Node

const PORT = 60084
var address:="localhost"
var display_name:="PLAYER"

var peer_data_path = "res://peer_data.tscn"

var peer = ENetMultiplayerPeer.new()
var peer_count := 0
var op_id=0
enum {
	HOST,
	JOIN
}
var connection_type := -1
var timeout_timer := Timer.new()
var multiplayer_spawner := MultiplayerSpawner.new()

func _init():
	name="Network"
	Global.NETWORK = self
	Global.get_tree().root.add_child.call_deferred(self)
	timeout_timer.connect("timeout", timeout)
	add_child(timeout_timer)
	multiplayer_spawner.add_spawnable_scene(peer_data_path)
	add_child(multiplayer_spawner)
	var scene = load("res://playarea_scene.tscn").instantiate()
	scene.visible=false
	Global.get_tree().root.add_child(scene)
	Global.PLAYAREA = scene
	

func playarea_create(id):
	print(id)
	var scene = load("res://peer_data.tscn").instantiate()
	scene.name=str(id)
	return scene

#region Setup Connections
func _ready():
	multiplayer_spawner.spawn_path = ".."
	match connection_type:
		HOST:start_host()
		JOIN:start_join()
		_:
			push_warning("Network started without connection type... join(), host()")
			free()

func host():
	connection_type=HOST
func join(ip:="localhost"):
	address=ip
	connection_type=JOIN
func start_host():
	Global.start_wait()
	await get_tree().create_timer(1).timeout
	var error_check = peer.create_server(PORT,2)
	if error_check == OK: 
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(connect_player)
		multiplayer.peer_disconnected.connect(disconnect_player)
		#multiplayer.server_disconnected.connect(disconnect_server)		
		connect_player()
		upnp_setup()
	else:
		printerr("Server Fail!")
		multiplayer.multiplayer_peer.close()
		Global.return_to_title()

func connect_player(id=1):#when anyone connects to host
	var scene = load("res://peer_data.tscn").instantiate()
	scene.name = str(id)
	call_deferred("add_child", scene)
	if multiplayer.get_peers().size() >= 1: #When another player connects
		Global.stop_wait()
		print("Opponnent Found!: %s" % id)
		op_id=id

func disconnect_player(id):#when opponent leaves
	rpc("_disconnect_player", id)
@rpc("any_peer", "call_local") func _disconnect_player(id):
	printerr("Opponnent Left!")
	Global.return_to_title()
	
@rpc("any_peer", "call_local") func disconnect_server():#when host leaves
	printerr("Host Left!")
	Global.return_to_title()

func start_join():
	timeout_timer.start(10)
	Global.start_wait()
	await get_tree().create_timer(0.75).timeout
	var error_check = peer.create_client(address, PORT)
	if error_check == OK:
		multiplayer.multiplayer_peer = peer
		await multiplayer.peer_connected
		multiplayer.server_disconnected.connect(disconnect_server)
		op_id=1
		#multiplayer.peer_connected.connect(connect_player)
		#multiplayer.peer_disconnected.connect(disconnect_player)
	else:
		printerr("Connection Fail!")
		timeout_timer.stop()
		Global.return_to_title()

func upnp_setup():
	var upnp = UPNP.new()
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover failed! Error %s" % discover_result)
	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP Invalid Gateway!")
	var map_result = upnp.add_port_mapping(PORT)
	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP Port Mapping Failed! Error %s" % map_result)
	address = upnp.query_external_address()
	print("Success! Host Adress: %s" % address)

func timeout():#when no address is found
	Global.return_to_title()
	printerr("Connection Timed out!")
	
func _exit_tree():#disconnect when leaving game
	multiplayer.multiplayer_peer.close()
#endregion
