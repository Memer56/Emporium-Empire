extends Node

func change_player_state(new_state : String):
	EventBus.cheat_command_entered = true
	match new_state:
		"FLY":
			EventBus.current_player_state = EventBus.player_state.FLY
			EventBus.cheat_command_entered = true
		"NORMAL":
			EventBus.current_player_state = EventBus.player_state.NORMAL
			EventBus.cheat_command_entered = false
