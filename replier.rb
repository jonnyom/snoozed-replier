require 'intercom'
require 'json'

TOKEN = ENV['MY_INTERCOM_TOKEN']

def auth_intercom
  @intercom = Intercom::Client.new(token: TOKEN)
end

def auth_me
	@me = @intercom.admins.me
end

def reply(convo_id)
	@intercom.conversations.reply(id: convo_id, type: 'admin', admin_id: @me.id, message_type: 'comment', body: 'I just wanted to check in on the issue you were experiencing?')
end

def get_conversation_info(convo_id)
	full_convo = @intercom.conversations.find(id: convo_id)

	convo_details = {
		:updated_at => nil,
		:body => ""
	}

	if !full_convo.conversation_parts.empty?
		puts "conversation_parts aren't empty"
		full_convo.conversation_parts.reverse_each do |convo_part|
			if convo_part.part_type == "comment" && convo_part.author.instance_of?(Intercom::Admin)
		    	puts "Conversation part is recent and a comment from admin."
		    	convo_details[:updated_at] = convo_part.created_at
		    	convo_details[:body] = convo_part.body
		    	break
		    else
	     		puts "Conversation part is recent, but not a reply from an admin."
	     		break
    		end
  		end
  	else
  		puts "Conversation parts are empty"
	end

	convo_details[:body].slice!("<p>")
	convo_details[:body].slice!("</p>")

	convo_details
end

def main
	auth_intercom
	auth_me
	@intercom.conversations.find_all(type: 'admin', id: @me.id, open: true).each do
		|convo|
		puts " "
		puts " *** *** *** *** *** "
		puts "In the loop"

		convo_id = convo.id
		message = get_conversation_info(convo_id)
		last_reply = message[:body].downcase
		puts last_reply
		if last_reply.include? "can i help with"
			puts "Last message was from you and contained your check, repyling..."
			reply(convo_id)
		else
			puts "Don't reply to this message"
			puts " *** *** *** *** *** "
			puts " "
			next
		end
	end
end

main