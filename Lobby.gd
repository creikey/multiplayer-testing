extends Node

signal update_lobby(player_info, my_info)

# Player info, associate ID to data
var player_info = {}
# Info we send to other players
var my_info = { user_name = "server", color = Color8(255, 0, 0) }

var upnp: UPNP = null
var forwarded_port = -1

func start_server(port):
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(port, 4)
	get_tree().set_network_peer(peer)

#func _process(delta):
#	print(player_info)

func join_server(port, ip):
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, port)
	get_tree().set_network_peer(peer)

# Connect all functions

func _ready():
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_player_connected")
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "_connected_ok")
# warning-ignore:return_value_discarded
	get_tree().connect("connection_failed", self, "_connected_fail")
# warning-ignore:return_value_discarded
	get_tree().connect("server_disconnected", self, "_server_disconnected")
# warning-ignore:return_value_discarded
	connect("tree_exiting", self, "_on_tree_exiting")

func _on_tree_exiting():
	if upnp != null:
# warning-ignore:return_value_discarded
		upnp.delete_port_mapping(forwarded_port)

func _player_connected(id):
	var my_id = get_tree().get_network_unique_id()
	# tell new player about myself
	rpc_id(id, "register_player", my_id, my_info)
	emit_signal("update_lobby", player_info, my_info)

func _player_disconnected(id):
	player_info.erase(id) # Erase player from info.
	emit_signal("update_lobby", player_info, my_info)

func _connected_ok():
	# Only called on clients, not server.
	print("connected ok")

func _server_disconnected():
	print("Server disconnected")
	pass # Server kicked us; show error and abort.

func _connected_fail():
	print("Failed to connect")
	pass # Could not even connect to server; abort.

remote func register_player(id, info):
	# Store the info
	player_info[id] = info
	# Call function to update lobby UI here
	emit_signal("update_lobby", player_info, my_info)

remotesync func preconfigure_game():
	var my_peer_id = get_tree().get_network_unique_id()
	var world = load("res://World.tscn").instance()
	get_node("/root").add_child(world)
	
	var player_pack = preload("res://Player.tscn")
	var my_player = player_pack.instance()
	my_player.set_name(str(my_peer_id))
	my_player.set_network_master(my_peer_id)
	my_player.get_node("ColorRect").color = my_info["color"]
	my_player.get_node("NametagLabel").text = my_info["user_name"]
	get_node("/root/World/Players").add_child(my_player)
	
	for p in player_info:
		var cur_player = player_pack.instance()
		cur_player.set_name(str(p))
		cur_player.set_network_master(p)
		cur_player.get_node("ColorRect").color = player_info[p]["color"]
		cur_player.get_node("NametagLabel").text = player_info[p]["user_name"]
		get_node("/root/World/Players").add_child(cur_player)
	
	get_node("/root/LobbyScene").queue_free()
	rpc_id(1, "done_preconfiguring", my_peer_id)

var players_done = []
remote func done_preconfiguring(who):
	assert(get_tree().is_network_server())
	assert(who in player_info)
	assert(not who in players_done)
	
	players_done.append(who)
	
	if players_done.size() == player_info.size() + 1: # account for server
		rpc("post_configure_game")

remote func post_configure_game():
	pass
	
