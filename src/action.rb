require '../src/command_resource'

class Action

  def initialize(n, evf, rpf, crs) # SimpleTagをひとつは取る
    @name = n
    @eval_flag = evf
    @roleplay_flag = rpf
    @commands = crs
  end

  def add(cr)
    # @commands << SimpleTag.new(tagcat, tagrate)
  end

  def getName()
    @name
  end

  def getCommand(index)
    @commands[index]
  end

  def requiredEvaluation()
    @eval_flag
  end

  def requiredRolePlaying()
    @roleplay_flag
  end

  def getCategory()
    cats = []
    for cr in @commands do
      # cats[cr.getTag().getCategory()] +=1
    end
    cr.getCategory()
  end

  def getRank(roleplay)
    if @roleplay_flag && roleplay then
      @commands.size * 100
    else
      getTagCommands().size * 100
    end
  end

  def getTagCommands()
     @commands
  end

  def getPower()
    power = 0
    for c in @commands do
      power += c.getPower()
    end
    power + @commands.size * 2
    power * 2.5
  end

  def getRisk()
    0
  end

end
