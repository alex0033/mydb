require './iofd_test/test_core.rb'

user_name = "test_user"
socket = "test_user_dir"
set_cmd("ruby #{user_name} #{socket}")

directory_data = [socket]

iofd "login as test_user" do |iofd|
    iofd.directory_data_in_test = directory_data
    iofd.io_contents = [
        { output: "#{user_name}>", input: "exit" }
    ]
    iofd.directories = ["#{socket}/#{user_name}"]
    iofd
end