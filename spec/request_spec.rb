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
  let(:url)     { "http://example.com" }
  let(:verb)    { "GET" }
  let(:content) { nil }
  let(:headers) { {"Content-Size" => 0} }
  let(:request) { PortableHole::Request.new(url, verb, content, headers) }
  let(:aws_key) { "AKIAIOSFODNN7" }
  let(:aws_secret) { "aws_secret" }
  let(:signature) { "bWq2s1WEIj+Ydj0vQ697zp+IXMU=" }
  let(:clock) { TestClock.new(Time.now) }  
  
  signature = ""
  
  aws_secret = "aws_secret"
  aws_key = ""

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
    request.headers["Authorization"].should eq( "AWS #{aws_key}:#{signature}")
  end
  
  # it "signs a Request" do
  #   aws_key = "AKIAIOSFODNN7"
  #   aws_secret = "aws_secret"
  #   signature = "bWq2s1WEIj+Ydj0vQ697zp+IXMU="
  #   clock = TestClock.new(Time.now)
  #   request.sign(aws_key, aws_secret, clock).should eq(signature)
  # end
  
  # it "signs a Request" do
  #   # TODO: request.sign(AWS_KEY, AWS_SECRET, clock)
  # end
end
