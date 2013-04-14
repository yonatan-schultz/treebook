require 'test_helper'

class UserFriendshipTest < ActiveSupport::TestCase
  should belong_to(:user)
  should belong_to(:friend)

  test "that creating a friendship works" do
    UserFriendship.create user: users(:poops), friend: users(:farts)
    assert users(:poops).friends.include?(users(:farts))
  end
end
