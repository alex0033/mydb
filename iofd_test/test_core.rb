require './iofd_test/iofd_class.rb'

def set_cmd(file_name)
    Iofd.set_command("ruby #{file_name}")
end

class String
    def colorize(color_code)
      "\e[#{color_code}m#{self}\e[0m"
    end

    def red
      colorize(31)
    end

    def green
      colorize(32)
    end

    def yellow
      colorize(33)
    end

    def pink
      colorize(35)
    end
end

def iofd(test_name)
    puts "始--------始"
    iofd = Iofd.new test_name
    iofd = yield iofd
    iofd.exec_test
    puts "終--------終"
    puts
end
