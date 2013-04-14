require 'test_helper'

class InterestTest < ActiveSupport::TestCase
 
 should belong_to(:user)

 test "that creating an interest works without raising an alarm" do 
 	assert_nothing_raised do 
 		Interest.create interest_name: "Snoring" 
 	end
 end

end
