user_name = ARGV[0]
socket = ARGV[1].to_s.dup
socket.delete_suffix! "/"
# database_nameの値に何が入っているかで、データベースが選択される
database_name = nil
user_directory = "#{socket}/#{user_name}"
Dir.mkdir user_directory unless Dir.exist?(user_directory)

# この関数名は分かりにくい
def set_values(thing, name, user_directory, database_name)
    # 適切なデータベースディレクトリへのパスが入る
    database_directroy = "#{user_directory}/#{database_name || name}"
    # nilにナルのかテストが必要
    table_file = thing == "table" ? "#{database_directroy}/#{name}.csv" : nil
    return thing, name, database_directroy, table_file
end

while true do
    print "#{user_name}>"
    print "#{database_name}>" if database_name
    line = STDIN.gets
    orders = line.split(" ")
    command = orders[0]
    case command
    when "create"
        # 共通化？？①
        thing, name, database_directroy, table_file = set_values(orders[1], orders[2], user_directory, database_name)
        # == と && の優先順位、Dir.existの反対コマンドの存在
        if thing == "database" && database_name.nil? && !Dir.exist?(database_directroy)
            Dir.mkdir database_directroy
        elsif thing == "table" && table_file && !File.exist?(table_file)
            open(table_file, "a") do |f|
                f.puts "id&SP&created_at&SP&updated_at"
            end
        else
            puts "\"create\"以後の書き方に誤りがあります。"
        end
    when "drop"
        # 共通化？？①
        # 怪しい
        thing, name, database_directroy, table_file = set_values(orders[1], orders[2], user_directory, database_name)
        # == と && の優先順位、Dir.existの反対コマンドの存在
        if thing == "database" && Dir.exist?(database_directroy)
            Dir.rmdir database_directroy
            database_name = nil if database_name == name
        elsif thing == "table" && database_name
            # file削除
        else
            puts "\"drop\"以後の書き方に誤りがあります。"
        end
    when "use"
        name = orders[1]
        database_directroy = "#{user_directory}/#{name}"
        # elseの情報があると親切
        database_name = name if Dir.exist?(database_directroy)
    when "select"
        # ココからコンパイラのような高度なテキスト処理
    when "exit"
        break
    else
        puts "そのコマンドは使えません"
    end
end
