require 'test_helper'

class UserTest < ActiveSupport::TestCase
  should have_many(:statuses)
  should have_many(:user_friendships)
  should have_many(:friends)

  test "a user should enter a first name" do
    user = User.new
    assert !user.save
    assert !user.errors[:first_name].empty?
  end

  test "a user should enter a last name" do
    user = User.new
    assert !user.save
    assert !user.errors[:last_name].empty?
  end

  test "a user should enter a profile name" do
    user = User.new
    assert !user.save
    assert !user.errors[:profile_name].empty?
  end

  test "a user should have a unique profile name" do
    user = User.new
    user.profile_name = users(:poops).profile_name

    assert !user.save
    assert !user.errors[:profile_name].empty?
  end

  test "a user should have a profile name without spaces" do
    user = User.new(first_name: 'Farts', last_name: 'Alot', email: 'farts@farts.net')
    user.password = user.password_confirmation = 'asdfasdf'

    user.profile_name = 'Contains spaces'

    assert !user.save
    assert !user.errors[:profile_name].empty?
    assert user.errors[:profile_name].include?("Must be formatted correctly.")
  end

  test "a user should have a profile name" do
    user = User.new(first_name: 'Farts', last_name: 'Alot', email: 'farts@farts.net')
    user.password = user.password_confirmation = 'asdfasdf'

    user.profile_name = 'fartsalot'
    assert user.profile_name?
  end
end
