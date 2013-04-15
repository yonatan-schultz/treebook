require 'test_helper'

class AddAFriendTest < ActionDispatch::IntegrationTest
	def sign_in_as(user,password)
		post login_path, user: {email: user.email, password: password}
	end

	test "that adding a friend works" do 

		sign_in_as users(:poops), "testing"

		get "/user_friendships/new?friend_it=#{users(:pees).profile_name}"
		assert_response :success

		assert_different 'UserFriendship.count' do
			post "/user_friendships", user_friendship: { friend_id: users(:pees).profile_name }
			assert_response :redirected
			assert_equal "You are now friends with #{users(:pees).full_name}", flash[:success]
		end

	end
end
