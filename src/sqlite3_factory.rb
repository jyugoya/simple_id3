require 'sqlite3'
require '../src/tag'

class SQLite3Factory

  def initialize(fname)
    @dbfile = fname
  end

  # DB������
  def createDB()
    db = SQLite3::Database.new(@dbfile)
    db.close()
  end

  # DB�폜
  def dropDB()
    File.unlink(@dbfile)
  end

  # Tag�N���X�p
  # �e�[�u���쐬
  def createTagTable()
    sql = "create table tag (category varchar(16) primary key not null, rating integer)"
    db = SQLite3::Database.new(@dbfile)
    begin
      db.execute(sql)
    ensure
      db.close()
    end
  end

  # Tag�N���X�p
  # �e�[�u���폜
  def dropTagTable()
    sql = "drop table tag"
    db = SQLite3::Database.new(@dbfile)
    begin
      db.execute(sql)
    ensure
      db.close()
    end
  end

  # Tag�N���X�p
  # �V�K�f�[�^�}��
  def insertTag(tag)
    db = SQLite3::Database.new(@dbfile)
    begin
      db.execute("insert into tag values (?,?)", tag.getCategory(), tag.getRating())
    ensure
      db.close()
    end
  end

  # Tag�N���X�p
  # �����f�[�^�X�V
  def updateTag(tag)
    db = SQLite3::Database.new(@dbfile)
    begin
      db.execute("update tag set rating = ? where category = ?", tag.getRating(), tag.getCategory())
    ensure
      db.close()
    end
  end

  # Tag�N���X�p
  # �f�[�^�폜
  def deleteTag(key)
    db = SQLite3::Database.new(@dbfile)
    begin
      db.execute("delete from tag where category = ?", key)
    ensure
      db.close()
    end
  end

  # Tag�N���X�p
  # ��L�[�ł̌������ʎ擾
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

  # Tag�N���X�p
  # �S�f�[�^�̎擾
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

