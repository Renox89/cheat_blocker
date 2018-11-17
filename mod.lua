Hooks:PostHook(NetworkPeer, "set_ip_verified", "Cheat_Blocker", function(self, state)

local NOSALOBBY_is_server_ok = NetworkMatchMakingSTEAM.is_server_ok
function NetworkMatchMakingSTEAM:is_server_ok(friends_only, room, attributes_list, ...)
	if attributes_list.numbers[11] ~= "value_pending" then
		return false
	end
	return NOSALOBBY_is_server_ok(self, friends_only, room, attributes_list, ...)
end

local NOSALOBBY_lobby_to_numbers = NetworkMatchMakingSTEAM._lobby_to_numbers
function NetworkMatchMakingSTEAM._lobby_to_numbers(self, lobby, ...)
	local numbers = NOSALOBBY_lobby_to_numbers(self, lobby, ...)
	table.insert(numbers, lobby:key_value("silent_assassin"))
	return numbers
end

	if not Network:is_server() then
		return
	end

	DelayedCalls:Add( "Cheat_Blocker_caller", 2, function()
		local user = Steam:user(self:ip())
		if user and user:rich_presence("is_modded") == "1" or self:is_modded() then
			managers.chat:feed_system_message(1, self:name() .. " HAS MODS! Checking...")
			for i, mod in ipairs(self:synced_mods()) do
				local mod_mini = string.lower(mod.name)	
				local kick_on = {}
				local questionable = {}
				local suspicious = nil

				kick_on = {
					"pirate perfection",
					"p3dhack",
					"p3dhack free",
					"dlc unlocker",
					"skin unlocker",
					"p3dunlocker",
					"arsium's weapons rebalance recoil",
					"overkill mod",
					"silent assassin",
					"carry stacker",
					"selective dlc unlocker",
					"the great skin unlock",
					"beyond cheats"
				}

				for _, v in pairs(kick_on) do
					if mod_mini == v then
						local identifier = "cheater_banned_" .. tostring(self:id())
						managers.ban_list:ban(identifier, self:name())
						managers.chat:feed_system_message(1, self:name() .. " has been kicked because of using the mod: " .. mod.name)
						local message_id = 0
						message_id = 6
						managers.network:session():send_to_peers("kick_peer", self:id(), message_id)
						managers.network:session():on_peer_kicked(self, self:id(), message_id)
						return
					end
				end

				questionable = {
					"pirate",
					"p3d",
					"hack",
					"cheat",
					"invisible",
					"dmg",
					"damage",
					"unlocker",
					"unlock",
					"dlc",
					"trainer",
					"sa",
					"skill",
					"carry stacker",
					"god",
					"x-ray",
					"mvp"
				}

				for k, pc in pairs(questionable) do
					if string.find(mod_mini, pc) then
						log("found something!")
						managers.chat:feed_system_message(1, self:name() .. " is using a mod that can be a potential cheating mod: " .. mod.name)
						suspicious = 1
					end
				end
			end

			if suspicious then
				managers.chat:feed_system_message(1, self:name() .. " has a warning... Check his mods/profile manually to be sure.")
			else
				managers.chat:feed_system_message(1, self:name() .. " seems to be clean.")
			end
		else
			managers.chat:feed_system_message(1, self:name() .. " doesn't seem to have mods.")
		end
	end)
end)