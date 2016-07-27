require_relative '../src/undefined_behaviour_exception.rb'
require_relative '../src/method_call.rb'

class Object
  def my_mock(clazz)
    MyMock.new(clazz)
  end

  def call(method)
    MethodCall.new(method)
  end
end

class MyMock
  attr_reader :mocked_class

  def initialize(clazz)
    @mocked_class = clazz
    @mocked_methods = []
    @expected_calls = []
  end

  def when method
    raise 'alto error' unless @mocked_class.method_defined?(method)

    @mocked_methods.push(MockedMethod.new(method))
    @last_method = method
    self
  end

  def returns(ret)
    self.define_singleton_method(@last_method) do |*args|
      check_args(args)
      add_call_for(@last_method, args)
      ret
    end
    method(@last_method).return_value(ret)
  end

  def add_call_for(method, *args)
    # TODO args [[]]
    (0..@expected_calls.count - 1).each do |i|
      aux = @expected_calls.fetch(i)
      if aux.method_to_call == method
        aux.add_call
        aux.add_called_params(args.fetch(0).fetch(0)) unless args.fetch(0).count == 0
      end
    end
  end

  def with(*args)
    (0..args.count - 1).map do |i|
      method(@last_method).args.push(args.fetch(i))
    end
    self
  end

  def check_args args
    raise 'Wrong method call' unless method(@last_method).args.count == args.count
    (0..args.count - 1).each do |i|
      raise 'Wrong method call' unless method(@last_method).args.fetch(i) == args.fetch(i)
    end
  end

  def method_missing(method_name, *arguments, &block)
    raise NoMethodError unless @mocked_class.method_defined?(method_name)
    raise UndefinedBehaviourException
  end

  def method(method)
    @mocked_methods.fetch(@mocked_methods.index(method))
  end

  def expects(call)
    @expected_calls.push(call)
    @expected_calls.last
  end

  def check_expects
    (0..@expected_calls.count - 1).each do |i|
      raise "Unexpected call on " + @expected_calls.fetch(i).method_to_call.to_s unless @expected_calls.fetch(i).check_expects
    end
    true
  end

end

class MockedMethod
  attr_accessor :return_value, :args

  def initialize(method)
    @method = method
    @args = []
  end

  def ==(method_name)
     @method == method_name
  end

  def return_value(ret)
    @return_value = ret
  end
end