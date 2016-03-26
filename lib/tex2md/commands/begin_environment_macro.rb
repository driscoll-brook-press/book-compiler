require_relative 'command.rb'

module TeX2md
  class BeginEnvironmentMacro
    include Command

    def initialize
      @name = 'begin'
      @pattern = /{([[:alpha:]]+)}/
    end

    def write(writer, environment_name)
      writer.write("<div class='#{environment_name}'>")
    end

    def transition(translator, _)
      translator.copy_text
    end

    def to_s
      "#{self.class}"
    end
  end
end