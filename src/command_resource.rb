class CommandResource

  def initialize(n, p, t)
    @name = n
    @power = p
    @tag = t
  end

  def getName()
    @name
  end

  def getPower()
    @power
  end

  def getTag()
    @tag
  end

  def getCost()
    adj = [-8, -6, -4, -2, 0, 2, 4, 6, 8]
    c = @power * @tag.getRating() + adj[@power - 1]
  end

end
