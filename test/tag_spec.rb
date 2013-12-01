require '../src/tag'

describe Tag, "when initialized with arguments" do

  before do
    @t = Tag.new("一般", 3)
  end

  it "should be initialized correctly" do
    @t.getCategory().should == "一般"
    @t.getRating().should == 3
  end

end

describe "When add with a new tag with arguments" do
  before do
    @t = (Tag.new("戦闘", 1)).add("攻撃", 4)
  end

  it "should be initialized correctly" do
    @t.getCategory().should == "戦闘/攻撃"
    @t.getRating().should == 5
  end
end
