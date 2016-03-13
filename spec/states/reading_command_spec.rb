$LOAD_PATH.unshift '../lib'

require 'reading_command'

require_relative '../spec_helper'

require 'ostruct'
require 'strscan'

describe ReadingCommand do
  subject { ReadingCommand.new(context, scanner, pattern, commands) }
  let(:context) { MiniTest::Mock.new FakeContext.new }
  let(:output) { StringIO.new previous_output }
  let(:previous_output) { 'previous output' }
  let(:scanner) { StringScanner.new input }

  describe 'when the input matches the command name pattern' do
    let(:input) { 'foo123' }
    let(:pattern) { /[[:alpha:]]+/ }

    describe 'and the command table includes a command with the scanned command name' do
      let(:commands) { { 'foo' => 'the foo command' } }

      it 'consumes the matching command name' do
        subject.execute
        scanner.rest.must_equal '123'
      end

      it 'executes the command found in the command table' do
        context.expect :execute_command, nil, [commands['foo']]
        subject.execute
      end
    end

    describe 'and the command table includes no command with the scanned command name' do
      let(:commands) { {} }

      it 'consumes the matching command name' do
        subject.execute
        scanner.rest.must_equal '123'
      end

      it 'pops the context' do
        context.expect :pop, nil
        subject.execute
        context.verify
      end
    end
  end


  describe 'when the input does not match the command pattern' do
    let(:input) { '\macroname{macro argument}' }
  end
end
