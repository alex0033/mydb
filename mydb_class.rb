# アプリの状態を保持するクラス
# アプリの状態とは：例↓
# ・ユーザー名は誰か
# ・使っている(use)データベースはどれか
class MyDB
    attr_accessor :database_name
    attr_reader :user_name, :user_directory

    def initialize(user_name, socket)
        @user_name = user_name
        socket.delete_suffix! "/"
        @user_directory = "#{socket}/#{user_name}"
        @database_name = nil
        make_user_directory
    end

    def exec
        while check_command do
        end
    end

    private

    def make_user_directory
        Dir.mkdir user_directory unless Dir.exist?(user_directory)
    end

    def check_command
        print_input_assist
        orders = STDIN.gets.split(" ")
        case orders[0]
        when "create"
            create orders[1], orders[2]
        when "drop"
            drop orders[1], orders[2]
        when "use"
            use orders[1]
        when "select"
            # ココからコンパイラのような高度なテキスト処理
        when "exit"
            return false
        else
            puts "そのコマンドは使えません"
        end
        true
    end

    def print_input_assist
        print "#{user_name}>"
        print "#{database_name}>" if database_name
    end

    def create(thing, name)
        if thing == "database" && database_path = make_path_to_create_database(name)
            Dir.mkdir database_path
        elsif thing == "table" && table_path = make_path_to_create_table(name)
            open(table_path, "w") do |f|
                f.puts "id&SP&created_at&SP&updated_at"
            end
        else
            puts "\"create\"以後の書き方に誤りがあります。"
        end
    end

    def drop(thing, name)
        if thing == "database" && database_path = make_path_to_drop_database(name)
            Dir.rmdir database_path
            @database_name = nil if database_name == name
        elsif thing == "table" && table_path = make_path_to_drop_table(name)
            File.delete table_path
        else
            puts "\"drop\"以後の書き方に誤りがあります。"
        end
    end

    def use(name)
        database_directroy = "#{user_directory}/#{name}"
        if Dir.exist?(database_directroy)
            # @database_name = name OR self.database_name = name
            @database_name = name
        else
            puts "そのようなデータベースは存在しません"
        end
    end

    # 以下４つのメソッドは抽象化の余地あり
    # しかし、可読性の観点からあえてこのままにした
    def make_path_to_create_database(name)
        database_path = database_path name
        if name && !Dir.exist?(database_path)
            return database_path
        end
        nil
    end

    def make_path_to_create_table(name)
        table_path = table_path name
        if name && database_name && !File.exist?(table_path)
            return table_path
        end
        nil
    end

    def make_path_to_drop_database(name)
        database_path = database_path name
        if name && Dir.exist?(database_path)
            return database_path
        end
        nil
    end

    def make_path_to_drop_table(name)
        table_path = table_path name
        if name && database_name && File.exist?(table_path)
            return table_path
        end
        nil
    end

    def database_path(name)
        "#{user_directory}/#{name}"
    end

    def table_path(name)
        "#{user_directory}/#{database_name}/#{name}.csv"
    end
end