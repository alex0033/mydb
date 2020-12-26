name = ARGV[0]
socket = ARGV[1].to_s.dup
socket.delete_suffix! "/"
# database_nameの値に何が入っているかで、データベースが選択される
database_name = nil
user_directory = "#{socket}/#{name}"
Dir.mkdir user_directory unless Dir.exist?(user_directory)
puts ARGV.inspect

def set_values(thing, name, database_name)
    database_directroy = "#{user_directory}/#{database_name || name}"
    # nilにナルのかテストが必要
    table_file = "#{database_directroy}/#{name}.csv" if thing == "table"
    return thing, name, database_directroy, table_file
end

while true do
    print "#{name}>"
    print "#{database_name}>" if database_name
    line = STDIN.gets
    orders = line.split(" ")
    command = orders[0]
    case command
    when "create"
        # 共通化？？①
        thing, name, database_directroy, table_file = set_values(orders[1], orders[2], database_name)
        # == と && の優先順位、Dir.existの反対コマンドの存在
        if thing == "database" && database_name.nil? && !Dir.exist?(database_directroy)
            Dir.mkdir database_directroy
            # データベース名がしっかり作られた場合、データベース名を設定する
            # elseの情報があると親切
            # 仕様：データベースを作っても自動接続しない設定にしよ
            # database_name = name if Dir.exist?(database_directroy)# && file exist?
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
        thing, name, database_directroy, table_file = set_values(orders[1], orders[2], database_name)
        # == と && の優先順位、Dir.existの反対コマンドの存在
        if thing == "database" && Dir.exist?(database_directroy)
            Dir.rmdir database_directroy
            database_name = nil if database_name == name
        elsif thing == "table" && database_name
            # file削除
        else
            # データベースの未設定、ファイルのかぶり、エトセトラのミス
        end
    when "use"
        name = orders[1]
        database_directroy = "#{user_directory}/#{name}"
        # elseの情報があると親切
        database_name = name if Dir.exist?(database_directroy)
    when "select"
        # ココからコンパイラのような高度なテキスト処理
    when "exit"
        break;
    else
        puts "そのコマンドは使えません"
    end
end
