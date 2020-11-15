name = ARGV[0]
socket = ARGV[1].to_s.dup
socket.delete_suffix! "/"
# database_nameの値に何が入っているかで、データベースが選択される
database_name = nil
user_directory = "#{socket}/#{name}"
Dir.mkdir user_directory unless Dir.exist?(user_directory)
puts ARGV.inspect

while true do
    print "#{name}>"
    print "#{database_name}>" if database_name
    line = STDIN.gets
    orders = line.split(" ")
    command = orders[0]
    case command
    when "create"
        # 共通化？？①
        thing = orders[1]
        name = orders[2]
        database_directroy = "#{user_directory}/#{database_name || name}"
        table_file = "#{database_directroy}/#{name}.csv"
        # == と && の優先順位、Dir.existの反対コマンドの存在
        if thing == "database" && database_name.nil? && !Dir.exist?(database_directroy)
            Dir.mkdir database_directroy
            # データベース名がしっかり作られた場合、データベース名を設定する
            database_name = name if Dir.exist?(database_directroy) &&#file exist?
        elsif thing == "table" && database_name
            open(table_file, "a") do |f|
                f.puts "id&SP&created_at&SP&updated_at"
            end
        else
            # データベースの未設定、ファイルのかぶり、エトセトラのミス
        end
    when "drop"
        # 共通化？？①
        # 怪しい
        thing = orders[1]
        name = orders[2]
        database_directroy = "#{user_directory}/#{database_name || name}"
        table_file = "#{database_directroy}/#{name}.csv"
        # == と && の優先順位、Dir.existの反対コマンドの存在
        if thing == "database" && database_name && Dir.exist?(database_directroy)
            Dir.rmdir database_directroy
            database_name = nil
        elsif thing == "table" && database_name
            # file削除
        else
            # データベースの未設定、ファイルのかぶり、エトセトラのミス
        end
    when "use"
        database_name = orders[1]
        database_directroy = "#{user_directory}/#{database_name}"
        database_name = nil unless Dir.exist?(database_directroy)
    when "exit"
        break;
    else
        puts "そのコマンドは使えません"
    end
    # 下記はリファクタリング前
    # if database_name.nil?
        # case command
        # when "create"
        #     # 共通化？？①
        #     thing = orders[1]
        #     database_name = orders[2]
        #     database_directroy = "#{user_directory}/#{database_name}"
        #     if thing == "database"
        #         if Dir.exist?(database_directroy)
        #             puts "そのデータベースは既に存在しています。"
        #             puts "データベースを選択： use #{database_name}"
        #             database_name = nil
        #             next
        #         end
        #         Dir.mkdir database_directroy
        #         # データベース名が万が一不正だった場合、データベース名を未設定にする
        #         database_name = nil unless Dir.exist?(database_directroy)
        #     end
        # when "drop"
        #     # 共通化？？①
        #     # 怪しい
        #     thing = orders[1]
        #     database_name = orders[2]
        #     database_directroy = "#{user_directory}/#{database_name}"
        #     if thing == "database"
        #         if Dir.exist?(database_directroy)
        #             Dir.rmdir database_directroy
        #             database_name = nil
        #             next
        #         end
        #         puts "そのようなデータベースは既に存在しません。"
        #     end
        # when "use"
        #     database_name = orders[1]
        #     database_directroy = "#{user_directory}/#{database_name}"
        #     database_name = nil unless Dir.exist?(database_directroy)
        # when "exit"
        #     break;
        # else
        #     puts "そのコマンドは使えません"
        #     puts "データベース作成"
        #     puts "データベースを選択"
        # end
    # else
        # case command
        # when "create"
        #     thing = orders[1]
        #     if thing == "table"
        #         table_name = orders[2]
        #         open("#{socket}/#{database_name}/#{table_name}.csv", "a") do |f|
        #             f.puts "id&SP&created_at&SP&updated_at"
        #         end
        #     else
        #         out
        #     end
        # when "exit"
        #     break
        # else
        #     puts "そのコマンドは使えません"
        #     # テーブルに対するヘルプ
        # end 
    # end
end
