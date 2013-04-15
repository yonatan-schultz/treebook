class InterestsController < ApplicationController
  before_filter :authenticate_user!

	def new
		if params[:interest]
			@interest = current_user.interests.new(params[:interest])
		else
			flash[:error] = "Interest Name Required"
		end
	end

end
