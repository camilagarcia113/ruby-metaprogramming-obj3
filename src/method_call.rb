class MethodCall
  attr_accessor :method_to_call

  def initialize(method)
    @calls = 0
    @once = false
    @method_to_call = method
    @expected_params = []
    @called_params = []
  end

  def once
    @once = true
    self
  end

  def add_call
    @calls += 1
  end

  def add_called_params(*args)
    (0..args.count - 1).each do |i|
      @called_params.push(args.fetch(i))
    end
  end

  def check_expects
    ((@once & @calls == 1) || (@calls > 0)) & check_params
  end

  def check_params
    return false unless @expected_params.count == @called_params.count
    (0..@expected_params.count - 1).each do |i|
      return false unless @expected_params.fetch(i) == @called_params.fetch(i)
    end
    true
  end

  def with_params(*params)
    (0..params.count - 1).each do |i|
      @expected_params.push(params.fetch(i))
    end
    self
  end
end