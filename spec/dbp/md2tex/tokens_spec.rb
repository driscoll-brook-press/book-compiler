require_relative '_helper'
require 'dbp/book_compiler/markdown_to_tex/translator'

module DBP::BookCompiler::MarkdownToTex
  describe Translator, 'tokens' do
    describe 'BODY_TEXT' do
      subject { Translator::BODY_TEXT }

      describe :pattern do
        let(:pattern) { subject[:pattern] }

        describe 'against a string with no operator characters' do
          it 'matches the entire string' do
            input = 'a bunch of text'
            pattern =~ input
            _($&).must_equal input
          end

          it 'captures the entire match' do
            input = 'a bunch of text'
            pattern =~ input
            _($1).must_equal input
          end
        end

        %w{< * _}.each do |c|
          describe "against a string with operator character #{c}" do
            it 'stops matching at the operator character' do
              input = "before#{c}after"
              pattern =~ input
              _($&).must_equal 'before'
            end

            it 'captures the entire match' do
              input = "before#{c}after"
              pattern =~ input
              _($1).must_equal 'before'
            end
          end
        end

        describe :command do
          let(:command) { subject[:command] }
          let(:translator) { MiniTest::Mock.new }

          after { translator.verify }

          it 'writes the capture' do
            capture = 'some capture'

            translator.expect :write, nil, [capture]
            command.call(translator, capture)
          end
        end
      end
    end

    describe 'COMMENT_CONTENT' do
      subject { Translator::COMMENT_CONTENT }

      describe :pattern do
        let(:pattern) { subject[:pattern] }

        describe 'against a string with a comment' do
          it 'matches through the end of the comment' do
            input = '<!--some comment-->after'
            pattern =~ input
            _($&).must_equal '<!--some comment-->'
          end

          it 'captures the stripped comment content' do
            input = '<!--                        some comment   -->'
            pattern =~ input
            _($1).must_equal 'some comment'
          end
        end

        describe :command do
          let(:command) { subject[:command] }
          let(:translator) { MiniTest::Mock.new }

          after { translator.verify }

          it 'writes the capture' do
            capture = 'some capture'

            translator.expect :write, nil, [capture]
            command.call(translator, capture)
          end
        end
      end
    end

    describe 'BR_TAG' do
      subject { Translator::BR_TAG }

      describe :pattern do
        let(:pattern) { subject[:pattern] }

        describe 'against a string with a <br/> tag' do
          it 'matches through the end of the tag' do
            input = '<br    />after'
            pattern =~ input
            _($&).must_equal '<br    />'
          end
        end

        describe :command do
          let(:command) { subject[:command] }
          let(:translator) { MiniTest::Mock.new }

          after { translator.verify }

          it 'writes a \break macro' do
            translator.expect :write, nil, ['\break ']
            command.call(translator, 'ignored capture')
          end
        end
      end
    end
  end
end
