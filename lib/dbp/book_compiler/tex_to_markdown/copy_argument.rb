require_relative 'command.rb'

module DBP::BookCompiler::TexToMarkdown
  class CopyArgument
    include Command

    def initialize(name)
      @name = name
      @pattern = /{/
    end

    def transition(translator, _)
      translator.copy_argument_text
    end

    def to_s
      "#{self.class}(#{name})"
    end
  end
end