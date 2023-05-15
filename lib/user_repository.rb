require_relative 'user'
require 'bcrypt'

class UserRepository

  def all
    sql = 'SELECT id, name, email, password FROM users;'
    result_set = DatabaseConnection.exec_params(sql, []) 
    users = []

    result_set.each do |result|
      user=User.new
      user.id = result['id'].to_i
      user.name = result['name']
      user.email = result['email']
      user.password = result['password']

      users << user
    end
    return users
  end 

  def find_by_email(email)
    sql = 'SELECT id, name, email, password FROM users WHERE email = $1;'
    result_set = DatabaseConnection.exec_params(sql,[email])

    puts result_set
    user = User.new
    user.id = result_set[0]['id'].to_i
    user.name = result_set[0]['name']
    user.email = result_set[0]['email']
    user.password = result_set[0]['password']
   
    return user
  end

  def email_exists?(email)
    sql = 'SELECT COUNT(*) FROM users WHERE email = $1;'
    result_set = DatabaseConnection.exec_params(sql, [email])
  
    return result_set[0]['count'].to_i > 0
  end

  def find(id)
    sql = 'SELECT id, name, email, password FROM users WHERE id = $1;'
      # sql_params = [id]
    result_set = DatabaseConnection.exec_params(sql,[id])

    user = User.new
    user.id = result_set[0]['id'].to_i
    user.name = result_set[0]['name']
    user.email = result_set[0]['email']
    user.password = result_set[0]['password']

    return user
  end

    def create(user) 
      # if find_by_email(user.email)
      #   return false
      # else  
        encrypted_password = BCrypt::Password.create(user.password)
        sql = 'INSERT INTO users (name, email, password) VALUES ($1, $2, $3);'
        params = [user.name, user.email, encrypted_password]
        result_set = DatabaseConnection.exec_params(sql, params) 
        # return true
      # end
    end

    def update(user)
      sql = 'UPDATE users SET name = $1, email = $2, password = $3 WHERE id = $4;'
      params =  [user.name, user.email, user.password, user.id]
      result_set = DatabaseConnection.exec_params(sql, params) 
    end

end
