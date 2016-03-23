require_relative '../spec_helper'

require 'commands/copy_text'

require 'strscan'

describe CopyText do
  subject { CopyText.new pattern }
  let(:translator) { FakeTranslator.new }
  let(:reader) { StringScanner.new(input) }
  let(:writer) { StringIO.new }

  describe 'when input begins with a match for the copy pattern' do
    let(:pattern) { /[[:alnum:]]*/ }
    let(:input) { 'stuff1234,.!:' }

    it 'consumes the matching text' do
      subject.execute(translator, reader, writer)

      reader.rest.must_equal ',.!:'
    end

    it 'writes the matching text' do
      subject.execute(translator, reader, writer)

      writer.string.must_equal 'stuff1234'
    end

    describe 'tells translator to' do
      let(:translator) { MiniTest::Mock.new }
      after { translator.verify }

      it 'read a command' do
        translator.expect :read_command, nil

        subject.execute(translator, reader, writer)
      end
    end
  end

  describe 'when input begins with a mismatch for the copy pattern' do
    let(:pattern) { /[[:punct:]]/ }
    let(:input) { 'A bunch of text with no punctuation' }


    it 'consumes no input' do
      subject.execute(translator, reader, writer)

      reader.rest.must_equal input
    end

    it 'writes no output' do
      subject.execute(translator, reader, writer)

      writer.string.must_be_empty
    end

    describe 'tells translator to' do
      let(:translator) { MiniTest::Mock.new }
      after { translator.verify }

      it 'read a command' do
        translator.expect :read_command, nil

        subject.execute(translator, reader, writer)
      end
    end
  end
end
