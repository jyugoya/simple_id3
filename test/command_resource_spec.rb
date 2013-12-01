require '../src/command_resource'
require '../src/tag'

describe CommandResource do

  desctibe "簡単の初期化" do
    before do
      @cr = CommandResource.new("女である", 4, Tag.new("一般",3));
    end

    it "代入がちゃんとおこなわれている" do
      @cr.getName().should == "女である"
      @cr.getPower().should == 4
    end

    it "簡単なタグの文字列はそのまま" do
      @cr.getTag().getCategory().should == "一般"
      @cr.getTag().getRating().should == 3
    end

    it "コスト計算もばっちり" do
      @cr.getCost().should == 10
    end
  end

  describe "複合タグの時" do
    before do
      t = Tag.new("アクション",4).add("戦闘",1)
      @cr = CommandResource.new("凄い剣技", 3, t);
    end

    it "代入がちゃんとおこなわれている" do
      @cr.getName().should == "凄い剣技"
      @cr.getPower().should == 3
    end

    it "複合タグは合成された文字列に" do
      @cr.getTag().getCategory().should == "アクション/戦闘"
      @cr.getTag().getRating().should == 5
    end

    it "コスト計算もばっちり" do
      @cr.getCost().should == 11
    end
  end
end
