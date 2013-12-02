require 'sqlite3'
require '../src/tag'

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

  # Tagクラス用
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

  # Tagクラス用
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

  # Tagクラス用
  # 新規データ挿入
  def insertTag(tag)
    db = SQLite3::Database.new(@dbfile)
    begin
      db.execute("insert into tag values (?,?)", tag.getCategory(), tag.getRating())
    ensure
      db.close()
    end
  end

  # Tagクラス用
  # 既存データ更新
  def updateTag(tag)
    db = SQLite3::Database.new(@dbfile)
    begin
      db.execute("update tag set rating = ? where category = ?", tag.getRating(), tag.getCategory())
    ensure
      db.close()
    end
  end

  # Tagクラス用
  # データ削除
  def deleteTag(key)
    db = SQLite3::Database.new(@dbfile)
    begin
      db.execute("delete from tag where category = ?", key)
    ensure
      db.close()
    end
  end

  # Tagクラス用
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

  # Tagクラス用
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

end

