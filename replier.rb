require 'intercom'

TOKEN = ENV['MY_INTERCOM_TOKEN']

intercom = Intercom::Client.new(token: TOKEN)
me = intercom.admins.me

intercom.conversations.find_all(type: 'admin', id: me.id, open: true).each {
	|convo|
	puts "In the loop"
	convo_id = convo.id
	puts convo_id
	count = 0
	convo_parts = convo.conversation_parts.reverse_each {|part| count = count+1}
	puts convo_parts
	# parts_count = convo_parts.each.length
	last_part_auth = convo_parts[0].author

	if last_part_auth == "User"
		puts "Last author of the conversation was a user"
	elsif last_part_auth == "Admin"
		puts "Last author of the conversation was an admin"
	else
		puts "Something has broken bud"
	end
}