require './iofd_test/test_core.rb'

user_name = "test_user"
socket = "test_user_dir"
user_dir = "#{socket}/#{user_name}"
database_name = "database_name"
table_name = "table_name"
set_cmd("mydb.rb #{user_name} #{socket}")

directory_data_at_first_login = [socket]
directory_data_logged_in = [socket, user_dir]
directory_data_with_database = [socket, user_dir, "#{user_dir}/#{database_name}"]
file_data_with_table = [{
    to: "#{user_dir}/#{database_name}/#{table_name}.csv",
    from: "iofd_test/file_data/#{table_name}"
}]

# このpart内にputsを置くことで見やすくできる余地あり
def part(part_name)
    yield
end

part "first" do
    iofd "login as test_user" do |iofd|
        iofd.directory_data_in_test = directory_data_at_first_login
        iofd.io_contents = [
            { output: "#{user_name}>", input: "exit" }
        ]
        iofd.directories = [user_dir]
        iofd
    end

    iofd "erorr command" do |iofd|
        iofd.directory_data_in_test = directory_data_at_first_login
        iofd.io_contents = [
            { output: "#{user_name}>", input: "error command" },
            { output: "そのコマンドは使えません" },
            { output: "#{user_name}>", input: "exit" }
        ]
        iofd.directories = [user_dir]
        iofd
    end    
end

part "create" do
    part "create database" do
        iofd "create database database_name" do |iofd|
            iofd.directory_data_in_test = directory_data_logged_in
            iofd.io_contents = [
                { output: "#{user_name}>", input: "create database #{database_name}" },
                { output: "#{user_name}>", input: "exit" }
            ]
            iofd.directories = ["#{user_dir}/#{database_name}"]
            iofd
        end

        iofd "create database database_name again" do |iofd|
            iofd.directory_data_in_test = directory_data_with_database
            iofd.io_contents = [
                { output: "#{user_name}>", input: "create database #{database_name}" },
                { output: "\"create\"以後の書き方に誤りがあります。", input: nil },
                { output: "#{user_name}", input: "exit" }
            ]
            iofd.directories = ["#{user_dir}/#{database_name}"]
            iofd
        end
    end
 
    part "create table" do
        iofd "create table table_name" do |iofd|
            iofd.directory_data_in_test = directory_data_with_database
            iofd.io_contents = [
                { output: "#{user_name}>", input: "use #{database_name}" },
                { output: "#{user_name}>#{database_name}>", input: "create table #{table_name}" },
                { output: "#{user_name}>#{database_name}>", input: "exit" }
            ]
            iofd.files = [{ 
                original: "#{user_dir}/#{database_name}/#{table_name}.csv",
                comparison: "/iofd_test/comparison_files/#{table_name}"
            }]
            iofd
        end
    end

    part "create another" do
        iofd "create miss_spell aaa" do |iofd|
            iofd.directory_data_in_test = directory_data_at_first_login
            iofd.io_contents = [
                { output: "#{user_name}>", input: "create miss_spell aaa" },
                { output: "\"create\"以後の書き方に誤りがあります。", input: nil },
                { output: "#{user_name}", input: "exit" }
            ]
            iofd
        end   
    end
end

part "drop" do
    part "drop database" do
        iofd "drop database database_name when use database_name" do |iofd|
            iofd.directory_data_in_test = directory_data_with_database
            iofd.io_contents = [
                { output: "#{user_name}>", input: "use #{database_name}" },
                { output: "#{user_name}>#{database_name}>", input: "drop database #{database_name}" },
                { output: "#{user_name}", input: "exit" }
            ]
            iofd.remove_directories = ["#{user_dir}/#{database_name}"]
            iofd
        end
        
        iofd "drop database database_name when not use database" do |iofd|
            iofd.directory_data_in_test = directory_data_with_database
            iofd.io_contents = [
                { output: "#{user_name}>", input: "drop database #{database_name}" },
                { output: "#{user_name}", input: "exit" }
            ]
            iofd.remove_directories = ["#{user_dir}/#{database_name}"]
            iofd
        end
        
        iofd "drop database database_name when database_name not exist" do |iofd|
            iofd.directory_data_in_test = directory_data_at_first_login
            iofd.io_contents = [
                { output: "#{user_name}>", input: "drop database #{database_name}" },
                { output: "\"drop\"以後の書き方に誤りがあります。" },
                { output: "#{user_name}", input: "exit" }
            ]
            iofd
        end
    end
 
    part "drop table" do
        iofd "drop table table_name" do |iofd|
            iofd.directory_data_in_test = directory_data_with_database
            iofd.file_data_in_test = file_data_with_table
            iofd.io_contents = [
                { output: "#{user_name}>", input: "use #{database_name}" },
                { output: "#{user_name}>#{database_name}>", input: "drop table #{table_name}" },
                { output: "#{user_name}>#{database_name}>", input: "exit" }
            ]
            iofd.remove_files = ["#{user_dir}/#{database_name}/#{table_name}.csv"]
            iofd
        end        
    end

    part "drop another" do
        iofd "drop miss_spell aaa" do |iofd|
            iofd.directory_data_in_test = directory_data_at_first_login
            iofd.io_contents = [
                { output: "#{user_name}>", input: "drop miss_spell aaa" },
                { output: "\"drop\"以後の書き方に誤りがあります。" },
                { output: "#{user_name}", input: "exit" }
            ]
            iofd
        end        
    end
end

part "use" do
    iofd "use database_name" do |iofd|
        iofd.directory_data_in_test = directory_data_with_database
        iofd.io_contents = [
            { output: "#{user_name}>", input: "use #{database_name}" },
            { output: "#{user_name}>#{database_name}>", input: "exit" }
        ]
        iofd.directories = ["#{user_dir}/#{database_name}"]
        iofd
    end    
end
