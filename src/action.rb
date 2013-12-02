# -*- encoding: utf-8 -*-
require '../src/command_resource'

class Action

  def initialize(n, evf, rpf)
    @name = n
    @eval_flag = evf
    @roleplay_flag = rpf
    @commands = []
  end

  def getCommandsSize()
    @commands.size
  end

  def addCR(cr)
    @commands << cr
    self
  end

  def getName()
    @name
  end

  def getCR(index)
    @commands[index]
  end

  def requiredEvaluation()
    @eval_flag
  end

  def requiredRolePlaying()
    @roleplay_flag
  end

  def getCategory()
    ctags = getCategoryTags()
    c = ctags.shift().getCategory()
    for t in ctags do 
      c += "/" + t.getCategory()
    end
    c
  end

  def getCategoryTags()
    s = getCommandsSize()
    cats = Hash.new {|cats, key| cats[key] = 0}
    for cr in @commands do
      tags = cr.getTags()
      for t in tags do
        cats[t] += 1
      end
    end
    
    ctags = []
    cats.each{|key, value|
      if value >= (s / 2.0) then
        ctags.push(key)
      end
    }
    ctags
  end

  def getRank(roleplay)
    if @roleplay_flag && roleplay then
      @commands.size * 100
    else
      getCategoryCommands().size * 100
    end
  end

  def getCategoryCommands()
    ctags = getCategoryTags()
    cms = []
    for cr in @commands do
      tags = cr.getTags()
      for t in tags do
        if ctags.index(t) != nil then
          cms.push(cr)
          break
        end
      end
    end
    cms
  end

  def getPower(roleplay, archetype, prereg)
    power = 0

    if roleplay then
      cms = @commands
    else
      cms = getCategoryCommands()
    end

    for c in cms do
      power += c.getPower()
    end
    power += cms.size * 2

    if archetype then
      power = power * 2.5
    elsif prereg then
      power = power * 2
    end

    power
  end

  def getRisk()
    r = 0
    for cr in @commands do
      r += cr.getCost()
    end
    r / 5
  end

end
