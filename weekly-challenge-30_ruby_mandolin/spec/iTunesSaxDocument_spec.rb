require_relative '../ITunesSaxDocument.rb'

describe ITunesSaxDocument do

  before do
    @sut = ITunesSaxDocument.new
  end

  after do
  end

  it 'should work' do
    expect(@sut.test).to eq 'tested'
  end
end