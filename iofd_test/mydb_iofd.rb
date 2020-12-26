require './iofd_test/test_core.rb'

user_name = "test_user"
socket = "test_user_dir"
user_dir = "#{socket}/#{user_name}"
database_name = "database_name"
set_cmd("mydb.rb #{user_name} #{socket}")

directory_data_at_first_login = [socket]
directory_data_logged_in = [socket, user_dir]
directory_data_with_database = [socket, user_dir, "#{user_dir}/#{database_name}"]

iofd "login as test_user" do |iofd|
    iofd.directory_data_in_test = directory_data_at_first_login
    iofd.io_contents = [
        { output: "#{user_name}>", input: "exit" }
    ]
    iofd.directories = [user_dir]
    iofd
end

iofd "create database database_name" do |iofd|
    iofd.directory_data_in_test = directory_data_logged_in
    iofd.io_contents = [
        { output: "#{user_name}>", input: "create database #{database_name}" },
        { output: "#{user_name}>", input: "exit" }
    ]
    iofd.directories = ["#{user_dir}/#{database_name}"]
    iofd
end

iofd "create database database_name" do |iofd|
    iofd.directory_data_in_test = directory_data_with_database
    iofd.io_contents = [
        { output: "#{user_name}>", input: "use #{database_name}" },
        { output: "#{user_name}>#{database_name}>", input: "exit" }
    ]
    iofd.directories = ["#{user_dir}/#{database_name}"]
    iofd
end
