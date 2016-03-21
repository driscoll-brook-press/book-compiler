$LOAD_PATH.unshift '../../lib'

require 'translator'

require_relative '../spec_helper'

describe Translator do
  subject { Translator.new('', nil, []) }
  let(:current_command) { subject.stack.last }

  describe 'copy argument' do
    it 'pushes CopyText with the argument pattern' do
      subject.copy_argument

      current_command.must_be_instance_of CopyText
      current_command.pattern.must_equal Translator::ARGUMENT_PATTERN
    end
  end

  describe 'copy text' do
    it 'pushes CopyText with the text pattern' do
      subject.copy_text

      current_command.must_be_instance_of CopyText
      current_command.pattern.must_equal Translator::TEXT_PATTERN
    end
  end

  describe 'finish command' do
    it 'pops one command off the stack' do
      subject.copy_text
      subject.copy_text
      subject.copy_text

      subject.finish_command

      subject.stack.size.must_equal(2)
    end
  end

  describe 'finish document' do
    it 'clears the stack' do
      subject.copy_text
      subject.copy_text
      subject.copy_text

      subject.finish_document

      subject.stack.must_be :empty?
    end
  end

  describe 'read command' do
    describe 'with a pattern' do
      let(:pattern) { /[p.;:]+/}

      it 'pushes ReadCommand with the given pattern' do
        subject.read_command(pattern)

        current_command.must_be_instance_of ReadCommand
        current_command.pattern.must_equal pattern
      end
    end

    describe 'with no pattern' do
      it 'pushes ReadCommand with the command pattern' do
        subject.read_command

        current_command.must_be_instance_of ReadCommand
        current_command.pattern.must_equal Translator::COMMAND_PATTERN
      end
    end
  end
end
