# -*- encoding: utf-8 -*-

class CommandResource

  def initialize(i, n, p)
    @id = i
    @name = n
    @power = p
    @tags = []
  end

  def getID()
    @id
  end

  def getName()
    @name
  end

  def setName(n)
    @name = n
  end

  def getPower()
    @power
  end

  def setPower(p)
    @power = p
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
    if t == nil then raise "Nil tag cannot be added!" end
    @tags.push(t)
    self
  end

  def removeTag(c)
    for t in @tags
      if t.getCategory() then
        @tags.delete(t)
        break;
      end
    end
  end

  def getTags()
    @tags
  end

  def getCost()
    adj = [-8, -6, -4, -2, 0, 2, 4, 6, 8]
    c = @power * self.getRating() + adj[@power - 1]
  end

end
