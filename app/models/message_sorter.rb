class MessageSorter

  class << self
    def sort_incomming_messages(data, client)
      standup = Standup.check_for_standup(data).first
      user = User.find_by(user_id: data['user'])
      Standup.vacation(data, client) if data['text'].downcase.include? "vacation: <@"
      Standup.admin_skip(data, client) if data['text'].downcase.include? "skip: <@"
      quit_standup(client, data['channel']) if data['text'].downcase == "quit-standup"
      help(client, data['channel']) if data['text'].downcase == "help"
      complete_standup(client, data['channel']) if Standup.complete?(client)
      Standup.skip_until_last_standup(client, data, standup) if standup && data['text'].downcase == "skip" && standup.not_complete?
      user_already_completed_standup(client, data) if standup && standup.complete?
      check_question_status(client, data, user, standup)
      start_standup(client, data) if data['text'].downcase == 'start' && standup.nil?
    end

    def help(client, channel)
      client.message channel: channel, text: "Standup-bot commands. \n * start                                    Begin Standup \n * vacation: @user           Skip users standup for the day \n * skip: @user                     Place user at the end of standup \n * yes                                     Begin your standup \n * skip                                   Skip your standup until the end of standup \n * quit-standup                 Quit standup  "
    end

    def start_standup(client, data)
      client.message channel: data['channel'], text: "Standup has started."
      client.message channel: data['channel'], text: "Goodmorning <@#{data['user']}>, Welcome to daily standup! Are you ready to begin?  ('yes', or 'skip')"
      Standup.check_registration(client, data, true)
    end

    def user_already_completed_standup(client, data)
      client.message channel: data['channel'], text: "You have already submitted a standup for today, thanks! <@#{data['user']}>"
    end

    def check_question_status(client, data, user, standup)
      if standup && standup.not_complete? && user.not_ready? && data['text'].downcase == "yes"
        Standup.question_1(client, data, user) if standup && standup.not_complete? && user.not_ready? && data['text'].downcase == "yes"
      elsif standup && standup.not_complete? && user.ready?
        Standup.check_question(client, data, standup)
      end
    end

    def quit_standup(client, channel)
      client.message channel: channel, text: "Quiting Standup"
      client.stop!
    end

    def complete_standup(client, channel)
      channel = client.groups.detect { |c| c['name'] == 'a-standup' }['id']
      client.message channel: channel, text: "That concludes our standup. For a recap visit http://quiet-shore-3330.herokuapp.com/"
      User.where(admin_user: true).first.update_attributes(admin_user: false) unless User.where(admin_user: true).first.nil?
      client.stop!
    end
  end
end
