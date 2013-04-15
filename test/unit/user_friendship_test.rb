require 'test_helper'

class UserFriendshipTest < ActiveSupport::TestCase
  should belong_to(:user)
  should belong_to(:friend)

  test "that creating a friendship works" do
    UserFriendship.create user: users(:poops), friend: users(:farts)
    assert users(:poops).pending_friends.include?(users(:farts))
  end

  context "a new instance" do
  	setup do
  		@user_friendship = UserFriendship.new user: users(:poops), friend: users(:pees)
  	end
  
	should "have a pending state" do
		assert_equal 'pending', @user_friendship.state
	end
  end 

  context "#send_request_email" do
  	setup do
  		@user_friendship = UserFriendship.create user: users(:poops), friend: users(:pees)
  	end

  	should "send an email" do
  		assert_difference 'ActionMailer::Base.deliveries.size', 1 do
  			@user_friendship.send_request_email
  		end
  	end
  end

  context "#accept!" do
  	setup do
  		@user_friendship = UserFriendship.create user: users(:poops), friend: users(:pees)
  	end

  	should "set the state to accepted" do
  		@user_friendship.accept!
  		assert_equal "accepted", @user_friendship.state
  	end 

  	should "send an acceptance email" do
  		assert_difference 'ActionMailer::Base.deliveries.size', 1 do
  			@user_friendship.accept!
  		end
  	end

  	should "include the friend in the list of friends" do
  		@user_friendship.accept!
  		users(:poops).friends.reload
  		assert users(:poops).friends.include?(users(:pees))
  	end
  end

  context ".request" do
  	should "create two user friendships" do
  		assert_difference "UserFriendship.count", 2 do
  			UserFriendship.request(users(:poops),users(:pees))
  		end
  	end

  	should "send a friend request email" do
  		assert_difference "ActionMailer::Base.deliveries.size", 1 do
  			UserFriendship.request(users(:poops),users(:pees))
  		end
  	end
  end
end
