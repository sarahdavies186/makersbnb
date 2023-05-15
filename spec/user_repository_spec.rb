require 'user_repository'
require 'user'

def reset_users_table
  seed_sql = File.read("spec/seeds/makersbnb_seeds.sql")
  connection = PG.connect({ host: "127.0.0.1", dbname: "makersbnb_test", password: 'a' })
  connection.exec(seed_sql)
end

describe UserRepository do
  before(:each) { reset_users_table }
    context 'it returns all users' do 
      it ' has a functioning all method' do
        repo = UserRepository.new 
        result = repo.all
        expect(result.length).to eq (5)

        expect(result.last.name).to eq  ('Destin')
        expect(result.last.email).to eq("destin@gmail.com")
        # expect(result.last.password).to eq("back2future")
      end 
    end 

    context 'it returns a specific user' do 
      it 'has a functioning find method' do 
        repo = UserRepository.new

        user = repo.find(1)

        expect(user.id).to eq(1)
        expect(user.name).to eq("chang")
        expect(user.email).to eq("chang@gmail.com")
        # expect(user.password).to eq("123")
      end
    end

    context 'it returns a specific user by email' do 
      it 'has finds the user information related to the email' do 
        repo = UserRepository.new

        user = repo.find_by_email('destin@gmail.com')

        expect(user.id).to eq(5)
        expect(user.name).to eq("Destin")
        expect(user.email).to eq("destin@gmail.com")
        # expect(user.password).to eq("back2future")
      end
    end

    describe '#email_exists?' do
      context 'when email exists in the database' do
        it 'returns true' do
          repo = UserRepository.new

          user = repo.email_exists?('chang@gmail.com')

          expect(user).to be true
        end
      end

      context 'when email does not exist in the database' do
        it 'returns false' do
          repo = UserRepository.new

          user = repo.email_exists?('martymcfly100@example.com')
          
          expect(user).to be false
        end
      end
    end

      context 'creates an individual user' do 
        it "has a functioning create method" do 
          user = User.new 
          repo = UserRepository.new

          user.name = "Kama"
          user.email = "lamakama@hotmail.com"
          user.password = "mypassword123"

          repo.create(user)
          result = repo.all

          expect(result.last.name).to eq ("Kama")
          expect(result.last.email).to eq ("lamakama@hotmail.com")
      end 
    end 

    context "updates an individual user" do 
      it "has a functioning update method" do 
        repo = UserRepository.new

        user = repo.find(1)
        user.name = "Chang" 

        repo.update(user)
        result = repo.find(1)
        expect(result.name).to eq ("Chang")
      end 
    end 
end
 
