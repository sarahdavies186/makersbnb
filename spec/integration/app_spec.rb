require "spec_helper"
require "rack/test"
require_relative '../../app'
require 'json'
require 'user'
require 'bcrypt'
require "user_repository"

def reset_makersbnb_table
  seed_sql = File.read("spec/seeds/makersbnb_seeds.sql")
  connection = PG.connect({ host: "127.0.0.1", dbname: "makersbnb_test" })
  connection.exec(seed_sql)
end

describe Application do
  # This is so we can use rack-test helper methods.
  include Rack::Test::Methods

  # We need to declare the `app` value by instantiating the Application
  # class so our tests work.
  let(:app) { Application.new }

  before(:each) { reset_makersbnb_table }

  # Write your integration tests below.
  # If you want to split your integration tests
  # accross multiple RSpec files (for example, have
  # one test suite for each set of related features),
  # you can duplicate this test file to create a new one.


  # context 'GET /rooms' do
  #   it "should return 200 OK" do
  #     response = get "/rooms"
  #     expect(response.status).to eq 200
  #     expect(response.body).to include '<h1>BOOK A SPACE</h1>'
  #   end
  #   it "should, by default, display a list of all available rooms" do
  #     response = get "/rooms"
  #     expect(response.status).to eq 200
  #     expect(response.body).to include '<h2>Changs Palace</h2>'
  #     expect(response.body).to include '<h2>Sarahs Sunset Side</h2>'
  #     expect(response.body).to include '<h2>Kons Gaff</h2>'
  #   end
  # end

  #SIGN IN TESTS
  context 'GET sign_in' do 
    it 'should show a form to sign into account' do 
      response = get('/sign_in')
      expect(response.status).to eq(200)
      expect(response.body).to include ('<input type="text" name="email" required/>')
      expect(response.body).to include ('<input type="password" name="password" required/>')
    end
  end

  context 'POST /sign_in' do
    it "should respond with a successful sign in message if password & email is correct" do
      post('/new_user', name:'test', email:'test@example.com', password: 'abc')
      post('/sign_in', { email: 'test@example.com', password: 'abc'})
      follow_redirect!
      expect(last_response.status).to eq 200
      expect(last_request.path).to eq ('/rooms') 
    end
  end

  context 'POST /sign_in' do
    it "should show error if password is wrong" do
      post('/new_user', name:'test', email:'test@example.com', password: 'abc')
      response = post('/sign_in', { email: 'test@example.com', password: 'abcd'})
      expect(response.status).to eq 200
      expect(response.body).to include ("Password is incorrect") 
    end
  end

  context 'POST /sign_in' do
    it "should show error if email is not found" do
      post('/new_user', name:'test', email:'test@example.com', password: 'abc')
      response = post('/sign_in', { email: 'tes@example.com', password: 'abc'})
      expect(response.status).to eq 200
      expect(response.body).to include ("This email address does not exist. Please try again or sign up for an account.") 
    end
  end

  #SIGN UP TESTS
  context 'GET /sign_up' do 
    it 'should show the form to create a new user account' do 
      response = get('/sign_up')
      expect(response.status).to eq(200)
      expect(response.body).to include ('<input type="text" name="name" required/>')
      expect(response.body).to include ('<input type="password" name="password" required/>')
    end 
  end

  context 'POST /new_user' do
    it 'should create a new user account if email does not already exist' do 
      response = post('/new_user', name:'Mark', email:'Mark@example.com', password:'Thisis@mark')
      expect(response.status).to eq(200)
      user = UserRepository.new.find_by_email('Mark@example.com')
      expect(user.name).to eq "Mark"
    end

    it 'should show an error if email already exists' do 
      response = post('/new_user', name:'Mark', email:'konrad@gmail.com', password:'Thisis@mark')
      expect(response.status).to eq(200)
      expect(response.body).to include ("Email already exists. Please click login below")
    end
  end



end
