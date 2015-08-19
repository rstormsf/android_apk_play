require 'rspec'


RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
end

describe 'My behaviour' do

  it 'should do something', :something do
    puts ENV["USER_ID"]
    true.should == true
  end
end