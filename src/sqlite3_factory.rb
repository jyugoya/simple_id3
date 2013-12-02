require 'sqlite3'
require '../src/tag'
require '../src/command_resource'

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

  ####
  # Tag�N���X�p��������
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

  # �V�K�f�[�^�}��
  def insertTag(tag)
    db = SQLite3::Database.new(@dbfile)
    begin
      db.execute("insert into tag values (?,?)", tag.getCategory(), tag.getRating())
    ensure
      db.close()
    end
  end

  # �����f�[�^�X�V
  def updateTag(tag)
    db = SQLite3::Database.new(@dbfile)
    begin
      db.execute("update tag set rating = ? where category = ?", tag.getRating(), tag.getCategory())
    ensure
      db.close()
    end
  end

  # �f�[�^�폜
  def deleteTag(key)
    db = SQLite3::Database.new(@dbfile)
    begin
      db.execute("delete from tag where category = ?", key)
    ensure
      db.close()
    end
  end

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
  # Tag�N���X�p�����܂�
  ####

  ####
  # CommandResource�p��������
  # �e�[�u���쐬
  def createCommandResourceTable()
    # CommandResource��Tag�͑��Α��֌W�Ȃ̂ł��̊֌W�p�̃e�[�u�����K�v
    # �Ƃ������ƂŁA2�̃e�[�u�� cr / cr_to_tag ���쐬����
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

  # �e�[�u���폜
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

  # �f�[�^�}��
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

  # �f�[�^�X�V
  def updateCR(cr)
    raise "Not yet implemented!"
  end

  # �f�[�^�폜
  def deleteCR(key)
    raise "Not yet implemented!"
  end

  # �f�[�^�擾
  def getCR(key, tags)
    # tag �̃n�b�V���e�[�u������Y������Tag���E���Ă���K�v������̂ő�Q�����Ɏw��
    raise "Not yet implemented!"
  end

  # �S�f�[�^�擾
  def getAllCRs(tags)
    # tag �̃n�b�V���e�[�u������Y������Tag���E���Ă���K�v������̂ň����Ɏw��
    raise "Not yet implemented!"
  end
  # CommandResource�p�����܂�
  ###
end

