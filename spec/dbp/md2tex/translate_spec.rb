require_relative '_helper'
require 'dbp/book_compiler/markdown_to_tex/translator'

module DBP::BookCompiler::MarkdownToTex
  describe Translator do
    subject { Translator.new(reader, writer) }
    let(:reader) { StringScanner.new(input) }
    let(:writer) { StringIO.new }

    describe 'wraps' do
      describe 'div.class' do
        let(:content) { 'some content' }
        let(:environment) { 'foo' }
        let(:input) { %Q{<div class="#{environment}">#{content}</div>} }

        it 'in the environment specified by the div class' do
          subject.translate

          _(writer.string).must_equal "\\begin{#{environment}}#{content}\\end{#{environment}}"
        end
      end

      describe 'span.class' do
        let(:content) { 'some content' }
        let(:macro) { 'foo' }
        let(:input) { %Q{<span class="#{macro}">#{content}</span>} }

        it 'in a call to the macro specified by the span class' do
          subject.translate

          _(writer.string).must_equal "\\#{macro}{#{content}}"
        end
      end
    end

    describe 'copies' do
      let(:input) { %q{A bunch of text that doesn't include any operators} }

      it 'non-operator text' do
        subject.translate

        _(writer.string).must_equal input
      end
    end

    describe 'extracts' do

      describe 'comment content' do
        let(:input) { '<!-- \somecommand{some argument} -->' }

        it 'as plain text' do
          subject.translate

          _(writer.string).must_equal '\somecommand{some argument}'
        end
      end

      describe 'style and title yaml header properties' do
        let(:style) { 'chapter' }
        let(:title) { 'My Title' }
        let(:input) do
          [
              '---',
              "style: #{style}",
              "title: #{title}",
              '...',
          ].join($/)
        end

        it 'as a style macro' do
          subject.translate

          _(writer.string).must_equal "\\#{style}{#{title}}"
        end
      end
    end

    describe 'rejects' do
      let(:input) { 'some okay text<WHATISTHIS?' }
      it 'a string starting with < that does not match any other token pattern' do
        err = -> { subject.translate }.must_raise RuntimeError
        err.message.must_match '<WHATISTHIS?'
      end
    end

    describe 'replaces' do
      describe '<br/>' do
        let(:input) { '<br/>' }

        it 'with \break' do
          subject.translate

          _(writer.string).must_equal '\break '
        end
      end
    end

    describe 'toggles' do
      describe 'emphasis' do
        let(:input) { 'regular _emphasized_ regular' }

        it 'by calling \emph{} with surrounded text' do
          subject.translate

          _(writer.string).must_equal "regular \\emph{emphasized} regular"
        end
      end

      describe 'bold' do
        let(:input) { 'regular **bold** regular' }

        it 'by calling \bf{} with surrounded text' do
          subject.translate

          _(writer.string).must_equal "regular \\bf{bold} regular"
        end
      end
    end
  end
end
