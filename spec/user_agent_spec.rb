require 'portable_hole/user_agent'

describe PortableHole::UserAgent do
  it "Says Hello" do
    user_agent = PortableHole::UserAgent.new
    user_agent.talk.should eq("Hello")
  end
end