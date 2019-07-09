extends Node

signal update_lobby(player_info)

func start_server(port):
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(port, 4)
	get_tree().set_network_peer(peer)


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

# Player info, associate ID to data
var player_info = {}
# Info we send to other players
var my_info = { user_name = "server", color = Color8(255, 0, 0) }

func _player_connected(_id):
	pass

func _player_disconnected(id):
	player_info.erase(id) # Erase player from info.
	emit_signal("update_lobby", player_info)

func _connected_ok():
	# Only called on clients, not server. Send my ID and info to all the other peers.
	print("client successfully connected. Detected network peers: ", get_tree().get_network_connected_peers())
	rpc("register_player", get_tree().get_network_unique_id(), my_info)

func _server_disconnected():
	pass # Server kicked us; show error and abort.

func _connected_fail():
	pass # Could not even connect to server; abort.

remote func register_player(id, info):
	# Store the info
	player_info[id] = info
	# If I'm the server, let the new guy know about existing players.
	if get_tree().is_network_server():
		# Send my info to new player
		rpc_id(id, "register_player", 1, my_info)
		# Send the info of existing players
		for peer_id in player_info:
			rpc_id(id, "register_player", peer_id, player_info[peer_id])

	# Call function to update lobby UI here
	emit_signal("update_lobby", player_info)

remotesync func update_player_info(id, info):
	print("receiving newly updated data... connected ids: ", get_tree().get_network_connected_peers())
	player_info[id] = info
	emit_signal("update_lobby", player_info)
