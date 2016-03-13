$LOAD_PATH.unshift '../lib'

require 'write_tag'

require_relative '../spec_helper'

require 'strscan'

describe WriteTag do
  subject { WriteTag.new(translator, output, tag_name, tag_class) }
  let(:translator) { FakeTranslator.new }
  let(:output) { StringIO.new }
  let(:tag_name) { 'foo' }
  let(:tag_class) { 'bar' }

  it 'writes the open tag with the tag class' do
    subject.execute
    output.string.must_equal "<#{tag_name} class='#{tag_class}'>"
  end

  describe 'tells translator to' do
    let(:translator) { MiniTest::Mock.new }
    it 'finish the current command, copy the argument, and write the end tag' do
      translator.expect :finish_current_command, nil
      translator.expect :write_text, nil, ["</#{tag_name}>"]
      translator.expect :copy_argument, nil
      subject.execute
      translator.verify
    end
  end
end