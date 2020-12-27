require './mydb_class.rb'

user_name = ARGV[0]
socket = ARGV[1].to_s.dup
mydb = MyDB.new user_name, socket
mydb.exec
