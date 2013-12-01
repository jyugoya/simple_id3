require '../src/tag'

describe Tag do
  before do
    @st = Tag.new("一般", 3)
  end

  it "初期化成功のチェック" do
    @st.getCategory().should == "一般"
    @st.getRating().should == 3
  end

end
