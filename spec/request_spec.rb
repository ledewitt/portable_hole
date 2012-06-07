require 'portable_hole/request'
# AWS - Amazon Web Service
# These are the items that are needed for a AWS Request:
# 
# AWS Access Key Id
# Signature - Caculated by using secret access key
# Time Stamp
# Date

class TestClock
  def initialize(time)
    @time = time
  end
  
  def now
    self
  end
  
  def strftime(*args)
    @time.strftime(*args)
  end
end

describe PortableHole::Request do
  let(:url)        { "http://example.com" }
  let(:verb)       { "GET" }
  let(:content)    { nil }
  let(:headers)    { {"Content-Size" => 0} }
  let(:request)    { PortableHole::Request.new(url, verb, content, headers) }
  let(:aws_key)    { "AKIAIOSFODNN7EXAMPLE" }
  let(:aws_secret) { "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY" }
  let(:signature)  { "bWq2s1WEIj+Ydj0vQ697zp+IXMU=" }
  let(:clock)      { TestClock.new(Time.now) }  

  it "stores a URL, a verb, some content, and some header" do
    request.url.should     eq(url)
    request.verb.should    eq(verb)
    request.content.should be_nil
    request.headers.should eq(headers)
  end
  
  it "adds a Date header" do
    request.sign(aws_key, aws_secret, clock)
    request.headers["Date"].should eq(
      clock.strftime(PortableHole::Request::TIMESTAMP_FORMAT)
    )
  end
  
  it "adds an Authorization header" do
    request.sign(aws_key, aws_secret, clock)    
    request.headers["Authorization"].should eq("AWS #{aws_key}:#{signature}")
  end
  
  # it "signs a Request" do
  #   TODO IF: Adding the Authorization header was insufficent
  # end
  
end
