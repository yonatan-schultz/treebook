class InterestsController < ApplicationController
  before_filter :authenticate_user!

	def new
		if params[:interest]
			@interest = Interest.new(params[:interest])
		else
			flash[:error] = "Interest Name Required"
		end
	end

end
