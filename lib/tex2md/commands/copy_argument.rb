require_relative 'command.rb'

module TeX2md
  class CopyArgument
    include Command

    def initialize(name)
      @name = name
      @pattern = /{/
    end

    def transition(translator, _)
      translator.copy_argument
    end

    def to_s
      "#{self.class}(#{name})"
    end
  end
end