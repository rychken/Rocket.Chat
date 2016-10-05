RocketChat.updateMessage = (message, user) ->
	# If we keep history of edits, insert a new message to store history information
	if RocketChat.settings.get 'Message_KeepHistory'
		RocketChat.models.Messages.cloneAndSaveAsHistoryById message._id

	message.editedAt = new Date()
	message.editedBy =
		_id: user._id,
		username: user.username

	urls = message.msg.match(RegExp.urls)

	if urls
		message.urls = ({url: url} for url in urls)

	message = RocketChat.callbacks.run('beforeSaveMessage', message)

	tempid = message._id
	delete message._id

	query = { $set: message }

	if RocketChat.authz.hasPermission user._id, 'message-approval', message.rid
		query["$unset"] = { needsApproval: "" }

	RocketChat.models.Messages.update { _id: tempid }, query

	room = RocketChat.models.Rooms.findOneById(message.rid)

	Meteor.defer ->
		RocketChat.callbacks.run 'afterSaveMessage', RocketChat.models.Messages.findOneById(tempid), room
