# -*- encoding: utf-8 -*-
require '../src/sqlite3_factory'
require '../src/tag'

describe SQLite3Factory do

  before do
    @fname = "../db/test.db"
    @factory = SQLite3Factory.new(@fname)
  end

  describe "初期化と削除処理：" do
    it "データベースの作成と削除が成功する" do
      @factory.createDB()
      File.exist?(@fname).should == true

      @factory.dropDB()
      File.exist?(@fname).should == false
    end
  end

  describe "Tagクラス用テーブルについて" do
    before do
      @factory.createDB()
    end

    it "作成し削除できる" do
      expect{
        @factory.createTagTable()
        @factory.dropTagTable()
      }.to_not raise_error # TODO: Errorの型特定
    end

    describe "テーブルはある状態で" do
      before do
        @factory.createTagTable()
      end

      it "Tagデータを新規に１つ挿入できる" do
        @factory.insertTag(Tag.new("戦闘", 1))
      end

      it "Tagデータを新規作成後取得できる" do
        @factory.insertTag(Tag.new("魔法", 2))
        tag = @factory.getTag("魔法")
        tag.getCategory().should == "魔法"
        tag.getRating().should == 2
      end

      it "Tagデータを更新できる" do
        @factory.insertTag(Tag.new("攻撃", 0))
        tag = @factory.getTag("攻撃")
        tag.getCategory().should == "攻撃"
        tag.getRating().should == 0

        @factory.updateTag(Tag.new("攻撃", 4))
        tag = @factory.getTag("攻撃")
        tag.getRating().should == 4
      end

      it "新規作成したTagデータを削除できる（その後の取得がnilになる）" do
        @factory.insertTag(Tag.new("防御", 4))
        @factory.deleteTag("防御")
        tag = @factory.getTag("防御")
        tag.should == nil
      end

      it "新規作成した3つのTagデータをgetAllTagsを使ってハッシュとして全て取得できる" do
        @factory.insertTag(Tag.new("魔法", 2))
        @factory.insertTag(Tag.new("攻撃", 4))
        @factory.insertTag(Tag.new("防御", 4))

        hash = @factory.getAllTags()
        hash.size.should == 3
        hash["魔法"].getCategory().should == "魔法"
        hash["攻撃"].getCategory().should == "攻撃"
        hash["防御"].getCategory().should == "防御"
      end

      it "同じカテゴリを持つTagデータを新規挿入しようとするとエラーになる" do
        expect {
          @factory.insertTag(Tag.new("防御", 4))
          @factory.insertTag(Tag.new("防御", 3))
        }.to raise_error ( SQLite3::ConstraintException )
      end

      after do
        @factory.dropTagTable()
      end
    end
  end

  describe "CommandResourceクラス用テーブルについて" do
    before do
      @factory.createDB()
    end

    it "作成し削除できる" do
      expect{
        @factory.createTagTable()
        @factory.createAllTablesForCR()
        @factory.dropAllTablesForCR()
        @factory.dropTagTable()
      }.to_not raise_error # TODO: Errorの型特定
    end

    describe "テーブルおよびTagのテーブルとハッシュがある状態で" do
      before do
        @factory.createTagTable()
        @factory.createAllTablesForCR()

        @factory.insertTag(Tag.new("魔法", 2))
        @factory.insertTag(Tag.new("攻撃", 4))
        @factory.insertTag(Tag.new("防御", 4))
        @factory.insertTag(Tag.new("戦闘", 1))
        @factory.insertTag(Tag.new("アクション", 1))
        @tags = @factory.getAllTags()

      end

      it "CRデータを新規に１つ挿入できる" do
        cr = CommandResource.new(1, "ダミー", 0).addTag(@tags['攻撃']).addTag(@tags['魔法'])
        @factory.insertCR(cr)
      end

      it "CRデータを新規作成後取得できる" do
        cr1 = CommandResource.new(1, "ダミー", 0).addTag(@tags['攻撃']).addTag(@tags['魔法'])
        @factory.insertCR(cr1)

        cr2 = @factory.getCR(1, @tags)
        cr2.getID().should == 1
        cr2.getName().should == "ダミー"
        cr2.getPower().should == 0
        tags = cr2.getTags()
        # 順番の保証は実はない
        tags[0].getCategory().should == '攻撃'
        tags[1].getCategory().should == '魔法'
      end

      it "CRデータを変更して更新できる" do
        cr1 = CommandResource.new(1, "ダミー", 0).addTag(@tags['攻撃']).addTag(@tags['魔法'])
        @factory.insertCR(cr1)

        cr1.setName("変更後の文字列")
        cr1.setPower(2)
        cr1.removeTag('攻撃')
        cr1.addTag(@tags['戦闘'])
        cr1.addTag(@tags['アクション'])

        @factory.updateCR(cr1)

        cr2 = @factory.getCR(1, @tags)
        cr2.getID().should == 1
        cr2.getName().should == "変更後の文字列"
        cr2.getPower().should == 2
        tags = cr2.getTags()
        tags.size == 3
        # p tags
      end

      it "新規作成したCRデータを削除できる（その後の取得がnilになる）" do
        cr1 = CommandResource.new(1, "ダミー", 0).addTag(@tags['攻撃']).addTag(@tags['魔法'])
        @factory.insertCR(cr1)
        @factory.deleteCR(1)

        cr2 = @factory.getCR(1, @tags)
        cr2.should == nil
        # TODO: 削除後のcr2tagテーブルの状況もチェックすべき…
      end

      it "新規作成した3つのCRデータをgetAllCRsを使ってハッシュとして全て取得できる" do
        cr1 = CommandResource.new(1, "ダミー１", 3).addTag(@tags['戦闘']).addTag(@tags['魔法'])
        cr2 = CommandResource.new(2, "ダミー２", 2).addTag(@tags['アクション'])
        cr3 = CommandResource.new(3, "ダミー３", 1).addTag(@tags['戦闘']).addTag(@tags['攻撃'])
        
        @factory.insertCR(cr1)
        @factory.insertCR(cr2)
        @factory.insertCR(cr3)

        chash = @factory.getAllCRs(@tags)
        chash.size.should == 3
      end

      it "同じID(主キー)を持つCRデータを新規挿入しようとするとエラーになる" do
        cr1 = CommandResource.new(1, "ダミー１", 3).addTag(@tags['戦闘']).addTag(@tags['魔法'])
        cr2 = CommandResource.new(1, "ダミー２", 2).addTag(@tags['アクション'])
        expect {
          @factory.insertCR(cr1)
          @factory.insertCR(cr2)
        }.to raise_error ( SQLite3::ConstraintException )

        cr3 = @factory.getCR(1, @tags)
        cr3.getName().should == "ダミー１"
        cr3.getPower().should == 3
        cr3.getTags().size.should == 2
      end

      after do
        @factory.dropAllTablesForCR()
        @factory.dropTagTable()
      end
    end

    after do
      @factory.dropDB()
    end
  end
end
