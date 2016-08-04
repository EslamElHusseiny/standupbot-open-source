## Standup-Bot

Check out our more advanced product with loads of new features and improvements!

http://standupbot.com

#### Automated Standups for Slack Channels

Messaging tools like Slack changed our work world. Standup changed our meetings. Standup Bot keeps us accountable, tracks our goals, and got us to post our successes, plans, and upcoming challenges. We love it so much and we think you will too, so we're releasing it Open-Source.


### Slack Setup:
  * Create a new Bot in Slack if you don't have one
    * Visit `https://your-team.slack.com/services/new/bot`
  * Invite the Bot you created to all Slack Channels you want to use
    * `/invite @your_bot`
  * Add a slash command integration (It allows to start the Standup typing /standup in Slack)
    * Visit `https://your-team.slack.com/services/new/slash-commands`
      * Set `/standup` as the command.
      * Set `http://your-app.herokuapp.com/api/standups/start?format=text` as the url.
      * Set `GET` as the method.

#### Local Setup (After Slack Setup):
  * Clone the repository
    * `git clone git@github.com:sofetch/slack-standup-bot.git`
  * Install all the gems
    * `bundle install`
  * Create and migrate the DB
    * `rake db:create db:migrate`
  * Start a local server and then visit the Settings page
    * `rails s`
    * Visit `http://localhost:3000/settings`  Populate all the inputs.
  * Run the mailcatcher server (It allows to see the emails, for that visit http://localhost:1080)
    * `mailcatcher`
  * Run the Delayed Job process
    * `rake jobs:work`
  * Now you have everything ready to start your first Standup
    * Visit `http://localhost:3000/api/standups/start?channel_name=YOUR_CHANNEL_NAME`.

#### Heroku Setup (After Slack Setup):
  * Clone the repository
    * `git clone git@github.com:sofetch/slack-standup-bot.git`
  * Associate your Heroku app and then push the master branch into Heroku
    * `heroku git:remote -a heroku-app-name`
    * `git push heroku master`
  * Run the Migrations
    * `heroku run rake db:migrate --app heroku-app-name`
  * Add a new worker to your app (If you don't have one running yet)
    * `heroku ps:scale worker=1`
  * Configure an SMTP server to deliver the emails
    * `heroku config:set MAILER_ADDRESS=your-smtp-domain.com`
    * `heroku config:set MAILER_PORT=587`
    * `heroku config:set MAILER_USERNAME=your-email@domain.com`
    * `heroku config:set MAILER_PASSWORD=your-password`
    * `heroku config:set MAILER_DOMAIN=your-domain.com`
  * Configure your credentials to access the webpage
    * `heroku config:set STANDUPBOT_USERNAME=your-username`
    * `heroku config:set STANDUPBOT_SECRET=your-secret`
  * Visit the Settings page
    * `http://your-app.herokuapp.com/settings` Populate all the inputs.
  * Now you have everything ready to start your first Standup
    * Type `/standup`.

> Be really careful when assigning the Bot username and Api Token, the app won't work if one of them is incorrect.


#### Commands:
  * `-skip`  Skips your turn until the end of standup.
  * `-yes`   Agrees to start your standup.
  * `-help`  Displays standup-bot commands in your channel.
  * `-status`  Displays the current status of the standup.
  * `-edit: #(1,2,3)` Edit your answer for the day.
  * `-delete: #(1,2,3)` Delete your answer for the day.

  * ##### Admin only Commands (Visit /settings to grant admin privileges to one or multiple users)
    * `-vacation: @user`  Skip users standup for the day. (Marks user "Vacation")
    * `-skip: @user`  Place user at the end of standup.
    * `-n/a: @user`   Skips users standup for the day
    * `-quit-standup` Quit standup.
    * `-start` Begins standup.


##### How to make a pull request:

1. Fork it ( https://github.com/sofetch/slack-standup-bot/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request
