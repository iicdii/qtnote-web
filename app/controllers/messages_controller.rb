class MessagesController < ApplicationController
    before_action :require_login
    
    def index
        @messages = current_user.messages
    end
    
    def read
        current_user.messages.each do |m|
            m.is_read = true
            m.save
        end
    end
end
