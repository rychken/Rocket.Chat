# uid and mid are each optional
RocketChat.isApprovalRequired = (rid, uid, mid) ->

	room = RocketChat.models.Rooms.findOneById rid

	# false if room doesn't require approval
	return false unless room?.approvalRequired

	message = if mid then RocketChat.models.Messages.findOneById(mid) else null

	# false if message from self
	return false if uid? and message? and uid == message.u._id

	# false if message doesn't require approval
	return false if message and not message?.needsApproval

	if uid
		return not RocketChat.authz.hasPermission(uid, 'message-approval', rid)
	else
		return true
