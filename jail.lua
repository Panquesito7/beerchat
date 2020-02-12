-- Jail channel is where you put annoying missbehaving users with /force2channel
beerchat.jail_channel_name = minetest.settings:get("beerchat.jail_channel_name") or "grounded"
beerchat.jail_channel_name = beerchat.jail_channel_name or "grounded"

beerchat.channels[beerchat.jail_channel_name] = {
	owner = main_channel_owner,
	color = main_channel_color
}

beerchat.jail_list = {}

beerchat.is_player_jailed = function(name)
	return true == beerchat.jail_list[name]
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	local meta = player:get_meta()

	local jailed = 1 == meta:get_int("beerchat:jailed")
	if jailed then
		beerchat.jail_list[name] = true
		beerchat.currentPlayerChannel[name] = beerchat.jail_channel_name
		beerchat.playersChannels[name][beerchat.jail_channel_name] = "joined"
	else
		beerchat.jail_list[name] = nil
	end

end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	beerchat.jail_list[name] = nil
end)

beerchat.register_callback('before_invite', function(sender, recipient, channel)
	if beerchat.is_player_jailed(player_name) then
		return false, player_name .. " is in chat-jail, no inviting."
	end
end)

beerchat.register_callback('before_mute', function(name, target)
	if beerchat.is_player_jailed(name) then
		return false, "You are in chat-jail, no muting for you."
	end
end)

beerchat.register_callback('before_join', function(name, channel)
	if beerchat.is_player_jailed(name) then
		return false, "You are in chat-jail, no joining channels for you."
	end
end)

beerchat.register_callback('before_leave', function(name, channel)
	if beerchat.is_player_jailed(name) then
		return false, "You are in chat-jail, no leaving for you."
	end
end)

beerchat.register_callback('before_send', function(name, message, channel)
	local jailed = beerchat.is_player_jailed(name)
	local is_jail_channel = channel == beerchat.jail_channel_name
	if jailed and not is_jail_channel then
		-- override default send method to mute pings for jailed users
		minetest.chat_send_player(name, message)
		return false
	end
end)

beerchat.register_callback('before_send_pm', function(name, message, target)
	if beerchat.is_player_jailed(name) then
		return false, "You are in chat-jail, no PMs for you."
	end
end)

beerchat.register_callback('before_send_me', function(name, message, channel)
	if beerchat.is_player_jailed(name) then
		return false, "You are in chat-jail, you may not use /me command."
	end
end)

beerchat.register_callback('before_whisper', function(name, message, channel, range)
	if beerchat.is_player_jailed(name) then
		return false
	end
end)

beerchat.register_callback('before_check_muted', function(name, muted)
	if beerchat.is_player_jailed(name) then
		return false
	end
end)

beerchat.register_callback('on_forced_join', function(name, target, channel, target_meta)
	-- going to/from jail?
	if channel == beerchat.jail_channel_name then
		target_meta:set_int("beerchat:jailed", 1)
		beerchat.jail_list[target] = true
	elseif beerchat.is_player_jailed(target) then
		target_meta:set_int("beerchat:jailed", 0)
		beerchat.jail_list[target] = nil
	end
end)
