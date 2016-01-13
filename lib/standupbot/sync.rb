module Standupbot
  class Sync

    def initialize
      @settings = Setting.first
      @client   = Slack::Web::Client.new(token: @settings.try(:api_token))
    end

    # @return [Boolean]
    def valid?
      @client.auth_test

      group.present? && bot_id.present?

    rescue Slack::Web::Api::Error
      false
    end

    # @retun [Array] contains all the error messages.
    def errors
      [].tap do |result|
        begin
          @client.auth_test

          result << "There is no Channel called ##{@settings.name}" if group.nil?
          result << "There is no Bot called @#{@settings.bot_name} within the ##{@settings.name} Channel" if bot_id.nil?
        rescue Slack::Web::Api::Error
          result << "The Bot API Token is invalid"
        end
      end
    end

    # It creates all the necessary data to start the standup.
    #
    def perform
      realtime = Slack::RealTime::Client.new(token: @settings.api_token)
      channel  = Channel.where(name: group['name'], slack_id: group['id']).first_or_initialize

      return if channel.active?

      ActiveRecord::Base.transaction do
        channel.save!
        channel.start!

        @settings.update_attributes(bot_id: bot_id)

        group['members'].each do |member|
          channel.users << User.create_with_slack_data(user_by_slack_id(member))
        end
      end

      realtime.on :hello do
        if channel.complete?
          realtime.message channel: group['id'], text: 'Today\'s standup is already completed.'
          realtime.stop!
        else
          realtime.message channel: group['id'], text: 'Welcome to standup! Type "-Start" to get started.'
        end
      end

      realtime.on :message do |data|
        IncomingMessage.new(data, realtime).execute
      end

      realtime.on :close do
        channel.stop!
      end

      # HOTFIX: Heroku sends a SIGTERM signal when shutting down a node, this is the only way
      #   I found to change the state of the channel in that edge case.
      at_exit do
        channel.stop!

        @client.chat_postMessage(channel: group['id'],
                                 text: I18n.t('activerecord.models.incoming_message.bot_died'),
                                 as_user: true)
      end

      realtime.start_async
    end

    private

    # Returns a user for given slack id.
    #
    # @param [String] slack_id.
    # @return [Hash]
    def user_by_slack_id(slack_id)
      users.find { |u| u['id'] == slack_id }
    end

    # Returns the bot id.
    #
    # @return [String]
    def bot_id
      users.find { |what| what['name'] == @settings.bot_name }.try(:[], 'id')
    end

    # Returns the slack channel that the user selected.
    #
    # @return [Hash]
    def group
      private_channels = @client.groups_list['groups'] || []
      public_channels  = @client.channels_list['channels'] || []

      (private_channels | public_channels).detect { |c| c['name'] == @settings.name }
    end

    # Returns a list of all the users within the slack team.
    #
    # @return [Hash]
    def users
      @client.users_list['members']
    end

  end
end
