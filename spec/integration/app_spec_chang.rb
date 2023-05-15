require "spec_helper"
require "rack/test"
require_relative '../../app'
require 'json'

def reset_bookings_table
  seed_sql = File.read("spec/seeds/bookings_seeds.sql")
  connection = PG.connect({ host: "127.0.0.1", dbname: "makersbnb_test" })
  connection.exec(seed_sql)
end

describe Application do

  include Rack::Test::Methods

  let(:app) { Application.new }
  let(:new_user) do 
    post('/new_user', name:'test', email:'test@example.com', password: 'abc')
    post('/sign_in', { email: 'test@example.com', password: 'abc'})
  end

  before { reset_bookings_table }
  after { reset_bookings_table }

  context 'GET /rooms' do
    it "should return 200 OK" do
      new_user
      response = get "/rooms"
      expect(response.status).to eq 200
      expect(response.body).to include '<h3>Choose dates to see the available locations: </h3>'
    end
    it "should, by default, display a list of all available rooms" do
      new_user
      response = get "/rooms"
      expect(response.status).to eq 200
      expect(response.body).to include '<h3>Changs Palace</h3>'
      expect(response.body).to include '<h3>Sarahs Sunset Side</h3>'
      expect(response.body).to include '<h3>Kons Gaff</h3>'
    end
  end

  context 'POST /rooms' do
    it "display the rooms available with the range of days the user requested" do
      new_user
      response = post "/rooms", from: "2023-05-01", to: "2023-05-04"
      # follow_redirect!
      expect(response.status).to eq 200
      expect(response.body).to include "Availabilities from Monday 01 May 2023"
      expect(response.body).to include "to Thursday 04 May 2023"
    end
    it "display only the rooms available from the days the user requested when only 'from' is filled" do
      new_user
      response = post "/rooms", from: "2023-03-01", to: ""
      # follow_redirect!
      expect(response.status).to eq 200
      expect(response.body).to include "Availabilities from Wednesday 01 March 2023"
    end
    it "display only the rooms available on the day the user requested when from and to are the same" do
      new_user
      response = post "/rooms", from: "2023-05-01", to: "2023-05-01"
      # follow_redirect!
      expect(response.status).to eq 200
      expect(response.body).to include "Availabilities on Monday 01 May 2023"
    end
  end

  context 'GET /requests' do 
    it "displays all the request sent and received" do 
      new_user
      follow_redirect!
      response = get("/requests")
      expect(last_response.status).to eq(200)
      # expect(last_response.body).to include("Request I've made")
      # expect(last_response.body).to include("Request I've received")
    end

    it "shows the name of room in the request sent" do 
      new_user
      follow_redirect!
      booking = Booking.new
      booking.owner_id = 1
      booking.room_id = 1
      booking.availability_id = 1
      booking.user_id = 6
      repo = BookingRepository.new
      repo.request_booking(booking)
      response = get("/requests")
      expect(last_response.body).to include("Changs Palace")
      expect(last_response.body).to include("A modern apartment in the heart of the city")
      expect(last_response.body).to include("Pending")
      expect(last_response.body).to include("2023-05-01")
    end

    it "shows the name of room from requests received" do
      new_user
      post '/list_a_space', {
        name: "Manhattan Appartment", 
        description: "Appartment in the center of NY",
        price: 500,
        available_from: "2023-05-02",
        available_to: "2023-05-03",
        user_id: 6
      }
      result = RoomRepository.new
      expect(result.find(6).name).to eq "Manhattan Appartment"
      get "/sign_out"

      post('/new_user', name:'chang', email:'chan@example.com', password: 'abc')
      post('/sign_in', { email: 'chan@example.com', password: 'abc'})

      booking = Booking.new
      booking.owner_id = 6
      booking.room_id = 6
      booking.availability_id = 2
      booking.user_id = 7
      repo = BookingRepository.new
      repo.request_booking(booking)
      response = get('/requests')
      expect(response.body).to include("Manhattan Appartment")
      expect(response.body).to include("Appartment in the center of NY")
      expect(response.body).to include("Pending")
      expect(response.body).to include("2023-05-02")

      get "/sign_out"

      post('/sign_in', { email: 'test@example.com', password: 'abc'})
      response = get('/requests')
      expect(response.body).to include("Manhattan Appartment")
      expect(response.body).to include("Appartment in the center of NY")
      expect(response.body).to include("Pending")
      expect(response.body).to include("2023-05-02")
      expect(response.body).to include("chang")
    end 
  end

  context "GET /room/:id" do
    it "should send a booking request" do
      new_user
      response = get "/room/1"
      expect(response.status).to eq 200
      expect(response.body).to include("Changs Palace")
      expect(response.body).to include("02/05")
      expect(response.body).to include("03/05")
    end
  end

  context "POST /room/:id" do
    it "should send a booking request" do
      new_user
      response = post "/room/1", request_date: "02", id: "1"
      follow_redirect!
      expect(last_response.status).to eq 200
      expect(last_response.body).to include("Changs Palace")
    end
  end
end
