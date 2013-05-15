require 'test_helper'

class UserFriendshipsControllerTest < ActionController::TestCase
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

      should "get new without error" do
        get :new
        assert_response :success
      end

      should "should set a flash error if the friend_id param is missing" do
        get :new, {}
        assert_equal "Friend required", flash[:error]
      end

      should "display a 404 page if no friend is found" do
        get :new, friend_id: 'invalid'
        assert_response :not_found
      end

      should "display the friend's name" do
        get :new, friend_id: users(:pees)
        assert_match /#{users(:pees).full_name}/, response.body
      end

      should "assign a user friendship" do
        get :new, friend_id: users(:pees)
        assert assigns(:user_friendship)
      end

      should "assign a user friendship with the user as current user" do
        get :new, friend_id: users(:pees)
        assert_equal assigns(:user_friendship).user, users(:poops)
      end

      should "assign a user friendship with the correct friend" do
        get :new, friend_id: users(:pees)
        assert_equal assigns(:user_friendship).friend, users(:pees)
      end
    end
  end
  
  context "#create" do
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

      context "with no friend_id" do
        setup do
          post :create
        end

        should "set the flash error message" do
          assert !flash[:error].empty?
        end

        should "set redirect to root" do
          assert_redirected_to root_path
        end
      end

      context "successfully" do
        should "create two user friendship objects" do
          assert_difference 'UserFriendship.count', 2 do
            post :create, user_friendship: { friend_id: users(:poops).profile_name }
          end
        end
      end

      context "with a valid friend_id" do
        setup do
          post :create, user_friendship: { friend_id: users(:farts) }
        end

        should "assign a friend object" do
          assert assigns(:friend)
          assert_equal users(:farts), assigns(:friend)
        end

        should "assign a user_friendship object" do
          assert assigns(:user_friendship)
          assert_equal users(:poops), assigns(:user_friendship).user
          assert_equal users(:farts), assigns(:user_friendship).friend
        end

        should "create a user friendship" do
          assert users(:poops).pending_friends.include?(users(:farts))
        end

        should "redirect to friend profile page" do
          assert_response :redirect
          assert_redirected_to profile_path(users(:farts))
        end

      end
    end
  end

    context "#index" do
      context "when not logged in" do
        should "redirect to the login page" do
          get :index
          assert_response :redirect
        end
      end

      context "when logged in" do
        setup do
          @friendship1 = create(:pending_user_friendship, user: users(:poops), friend: create(:user, first_name: 'Pending', last_name: 'Friend'))
          @friendship2 = create(:accepted_user_friendship, user: users(:poops), friend: create(:user, first_name: 'Active', last_name: 'Friend'))
          @friendship3 = create(:requested_user_friendship, user: users(:poops), friend: create(:user, first_name: 'Requested', last_name: 'Friend'))
          @friendship4 = user_friendships(:blocked_by_poops)

          sign_in users(:poops)
          get :index
        end

        should "get the index page without error" do
          assert_response :success
        end

        should "assign user_friendships" do
          assert assigns(:user_friendships)
        end

        should "display friend's names" do
          assert_match /Pending/, response.body
          assert_match /Active/, response.body
        end

        should "display pending information on a pending friendship" do
          assert_select "#user_friendship_#{@friendship1.id}" do
            assert_select "em", "Friendship is pending."
          end
        end

        should "display accepted information on an accepted friendship" do
          assert_select "#user_friendship_#{@friendship2.id}" do
            assert_select "em", "Friendship is accepted."
          end
        end

        should "display date information on an accepted friendship" do
          assert_select "#user_friendship_#{@friendship2.id}" do
           assert_select "em", "Friendship began #{@friendship2.updated_at}."
          end
        end

        context "blocked users" do
          setup do
            get :index, list: 'blocked'
          end

          should "get the index without error" do
            assert_response :success
          end

          should "not display pending requested or active friends names" do
            assert_no_match /Pending\ Friend/, response.body
            assert_no_match /Active\ Friend/, response.body
            assert_no_match /Requested\ Friend/, response.body
          end

          should "display blocked users friends names" do
            assert_match /Blocked\ Friend/, response.body
          end
        end

        context "pending users" do
          setup do
            get :index, list: 'pending'
          end

          should "get the index without error" do
            assert_response :success
          end

          should "not display blocked requested or active friends names" do
            assert_no_match /Blocked\ Friend/, response.body
            assert_no_match /Active\ Friend/, response.body
            assert_no_match /Requested\ Friend/, response.body
          end

          should "display pending users friends names" do
            assert_match /Pending\ Friend/, response.body
          end
        end

        context "active users" do
          setup do
            get :index, list: 'active'
          end

          should "get the index without error" do
            assert_response :success
          end

          should "not display pending requested or blocked friends names" do
            assert_no_match /Pending\ Friend/, response.body
            assert_no_match /Blocked\ Friend/, response.body
            assert_no_match /Requested\ Friend/, response.body
          end

          should "display active users friends names" do
            assert_match /Active\ Friend/, response.body
          end
        end

        context "requested users" do
          setup do
            get :index, list: 'requested'
          end

          should "get the index without error" do
            assert_response :success
          end

          should "not display pending active or blocked friends names" do
            assert_no_match /Pending\ Friend/, response.body
            assert_no_match /Blocked\ Friend/, response.body
            assert_no_match /Active\ Friend/, response.body
          end

          should "display requested users friends names" do
            assert_match /Requested\ Friend/, response.body
          end
        end

      end 
    end

  context "#accept" do
      context "when not logged in" do
        should "redirect to the login page" do
          put :accept, id: 1
          assert_response :redirect
        end
      end

      context "when logged in" do
        setup do
          @friend = create(:user)
          @user_friendship = create(:pending_user_friendship, user: users(:poops), friend: @friend)
          create(:pending_user_friendship, user: @friend, friend: users(:poops) )
          sign_in users(:poops)
          put :accept, id: @user_friendship
          @user_friendship.reload
        end

        should "assing a user_friendship" do
          assert assigns(:user_friendship)
          assert_equal @user_friendship, assigns(:user_friendship)
        end

        should "update the state to accepted" do
          assert_equal 'accepted', @user_friendship.state
        end

        should "have a flash success message" do
          assert_equal "You are now friends with #{@user_friendship.friend.first_name}.", flash[:success]
        end
      end
    end

  context "#edit" do
    context "when not logged in" do
      should "redirect to the login page" do
        get :edit, id: 1
        assert_response :redirect
        assert_redirected_to login_path
      end
    end

    context "when logged in" do
      setup do
        @user_friendship = create(:pending_user_friendship, user: users(:poops))
        sign_in users(:poops)
        get :edit, id: @user_friendship
      end

      should "get edit without error" do
        assert_response :success
      end

      should "assign to user_friendship" do
        assert assigns(:user_friendship)
      end

      should "assign friend" do
        assert assigns(:friend)
      end
    end
  end

 context "#destroy" do
      context "when not logged in" do
        should "redirect to the login page" do
          delete :destroy, id: 1
          assert_response :redirect
          assert_redirected_to login_path
        end
      end

      context "when logged in" do
        setup do
          @friend = create(:user)
          @user_friendship = create(:accepted_user_friendship, friend: @friend, user: users(:poops))
          create(:accepted_user_friendship, friend: users(:poops), user: @friend)
          sign_in users(:poops)
        end
     

        should "delete user friendships" do
          assert_difference 'UserFriendship.count', -2 do
          delete :destroy, id: @user_friendship
          end
        end  

        should "set the flash" do
          delete :destroy, id: @user_friendship             
          assert_equal "Friendship Destroyed.", flash[:success]       
        end
      end
  end

  context "#block" do
    context "when not logged in" do
        should "redirect to the login page" do
          put :block, id: 1
          assert_response :redirect
          assert_redirected_to login_path
        end
      end

    context "when logged in" do
      setup do
        @user_friendship = create(:pending_user_friendship, user: users(:poops))
        sign_in users(:poops)
        put :block, id: @user_friendship
        @user_friendship.reload
      end

      should "assign user friendship object" do
        assert assigns(:user_friendship)
        assert_equal @user_friendship, assigns(:user_friendship)
      end

      should "update the user friendship state to blocked" do
        assert_equal 'blocked', @user_friendship.state
      end
    end

  end
end

