﻿require '../src/command_resource'
require '../src/tag'

#　戦力が１　コストは－８される。
#　戦力が２　コストは－６される。
#　戦力が３　コストは－４される。
#　戦力が４　コストは－２される。
#　戦力が５　コストは変動しない。
#　戦力が６　コストは＋２される。
#　戦力が７　コストは＋４される。
#　戦力が８　コストは＋６される。
#　戦力が９　コストは＋８される。

describe CommandResource do

  describe "タグがひとつの時" do
    before do
      @cr = CommandResource.new("女である", 4).addTag(Tag.new("一般",3))
    end

    it "代入のみ初期化のチェック" do
      @cr.getName().should == "女である"
      @cr.getPower().should == 4
    end

    it "簡単なタグのカテゴリはそのままカテゴリになる" do
      @cr.getCategory().should == "一般"
    end

    it "簡単なタグのレーティングはそのままレーティングになる" do
      @cr.getRating().should == 3
    end

    it "コストはそのコマンドリソースのパワー(4)*レーティング(3)にパワーによる補正値（-2）を足したもの " do
      @cr.getCost().should == 10
    end

  end

  describe "タグが複数ある時" do
    before do
      t1 = Tag.new("アクション",4)
      t2 = Tag.new("戦闘",1)
      @cr = CommandResource.new("凄い剣技", 3).addTag(t1).addTag(t2)
    end

    it "代入がちゃんとおこなわれている" do
      @cr.getName().should == "凄い剣技"
      @cr.getPower().should == 3
    end

    it "カテゴリは全タグのカテゴリが合成された文字列になる" do
      @cr.getCategory().should == "アクション/戦闘"
    end

    it "レーティングは全タグのレーティングの総和になる" do
      @cr.getRating().should == 5
    end

    it "コストはそのコマンドリソースのパワー(3)*レーティング(5)にパワーによる補正値（-4）を足したもの " do
      @cr.getCost().should == 11
    end
  end
end
