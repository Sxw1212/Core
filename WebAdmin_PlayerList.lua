function WebAdmin_PlayerList(Request)
	local Content = ""
	local ExcludePlayer = ""
	local Connected_Players = cRoot:Get():GetServer():GetNumPlayers()
	if Request.PostParams["KickPlayer"] ~= nil and Request.PostParams["PlayerName"] ~= nil then
		local PlayerName = Request.PostParams["PlayerName"]
		ExcludePlayer = PlayerName
		Connected_Players = Connected_Players - 1
		cRoot:Get():ForEachWorld(
			function(World)
				World:QueueTask(
					function(a_World)
						a_World:DoWithPlayer(PlayerName,
							function(Player)
								if Player:GetName() == PlayerName then
									Player:GetClientHandle():Kick("You were kicked from the game!")
								end
							end
						)
					end
				)
			end
		)
	end
	Content = Content .. [[
		Connected Players: <b>]] .. Connected_Players .. [[</b>
		<table>
			<tr>
				<td>Player</td>
				<td>World</td>
				<td>Kick</td>
			</tr>]]
	cRoot:Get():ForEachPlayer(function(Player)
		local PlayerName = Player:GetName()
		if ExcludePlayer ~= PlayerName then
			Content = Content .. [[
			<tr>
				<td>]] .. PlayerName .. [[</td>
				<td>]] .. Player:GetWorld():GetName() .. [[</td>
				<td><form method="POST"><input type="hidden" name="PlayerName" value="]].. PlayerName ..[["><input type="submit" name="KickPlayer" value="Kick"></form></td>
			</tr>]]
		end
	end)
	Content = Content .. [[
		</table>
		<META HTTP-EQUIV="refresh" CONTENT="3">]]
	return Content
	
end