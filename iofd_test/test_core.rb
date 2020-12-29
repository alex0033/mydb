require './iofd_test/iofd_class.rb'

def set_cmd(file_name)
    Iofd.set_command("ruby #{file_name}")
end

def iofd(test_name)
    puts "始--------始"
    iofd = Iofd.new test_name
    iofd = yield iofd
    iofd.exec_test
    puts "終--------終"
    puts
end
