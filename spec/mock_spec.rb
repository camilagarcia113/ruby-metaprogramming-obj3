require 'rspec'
require_relative '../src/my_mock.rb'
require_relative '../src/pepita.rb'

describe 'Pepita mock' do

  before (:each) do
    @pepita_mock = my_mock(Pepita)
  end

  it 'should be instantiated correctly as a mock of an instance' do
    expect(@pepita_mock.mocked_class).to be Pepita
    @pepita_mock.kind_of?(MyMock).should be true
  end

   it 'should return whatever it is asked to when mocking a method' do
     @pepita_mock.when(:puede_volar?).returns(true)
     expect(@pepita_mock.puede_volar?).to be true
   end

   it 'should be able to pass parameters to a method mock' do
     @pepita_mock.when(:puede_gastar?).with(40).returns(true)
     expect(@pepita_mock.puede_gastar?(40)).to be true
   end

  it 'should fail when calling a mocked method with wrong arguments' do
    @pepita_mock.when(:puede_gastar?).with(40).returns(true)
    expect{@pepita_mock.puede_gastar?(50)}.to raise_exception RuntimeError
  end

  it 'should raise an error when the mocked object calls an unknown method' do
    expect {
      @pepita_mock.sabarasa
    }.to raise_error NoMethodError
  end

  it 'should raise an error when the mocked object calls a method with undefined behaviour' do
    expect {
      @pepita_mock.puede_volar?
    }.to raise_error UndefinedBehaviourException
  end

  it 'should check if a method was called' do
    @pepita_mock.when(:puede_volar?).returns(false)
    @pepita_mock.expects call :puede_volar?

    @pepita_mock.puede_volar?

    expect(@pepita_mock.check_expects).to be true
  end

  it 'should raise an error when a expected method isnt called' do
    @pepita_mock.when(:puede_volar?).returns(false)
    @pepita_mock.expects call :puede_volar?

    expect{
      @pepita_mock.check_expects
    }.to raise_error RuntimeError
  end

  it 'should check a method was called once' do
    @pepita_mock.when(:puede_volar?).returns(false)
    @pepita_mock.expects call(:puede_volar?).once

    @pepita_mock.puede_volar?

    expect(@pepita_mock.check_expects).to be true
  end

  it 'should raise an error if a method that should be called once is called more than one time' do
    @pepita_mock.when(:puede_volar?).returns(false)
    @pepita_mock.expects call(:puede_volar?).once

    @pepita_mock.puede_volar?
    @pepita_mock.puede_volar?

    @pepita_mock.check_expects
  end

  it 'should check if a method with a certain parameter was called with the same parameter as before' do
    @pepita_mock.when(:volar!).with(20).returns(true)
    @pepita_mock.expects call(:volar!).with_params(20).once()

    @pepita_mock.volar!(20)

    expect(@pepita_mock.check_expects).to be true
  end

  it 'should raise an error when expected method with certain parameters is not called' do
    @pepita_mock.when(:volar!).with(30).returns(true)
    @pepita_mock.expects call(:volar!).with_params(20).once()

    @pepita_mock.volar!(30)

    expect{
      @pepita_mock.check_expects
    }.to raise_error RuntimeError
  end
end