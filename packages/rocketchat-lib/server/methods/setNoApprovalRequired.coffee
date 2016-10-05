Meteor.methods
	setNoApprovalRequired: (rid) ->

		check rid, String

		if not Meteor.userId()
			throw new Meteor.Error 'error-invalid-user', 'Invalid user', { method: 'setNoApprovalRequired' }

		room = RocketChat.models.Rooms.findOneById rid

		unless room
			throw new Meteor.Error 'error-invalid-room', 'Invalid room', { method: 'setNoApprovalRequired' }

		unless RocketChat.authz.hasPermission(Meteor.userId(), 'message-approval', room._id)
			throw new Meteor.Error 'error-not-authorized', 'Not authorized', { method: 'setNoApprovalRequired' }

		RocketChat.models.Rooms.setNoApprovalRequiredById(rid)
