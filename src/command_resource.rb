class CommandResource

  def initialize(n, p)
    @name = n
    @power = p
    @tags = []
  end

  def getName()
    @name
  end

  def getPower()
    @power
  end

  def getCategory()
    ary = @tags.dup
    c = ary.shift().getCategory()
    for t in ary do
      c += "/" + t.getCategory()
    end
    c
  end

  def getRating()
    r = 0
    for t in @tags do
      r += t.getRating()
    end
    r
  end

  def addTag(t)
    @tags.push(t)
    self
  end

  def getTags()
    @tags
  end

  def getCost()
    adj = [-8, -6, -4, -2, 0, 2, 4, 6, 8]
    c = @power * self.getRating() + adj[@power - 1]
  end

end
