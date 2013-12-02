require 'sqlite3'
require '../src/tag'
require '../src/command_resource'

class SQLite3Factory

  def initialize(fname)
    @dbfile = fname
  end

  # DB初期化
  def createDB()
    db = SQLite3::Database.new(@dbfile)
    db.close()
  end

  # DB削除
  def dropDB()
    File.unlink(@dbfile)
  end

  ####
  # Tagクラス用ここから
  # テーブル作成
  def createTagTable()
    sql = "create table tag (category varchar(16) primary key not null, rating integer)"
    db = SQLite3::Database.new(@dbfile)
    begin
      db.execute(sql)
    ensure
      db.close()
    end
  end

  # テーブル削除
  def dropTagTable()
    sql = "drop table tag"
    db = SQLite3::Database.new(@dbfile)
    begin
      db.execute(sql)
    ensure
      db.close()
    end
  end

  # 新規データ挿入
  def insertTag(tag)
    db = SQLite3::Database.new(@dbfile)
    begin
      db.execute("insert into tag values (?,?)", tag.getCategory(), tag.getRating())
    ensure
      db.close()
    end
  end

  # 既存データ更新
  def updateTag(tag)
    db = SQLite3::Database.new(@dbfile)
    begin
      db.execute("update tag set rating = ? where category = ?", tag.getRating(), tag.getCategory())
    ensure
      db.close()
    end
  end

  # データ削除
  def deleteTag(key)
    db = SQLite3::Database.new(@dbfile)
    begin
      db.execute("delete from tag where category = ?", key)
    ensure
      db.close()
    end
  end

  # 主キーでの検索結果取得
  def getTag(key)
    db = SQLite3::Database.new(@dbfile)
    t = nil
    begin
      db.execute("select * from tag where category = ?", key) do |row|
        t = Tag.new(row[0],row[1])
      end
    ensure
      db.close()
    end
    t
  end

  # 全データの取得
  def getAllTags()
    db = SQLite3::Database.new(@dbfile)
    tary = Hash.new {|tary, key| tary[key] = nil}
    begin
      db.execute("select * from tag") do |row|
        tary[row[0]] = Tag.new(row[0],row[1])
      end
    ensure
      db.close()
    end
    tary
  end
  # Tagクラス用ここまで
  ####

  ####
  # CommandResource用ここから
  # テーブル作成
  def createCommandResourceTable()
    # CommandResourceとTagは多対多関係なのでその関係用のテーブルが必要
    # ということで、2つのテーブル cr / cr_to_tag を作成する
    sql =<<-SQL
CREATE TABLE cr (
  id integer PRIMARY KEY NOT NULL,
  name varchar(32) NOT NULL,
  power integer NOT NULL);
CREATE TABLE cr_to_tag (
  cr_id integer NOT NULL REFERENCES cr(id),
  tag_category varchar(16) NOT NULL REFERENCES tag(category),
  PRIMARY KEY(cr_id, tag_category));
SQL
    db = SQLite3::Database.new(@dbfile)
    begin
      db.execute_batch(sql)
    ensure
      db.close()
    end
  end

  # テーブル削除
  def dropCommandResourceTable()
    sql =<<-SQL
DROP TABLE cr;
DROP TABLE cr_to_tag;
SQL
    db = SQLite3::Database.new(@dbfile)
    begin
      db.execute_batch(sql)
    ensure
      db.close()
    end
  end

  # データ挿入
  def insertCR(cr)
    sql = "INSERT INTO cr VALUES(:id, :name, :power)"
    db = SQLite3::Database.new(@dbfile)
    begin
      db.execute(sql,
        "id" => cr.getID(),
         "name" => cr.getName(),
         "power" => cr.getPower())

      sql = ""
      cr.getTags() do |tag|
        sql += "INSERT INTO cr_to_tag VALUES(:cr_id, '" + tag.getCategory() + "');"
      db.execute_batch(sql,
        "cr_id" => cr.getID())
      end
    ensure
      db.close()
    end
  end

  # データ更新
  def updateCR(cr)
    raise "Not yet implemented!"
  end

  # データ削除
  def deleteCR(key)
    raise "Not yet implemented!"
  end

  # データ取得
  def getCR(key, tags)
    # tag のハッシュテーブルから該当するTagを拾ってくる必要があるので第２引数に指定
    raise "Not yet implemented!"
  end

  # 全データ取得
  def getAllCRs(tags)
    # tag のハッシュテーブルから該当するTagを拾ってくる必要があるので引数に指定
    raise "Not yet implemented!"
  end
  # CommandResource用ここまで
  ###
end

