RocketChat.isApprovalRequired = (rid) ->
	room = RocketChat.models.Rooms.findOneById(rid)
	unless room
		return false
	return room.approvalRequired
