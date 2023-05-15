require 'sinatra/base'
require 'sinatra/reloader'
require_relative "./lib/room_repository"
require_relative "./lib/availability_repository"
require_relative "./lib/database_connection.rb"
require_relative "./lib/user_repository.rb"
require_relative "./lib/booking_repository.rb"
require "date"
require 'bcrypt'

DatabaseConnection.connect("makersbnb_test")

  class Application < Sinatra::Base
  enable :sessions
  configure :development do
    register Sinatra::Reloader
    also_reload "lib/user.rb"
    also_reload "lib/user_repository.rb"
  end

  def room_repo
    @room_repo ||= RoomRepository.new
  end
  def availability_repo
    @availability_repo ||= AvailabilityRepository.new
  end

  get '/' do
    return erb(:index)
  end

  get "/rooms" do
    if session[:id].nil?
      redirect "/"
    else
      @rooms = room_repo.all
      @session_id = session[:id]
      user_repo = UserRepository.new
      @user = user_repo.find(@session_id)
      return erb(:rooms)
    end
  end

  post "/rooms" do
    redirect "/rooms" if params[:from].empty?
    last_date_with_availabilities = availability_repo.all.last.date

    @to_is_empty = params[:to].empty?
    
    @from = params[:from]
    @to = @to_is_empty ? last_date_with_availabilities : params[:to]
    @same_from_and_to = @from == @to
    @rooms = availability_repo.find_rooms_within_range(@from, @to)
    @session_id = session[:id]
    user_repo = UserRepository.new
    @user = user_repo.find(@session_id)
    return erb(:rooms)
    # redirect "/rooms"
  end

  get "/room/:id" do
    if session[:id].nil?
      redirect "/"
    else
      @id = params[:id]

      @month = Date.parse("2023-05-31").strftime("%m")
      start_date = Date.parse("2023-05-01").strftime("%d")
      end_date = Date.parse("2023-05-31").strftime("%d")
      @room = room_repo.find(@id)
      @availabilities_objects = availability_repo.find_by_room(@id)
      days_with_availabilities = @availabilities_objects.map! { |av| av.date[-2..-1] }

      @days_hash = {}
      (start_date..end_date).each { |day| @days_hash[day] = nil }

      @days_hash.each do |k, v|
        days_with_availabilities.each do |av|
          @days_hash[k] = 1 if k == av
        end
      end
    end
    @message = session.delete(:message)
    return erb(:room_page)
  end

  post "/room/:id" do
    booking = Booking.new
    booking.room_id = params[:id]
    repo = RoomRepository.new
    booking.owner_id = repo.find(params[:id].to_i).user_id
    booking.availability_id = params[:request_date].to_i
    booking.user_id = session[:id]
    
    new_booking = BookingRepository.new
    new_booking.request_booking(booking)
    session[:message] = "Your request was successfully sent to the space owner."
    redirect "/room/#{params[:id]}"
  end

  get '/list_a_space' do
    if session[:id].nil?
      redirect "/"
    else
      @message = session.delete(:message)
      return erb(:list_a_space)
    end
  end

  post '/list_a_space' do
    repo = RoomRepository.new
    @new_listing = Room.new 
    @new_listing.name = params[:name]
    @new_listing.description = params[:description]
    @new_listing.price = params[:price]
    @new_listing.available_from = params[:available_from]
    @new_listing.available_to = params[:available_to]
    @new_listing.user_id = session[:id] # this will be pulled from user who's signed up
    repo.create(@new_listing)

    room = repo.find(repo.all.last.id)
    availability_repo = AvailabilityRepository.new
    availability_repo.add_room(room)
    session[:message] = "Your space was successfully added to the listing."
    redirect "/list_a_space"
  end

  #SIGN-IN
  get '/sign_in' do
    erb(:sign_in)
  end

  post '/sign_in' do
    email = params[:email]
    password = params[:password]

    user = login(email, password)
    if user == "not found"
      @error_message = "This email address does not exist. Please try again or sign up for an account."
      erb(:sign_in)
    elsif user == "incorrect password"
      @error_message = "Password is incorrect"
      erb(:sign_in)
    else
      session[:id] = user.id
      redirect '/rooms'
    end
  end

  def login(email, submitted_password)
    user_exists = _user_repo.email_exists?(email)
    return "not found" if user_exists == false

    user = _user_repo.find_by_email(email)
    stored_password = BCrypt::Password.new(user.password)
    return "incorrect password" if stored_password != submitted_password 
      
    return user
  end
  
  #SIGN-UP
  get '/sign_up' do
    erb(:sign_up)
  end

  post '/new_user' do
    repo = UserRepository.new
    user = User.new
    user.name = params[:name]
    user.email = params[:email]
    user.password = params[:password]

    if repo.email_exists?(user.email)
      @error_message = "Email already exists. Please click login below"
      return erb(:sign_up) 
    else
      repo.create(user)
      return erb(:sign_in)
    end
  end

  get "/sign_out" do
    session.clear
    redirect "/"
  end

  get '/requests' do
    if session[:id].nil?
      redirect "/"
    else
      user_id = session[:id]
      repo = BookingRepository.new
      @room_repo = RoomRepository.new
      @availability = AvailabilityRepository.new
      @bookings = repo.all_sent(user_id)
      @bookings_received = repo.all_received(user_id)
      @user_repo = UserRepository.new
      return erb(:requests)
    end
  end

  get '/request/:id' do
    p params
    id = params[:id]
    booking_repo = BookingRepository.new
    room_repo = RoomRepository.new
    user_repo = UserRepository.new
    date_repo = AvailabilityRepository.new
    @booking = booking_repo.find(id)
    @room = room_repo.find(@booking.room_id)
    @user = user_repo.find(@booking.user_id)
    @date = date_repo.find_by_id(@booking.availability_id)
    return erb :request
  end

  post "/confirm_request/:id" do
    id = params[:id]
    booking_repo = BookingRepository.new
    booking_repo.confirm_booking(id)
    redirect "/requests"
  end

  post "/deny_request/:id" do
    id = params[:id]
    booking_repo = BookingRepository.new
    booking_repo.deny_request(id)
    redirect "/requests"
  end

  #helpers
  def _user_repo
    @user_repo ||= UserRepository.new
  end
end

