require 'test_helper'

class AuthenticationControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @access_token = 'abcdefg123456'

    @fb_user = stub()
    @fb_user.stubs(:authenticate).returns(@fb_user)
    @fb_user.stubs(:first_name).returns(@user.name)

    FbGraph2::User.stubs(:new).returns(@fb_user)
  end

  test "should get session token" do
    @fb_user.stubs(:fetch).returns(@fb_user)

    post '/get_session_token', as: :json,
         params: { auth: { id: @user.id,
                           access_token: @access_token } }
    assert_response :success
  end

  test "should raise invalid token exception" do
    @fb_user.stubs(:fetch)
            .returns(@fb_user)
            .then
            .raises(FbGraph2::Exception::InvalidToken, 'derp')

    post '/get_session_token', as: :json,
         params: { auth: { id: @user.id,
                           access_token: @access_token } }

    assert_response :unauthorized
  end

  test "should create new user with id, valid name and session token" do
    @fb_user.stubs(:fetch).returns(@fb_user)

    post '/get_session_token', as: :json,
         params: { auth: { id: 43,
                           access_token: @access_token } }
    user = User.find_by(id: 43)

    assert_instance_of User, user
    assert_equal user.name, @user.name
    assert_match /^[a-z0-9]{64}$/, user.session_token
  end

  test "should return invalid request if id and access_token are missing" do
    @fb_user.stubs(:fetch).returns(@fb_user)

    post '/get_session_token'

    assert_response :bad_request
  end

end
