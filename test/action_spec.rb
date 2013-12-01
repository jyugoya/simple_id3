require '../src/action'
require '../src/tag'
require '../src/command_resource'

describe Action, "when initialized with arguments" do

  before do
    t1 = Tag.new("戦闘",1).add("攻撃",4)
    t2 = Tag.new("アクション",4)
    cr1 = CommandResource.new("名剣", 6, t1)
    cr2 = CommandResource.new("短剣", 3, t1)
    cr3 = CommandResource.new("肉体派", 3, t2)
    crs = [cr1, cr2, cr3]
    @a = Action.new("二刀流", true, true, crs)
  end

  it "should be initialized correctly" do
    @a.getName().should == "二刀流"
    @a.getCommand(0).getName().should == "名剣"
    @a.requiredEvaluation().should == true
    @a.requiredRolePlaying().should == true
  end

  it "50%以上のタグが行動のタグとなる(複数可能)" do
    @a.getCategory().should == "戦闘/攻撃"
  end

  it "ランクは使用したコマンドリソースの数*100である" do
    @a.getRank(true).should == 300
    @a.getRank(false).should == 200
  end

 it "戦力は、コマンドリソースの戦力の総和である" do
    @a.getPower().should == 45
 end

  it "上昇危険度は総コストの1/5である" do
    @a.getRisk().should == 10
  end

  it "行動はコマンドリソース５つまでを合成して作る。→6つ以上はエラー" do
    t = Tag.new("アクション",4)
    cr1 = CommandResource.new("ダミー１", 6, t)
    cr2 = CommandResource.new("ダミー２", 3, t)
    cr3 = CommandResource.new("ダミー３", 3, t)
    cr4 = CommandResource.new("ダミー１", 6, t)
    cr5 = CommandResource.new("ダミー２", 3, t)
    cr6 = CommandResource.new("ダミー３", 3, t)
    crs = [cr1, cr2, cr3, cr4, cr5, cr6]
    proc {
      Action.new("ダミー", true, true, crs)
    }.should raise_error
  end
end
