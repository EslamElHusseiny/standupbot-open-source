class StandupsController < ApplicationController

  def index
    @date = Date.parse(params[:date]) rescue Date.today
    @date_string = @date.strftime("%A")
    @standups = Standup.where(created_at: @date.at_midnight..@date.next_day.at_midnight).order('today DESC NULLS LAST') 
  end

end
