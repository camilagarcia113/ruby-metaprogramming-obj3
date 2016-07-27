class Pepita
  def initialize
    @energia = 10
  end

  def puede_volar?
    puede_gastar?(10)
  end

  def puede_gastar?(esfuerzo)
    @energia >= esfuerzo
  end

  def volar!
    raise 'no hay suficiente energia' unless puede_volar?
    @energia -= 10
  end
end 
