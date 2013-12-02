# -*- encoding: utf-8 -*-
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
    db.execute_batch("pragma encoding=utf8;\npragma foreign_keys = ON;")
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
    t = nil
    db = SQLite3::Database.new(@dbfile)
    begin
      r = db.get_first_row("select * from tag where category = ?", key)
      if r != nil then
        t = Tag.new(r[0],r[1])
      end
    ensure
      db.close()
    end
    t
  end

  # 全データの取得
  def getAllTags()
    db = SQLite3::Database.new(@dbfile)
    thash = Hash.new {|thash, key| thash[key] = nil}
    begin
      db.execute("select * from tag") do |row|
        thash[row[0]] = Tag.new(row[0],row[1])
      end
    ensure
      db.close()
    end
    thash
  end
  # Tagクラス用ここまで
  ####

  ####
  # CommandResource用ここから
  # テーブル作成
  def createAllTablesForCR()
    # CommandResourceとTagは多対多関係なのでその関係用のテーブルが必要
    # ということで、2つのテーブル cr / cr2tag を作成する
    sql =<<-SQL
CREATE TABLE cr (
  id integer PRIMARY KEY NOT NULL,
  name varchar(32) NOT NULL,
  power integer NOT NULL);
CREATE TABLE cr2tag (
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
    rescue => e
      db.close()
      raise e
  end


  # 関係するテーブルをすべて削除
  def dropAllTablesForCR()
    db = SQLite3::Database.new(@dbfile)
    db.transaction do
      db.execute("DROP TABLE cr")
      db.execute("DROP TABLE cr2tag")
    end
    db.close()
    rescue => e
      db.close()
      raise e
  end

  # データ挿入
  def insertCR(cr)
    db = SQLite3::Database.new(@dbfile)
    db.transaction do
      db.execute("INSERT INTO cr VALUES(:id, :name, :power)",
        "id" => cr.getID(),
         "name" => cr.getName(),
         "power" => cr.getPower())

      tary = cr.getTags()
      for tag in tary
        db.execute("INSERT INTO cr2tag VALUES(:cr_id, :tag_category)",
        "cr_id" => cr.getID(),
        "tag_category" => tag.getCategory())
      end
    end
    db.close()
    rescue => e
      db.close()
      raise e
  end

  # データ更新
  def updateCR(cr)
    db = SQLite3::Database.new(@dbfile)
    db.transaction do
      db.execute("update cr set name = ?, power = ? where id = ?", cr.getName(), cr.getPower(), cr.getID())
      db.execute("delete from cr2tag where cr_id = ?", cr.getID())
      tary = cr.getTags()
      for tag in tary
        db.execute("insert into cr2tag values(:cr_id, :tag_category)",
        "cr_id" => cr.getID(),
        "tag_category" => tag.getCategory())
      end
    end
    db.close()
    rescue => e
      db.close()
      raise e
  end

  # データ削除
  def deleteCR(key)
    db = SQLite3::Database.new(@dbfile)
    db.transaction do
      db.execute("delete from cr2tag where cr_id = ?", key)
      db.execute("delete from cr where id = ?", key)
    end
    db.close()
    rescue => e
      db.close()
      raise e
  end

  # データ取得
  def getCR(key, tags)
    # tag のハッシュテーブルから該当するTagを拾ってくる必要があるので第２引数に指定
    cr = nil
    db = SQLite3::Database.new(@dbfile)
    db.transaction do
      r = db.get_first_row("select * from cr where id = ?", key)
      if r != nil then
        cr = CommandResource.new(r[0], r[1], r[2])
        db.execute("select tag_category from cr2tag where cr_id = ?", key) do |row|
          t = tags[row[0]]
          if t != nil then cr.addTag(t) end
        end
      end
    end
    db.close()
    cr
    rescue => e
      db.close()
      raise e
  end

  # 全データ取得
  def getAllCRs(tags)
    # tag のハッシュテーブルから該当するTagを拾ってくる必要があるので引数に指定
    chash = Hash.new {|chash, key| chash[key] = nil}
    db = SQLite3::Database.new(@dbfile)
    db.transaction do
      db.execute("select * from cr") do |r|
        cr = CommandResource.new(r[0], r[1], r[2])
        db.execute("select tag_category from cr2tag where cr_id = ?", r[0]) do |row|
          t = tags[row[0]]
          if t != nil then cr.addTag(t) end
        end
        chash[r[0]] = cr
      end
    end
    db.close()
    chash
    rescue => e
      db.close()
      raise e
  end
  # CommandResource用ここまで
  ###
end

