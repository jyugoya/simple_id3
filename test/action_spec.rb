# -*- encoding: utf-8 -*-
require '../src/action'
require '../src/tag'
require '../src/command_resource'

describe Action do
  describe "３つのＣＲからなる行動に対して" do
    before do
      t1 = Tag.new("戦闘",1)
      t2 = Tag.new("攻撃",4)
      t3 = Tag.new("アクション",4)
      cr1 = CommandResource.new("名剣", 6).addTag(t1).addTag(t2)
      cr2 = CommandResource.new("短剣", 3).addTag(t1).addTag(t2)
      cr3 = CommandResource.new("肉体派", 3).addTag(t3)
      @a = Action.new("二刀流", true, true).addCR(cr1).addCR(cr2).addCR(cr3)
    end

    it "初期値がちゃんとセットされてるかどうか" do
      @a.getName().should == "二刀流"
      @a.requiredEvaluation().should == true
      @a.requiredRolePlaying().should == true
    end

    it "ＣＲの数は3つになる" do
      @a.getCommandsSize().should == 3
    end

    it "0番目のコマンドリソースは最初に追加したものである" do
      @a.getCR(0).getName().should == "名剣"
    end

    it "ＣＲの数（タグ総数？）の50%以上のタグが行動のタグとなる(複数可能)" do
      @a.getCategory().should == "戦闘/攻撃"
    end

    it "ランクはＲＰがある場合は全ＣＲの数*100である" do
      @a.getRank(true).should == 300
    end

    it "ランクはＲＰがない場合はカテゴリに合致するＣＲの数*100である" do
      @a.getRank(false).should == 200
    end

    # ＣＲあり、アーキタイプあり、事前登録あり（なしでも一緒）
    it "戦力はＲＰがある場合は全ＣＲの戦力の総和(12)にその数*2(6)を加えたもの(18)であり、アーキタイプの場合はさらに2.5倍される（事前登録の場合の2倍についてはアーキタイプが優先される）" do
      @a.getPower(true, true, true).should == 45
    end

    # ＣＲなし、アーキタイプなし、事前登録なし
    it "戦力はＲＰがない場合はカテゴリＣＲの戦力の総和(9)にその数*2(4)を加えたものである（事前登録なしでアーキタイプでもない）" do
      @a.getPower(false, false, false).should == 13
    end

    it "上昇危険度は全ＣＲのコスト総和（32+11+8=51）の1/5（10.2の端数切捨て）である" do
      @a.getRisk().should == 10
    end
  end

  describe "ＣＲが２つの場合" do
    before do
      t1 = Tag.new("アクション",4)
      t2 = Tag.new("解錠",3)
      cr1 = CommandResource.new("手先が器用",3).addTag(t1)
      cr2 = CommandResource.new("解錠師",5).addTag(t2).addTag(t1)
      @a = Action.new("解錠", false, true).addCR(cr1).addCR(cr2)
    end

    it "タグが１つあっても50%以上になるため残る" do
      @a.getCategory().should == "アクション/解錠"
    end
  end

  describe "最大数５つのＣＲからなる行動に対して" do
    before do
      t1 = Tag.new("アクション",4)
      t2 = Tag.new("戦闘",1)
      t3 = Tag.new("魔法",2)
      t4 = Tag.new("攻撃",1)
      t5 = Tag.new("防御",1)
      cr1 = CommandResource.new("ダミー１", 1).addTag(t1)
      cr2 = CommandResource.new("ダミー２", 2).addTag(t2).addTag(t3)
      cr3 = CommandResource.new("ダミー３", 3).addTag(t2).addTag(t4)
      cr4 = CommandResource.new("ダミー４", 4).addTag(t2).addTag(t5)
      cr5 = CommandResource.new("ダミー５", 5).addTag(t1)
      @a = Action.new("ダミー", false, false).addCR(cr1).addCR(cr2).addCR(cr3).addCR(cr4).addCR(cr5)
    end

    it "初期値がちゃんとセットされている" do
      @a.getName().should == "ダミー"
      @a.requiredEvaluation().should == false
      @a.requiredRolePlaying().should == false
    end

    it "5番目のコマンドリソースは最後に追加したものである" do
      @a.getCR(4).getName().should == "ダミー５"
    end

    # ＣＲあり、アーキタイプなし、事前登録あり
    it "戦力はＲＰがある場合は全ＣＲの戦力の総和(15)にその数*2(10)を加えたもの(25)であり、事前登録で2倍になる" do
      @a.getPower(true, false, true).should == 50
    end

    # ＣＲなし、アーキタイプなし、事前登録あり
    it "戦力はＲＰがない場合はカテゴリＣＲの戦力の総和(9)にその数*2(6)を加えたものであり、事前登録で2倍になる" do
      @a.getPower(false, false, true).should == 30
    end

    it "行動はコマンドリソース５つまでを合成して作る。→6つ以上はエラー" do
      t = Tag.new("アクション",4)
      cr = CommandResource.new("ダミーＣＲ", 3).addTag(t)
      proc {
        @a.addCR(cr)
      }.should raise_error
    end
  end
end
