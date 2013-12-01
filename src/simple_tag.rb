require '../src/simple_tag'

# Composite Pattern にすべきかもと思いつつ、とりあえずただのコンポジットで
class Tag

  def initialize(tagcat, tagrate) # SimpleTagをひとつは取る
    @tags = [SimpleTag.new(tagcat, tagrate)]
  end

  def add(tagcat, tagrate)
    @tags << SimpleTag.new(tagcat, tagrate)
    self
  end

  def getCategory()
    ary = @tags.dup
    cat = ary.shift().getCategory()
    for t in ary do
      cat += "/" + t.getCategory()
    end
    cat
  end

  def getRating()
    rat = 0
    for t in @tags do
      rat += t.getRating()
    end
    rat
  end

end
