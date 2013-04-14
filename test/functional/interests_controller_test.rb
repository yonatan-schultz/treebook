require 'test_helper'

class InterestsControllerTest < ActionController::TestCase
 
context "#new" do
	context "when not logged in" do
	  should "redirect to the login page" do
	    get :new
	    assert_response :redirect
	    assert_redirected_to login_path
	  end
	end

	context "when logged in" do
		setup do
			sign_in users(:poops)
		end

		should "get new and return success" do
			get :new
			assert_response :success
		end

		should "set a flash message if the interest_name is blank" do
			get :new, {}
			assert_equal "Interest Name Required", flash[:error]
		end

#		should "display the interest name" do
#			get :new, interest_name: interests(:one).interest_name 
#			assert_match /#{interests(:one).interest_name} /, response.body
#		end

		should "assign interest object" do
			get :new, interest_name: interests(:one).interest_name 
			assert assigns(:interest)
		end
	end
end

end
