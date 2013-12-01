require '../src/simple_tag'

describe SimpleTag, "when initialized with arguments" do

  before do
    @st = SimpleTag.new("一般", 3)
  end

  it "should be initialized correctly" do
    @st.getCategory().should == "一般"
    @st.getRating().should == 3
  end

end
