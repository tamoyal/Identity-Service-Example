require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "service" do
  before(:each) do
    User.delete_all
      
      post '/api/v1/users/', {
          :first_name     => "Tony",
          :last_name     => "Amoyal",
          :email    => "tamoyal@frontierstrategygroup.com",
          :password => "aSecurePassword",
          :password_confirmation => "aSecurePassword"}.to_json
      @user_id = Yajl::Parser.parse(last_response.body)["_id"]
      
  end
  
  describe "POST on /api/v1/users/" do
    it "should create a user" do
      last_response.should be_ok, last_response.body
            
      get "/api/v1/users/#{@user_id}"
      attributes = Yajl::Parser.parse(last_response.body)
      attributes["first_name"].should  == "Tony"
      attributes["last_name"].should  == "Amoyal"
      attributes["email"].should == "tamoyal@frontierstrategygroup.com"
    end
  end
  
  describe "GET on /api/v1/users/:id" do    
    it "should return a user by id" do
      get "/api/v1/users/#{@user_id}"
      last_response.should be_ok, last_response.body
      attributes = Yajl::Parser.parse(last_response.body) 
      attributes["first_name"].should == "Tony"
    end
  end
  
  describe "POST on /api/v1/sessions/" do
    it "should log in a user with proper credentials" do
      post "/api/v1/sessions/", {
          :email    => "tamoyal@frontierstrategygroup.com",
          :password => "aSecurePassword"}.to_json
      last_response.should be_ok, last_response.body
      attributes = Yajl::Parser.parse(last_response.body) 
      attributes["first_name"].should == "Tony"
    end
  
    it "should deny authentication to a user with bad credentials" do
      post "/api/v1/sessions/", {
          :email    => "tamoyal@frontierstrategygroup.com",
          :password => "aBadPassword"}.to_json
      last_response.status.should == 404
    end
  end
  
  describe "PUT on /api/v1/users/:id" do
    it "should update a user" do
      put "/api/v1/users/#{@user_id}", {
        :first_name => "Tony the TAFTr" }.to_json
      last_response.should be_ok, last_response.body
      get "/api/v1/users/#{@user_id}"
      attributes = Yajl::Parser.parse(last_response.body)
      attributes["first_name"].should == "Tony the TAFTr"
    end
  end
  
end