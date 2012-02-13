# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# User.create(:username => 'Jean',     :password => 'password', :email => 'jean@mail.com')
# User.create(:username => 'Jack',     :password => 'password', :email => 'jack@mail.com')
# User.create(:username => 'John',     :password => 'password', :email => 'john@mail.com')
# User.create(:username => 'Paul',     :password => 'password', :email => 'paul@mail.com')
# User.create(:username => 'Ravi',     :password => 'password', :email => 'ravi@mail.com')
# User.create(:username => 'X'   ,     :password => 'password', :email => 'x@mail.com')
# User.create(:username => 'Otto',     :password => 'password', :email => 'otto@mail.com')
# User.create(:username => 'Nicolas',  :password => 'password', :email => 'nicolas@mail.com')
# User.create(:username => 'David',    :password => 'password', :email => 'david@mail.com')
# User.create(:username => 'Art',      :password => 'password', :email => 'art@mail.com')
# User.create(:username => 'Jeremy',   :password => 'password', :email => 'jeremyn@mail.com')
# User.create(:username => 'Aurelien', :password => 'password', :email => 'aurelien@mail.com')
# User.create(:username => 'Cyril',    :password => 'password', :email => 'cyril@mail.com')

Status.create(:name => 'validated')
Status.create(:name => 'rejected')
Status.create(:name => 'has_responded')