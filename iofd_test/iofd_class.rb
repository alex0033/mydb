require 'pty'
require 'expect'
require 'fileutils'

class Iofd
    attr_writer :io_contents, :files, :remove_files,
                :directories, :remove_directories,
                :file_data_in_test, :directory_data_in_test

    def initialize(test_name)
        @test_name = test_name
        @io_contents = []
        @files = []
        @remove_files = []
        @directories = []
        @remove_directories = []
        @error_contents = []
        @file_data_in_test = []
        @directory_data_in_test = []
    end

    def self.set_command(cmd)
        @@cmd = cmd
    end

    def exec_test
        in_test_environment do
            all_tests
        end
    end

    private

    def test_error
        puts "fail #{@test_name}".red
        @error_contents.each do |content|
            puts "**#{content}"
        end
    end

    def test_error?
        @error_contents.any?
    end

    def in_test_environment
        original_dir = Dir::pwd
        # コピーディレクトリ作成準備
        Dir::chdir ".."
        copy_dir = "#{Dir::pwd}/copy_dir"
        if Dir.exist? copy_dir || original_dir == copy_dir
            @error_contents.push "テスト環境が準備できません"
            test_error
            Dir::chdir original_dir
            return
        end
        # コピーディレクトリ作成と移動
        FileUtils.cp_r original_dir, copy_dir
        Dir::chdir copy_dir
        # 下記でtestを実施
        in_test_data do
            begin
                test_error? ? test_error : yield
            rescue => error
                @error_contents.push error
                test_error
            end
        end
        # 状態のリセット
        Dir::chdir ".."
        FileUtils.rm_rf copy_dir
        Dir::chdir original_dir
    end

    def in_test_data
        make_test_data
        yield
        remove_test_data
        
    end

    def make_test_data
        @directory_data_in_test.each do |d|
            Dir.exist?(d) ? @error_contents.push("ディレクトリのデータエラー") : Dir.mkdir(d)
        end
        @file_data_in_test.each do |f|
            if File.exist?(f[:to])
                @error_contents.push("ファイルのデータエラー")
            elsif f[:from]
                FileUtils.cp f[:from], f[:to]
            else
                FileUtils.touch(f[:to])
            end
        end
    end

    def remove_test_data
        @file_data_in_test.each do |f|
            File.delete f[:to] if File.exist? f[:to]
        end
        @directory_data_in_test.each do |d|
            FileUtils.rm_rf d if Dir.exist? d
        end
    end

    def all_tests
        io_contents_test
        files_test
        directories_test
        remove_files_test
        remove_directories_test
        test_error? ? test_error : puts("success #{@test_name}".green)
    end

    def io_contents_test
        begin
            PTY.getpty(@@cmd) do |i, o, pid|
                @io_contents.each do |content|
                    expected_output = content[:output]
                    expected_input = content[:input]
                    i.expect(expected_output, 10) do |line|
                        # 以下二行で正確な文字列チェック
                        output = line[0].gsub(/[\n\r]/,"")
                        @error_contents.push "期待値：#{expected_output} 実際：#{output}" unless output == expected_output
                        # 下記if文の塊のおかげで
                        if expected_input
                            o.puts expected_input
                            i.expect expected_input
                        end
                    end
                end
                # 下記コードでコマンドの終了待ち
                # これによりディレクトリやファイル作成が反映される
                Process.wait pid
            end
        rescue => error
            @error_contents.push error
        end
    end

    def files_test
        # filesの存在確認、内容一致の確認ー＞存在しない、内容不一致だとエラーになる
        @files.each do |f|
            if !File.exist?(f[:original])
                @error_contents.push "#{f[:original]}が存在しません"
            elsif f[:comparison] && File.exist?(f[:comparison]) && !FileUtils.cmp(f[:original], f[:comparison])
                @error_contents.push "#{f[:comparison]}と内容が一致しません"
            end
        end
    end

    def directories_test
        # directoriesの存在確認ー＞存在しないとエラーになる
        @directories.each do |d|
            unless Dir.exist?(d)
                @error_contents.push "#{d}が存在しません"
            end
        end
    end
    
    def remove_files_test
        # remove_filesの存在確認ー＞存在するとエラーになる
        @remove_files.each do |f|
            if File.exist?(f)
                @error_contents.push "#{f}が削除できていません"
            end
        end
    end

    def remove_directories_test
        # remove_directoriesの存在確認ー＞存在するとエラーになる
        @remove_directories.each do |d|
            if Dir.exist?(d)
                @error_contents.push "#{d}が削除できていません"
            end
        end
    end
end
