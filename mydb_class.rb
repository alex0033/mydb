# アプリの状態を保持するクラス
# アプリの状態とは：例↓
# ・ユーザー名は誰か
# ・使っている(use)データベースはどれか
class MyDB
    def initialize(user_name, socket)
        @user_name = user_name
        socket.delete_suffix! "/"
        @socket = socket
        @user_directory = "#{socket}/#{user_name}"
        Dir.mkdir @user_directory unless Dir.exist?(@user_directory)
    end

    def exec
        while check_command do
        end
    end

    private

    # この関数名は分かりにくい
    def set_values(thing, name)
        # 適切なデータベースディレクトリへのパスが入る
        database_directroy = "#{@user_directory}/#{@database_name || name}"
        # nilにナルのかテストが必要
        table_file = thing == "table" ? "#{database_directroy}/#{name}.csv" : nil
        return database_directroy, table_file
    end

    def print_input_assist
        print "#{@user_name}>"
        print "#{@database_name}>" if @database_name
    end

    def create(thing, name)
        database_directroy, table_file = set_values(thing, name)
        # == と && の優先順位、Dir.existの反対コマンドの存在
        if thing == "database" && @database_name.nil? && !Dir.exist?(database_directroy)
            Dir.mkdir database_directroy
        elsif thing == "table" && table_file && !File.exist?(table_file)
            open(table_file, "w") do |f|
                f.puts "id&SP&created_at&SP&updated_at"
            end
        else
            puts "\"create\"以後の書き方に誤りがあります。"
        end
    end

    def drop(thing, name)
        database_directroy, table_file = set_values(thing, name)
        # == と && の優先順位、Dir.existの反対コマンドの存在
        if thing == "database" && Dir.exist?(database_directroy)
            Dir.rmdir database_directroy
            @database_name = nil if @database_name == name
        elsif thing == "table" && @database_name && File.exist?(table_file)
            File.delete table_file
        else
            puts "\"drop\"以後の書き方に誤りがあります。"
        end
    end

    def use(name)
        database_directroy = "#{@user_directory}/#{name}"
        if Dir.exist?(database_directroy)
            @database_name = name
        else
            puts "そのようなデータベースは存在しません"
        end
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
end