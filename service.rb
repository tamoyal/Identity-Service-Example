require 'rubygems' 
require 'sinatra'
require 'models/user'
require 'mongoid'
require 'yajl'

configure do
   Mongoid.configure do |config|
    name = "fsg_ident"
    host = "localhost"
    config.master = Mongo::Connection.new.db(name)
  end
end

before do
  content_type :json
end

# get a user by id
get '/api/v1/users/:id' do
  user = User.find(params[:id]) 
  if user
    user.to_json 
  else
    error 404, {:error => "user not found"}.to_json 
  end
end

# authenticate user
post '/api/v1/sessions/' do
  begin
    attributes = Yajl::Parser.parse(request.body.read)
    user = User.authenticate(attributes["email"],attributes["password"])
    if user
      user.to_json 
    else
      error 404, "invalid login credentials"
    end
  rescue => e
    error 400, e.message.to_json
  end
end

# create user
post '/api/v1/users/' do
  begin
    user = User.new(Yajl::Parser.parse(request.body.read))
    if user.save
      user.to_json 
    else
      error 400, user.errors.to_json
    end
  rescue => e
    error 400, e.message.to_json
  end
end

# update an existing user
put '/api/v1/users/:id' do
  user = User.find(params[:id])
  if user
    begin
      user = user.update_attributes!(Yajl::Parser.parse(request.body.read))
      user.to_json
    rescue => e
      error 400, e.message.to_json
    end
  else
    error 404, "user not found".to_json
  end
end
  
