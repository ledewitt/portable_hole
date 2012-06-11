require "spec_helper"

require 'portable_hole/request'
# AWS - Amazon Web Service
# These are the items that are needed for a AWS Request:
# 
# AWS Access Key Id
# Signature - Caculated by using secret access key
# Time Stamp
# Date

describe PortableHole::Request do
  let(:url)            { "/johnsmith/photos/puppy.jpg" }
  let(:verb)           { "GET" }
  let(:content)        { nil }
  let(:headers)        { {"Content-Size" => 0} }
  let(:request)        { PortableHole::Request.new(url, verb, content, headers) }
  let(:aws_key)        { "AKIAIOSFODNN7EXAMPLE" }
  let(:aws_secret)     { "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY" }
  let(:signature)      { "bWq2s1WEIj+Ydj0vQ697zp+IXMU=" }
  let(:clock)          { TestClock.new(Time.utc(2007, "mar",27,19,36,42)) }

  it "stores a URL, a verb, some content, and some header" do
    request.url.should          eq(url)
    request.verb.should         eq(verb)
    request.content.should      be_nil
    request.headers.should      eq(headers)
  end
  
  it "adds a Date header" do
    request.add_date_header(clock)
    request.headers["Date"].should eq(
      clock.strftime(PortableHole::Request::TIMESTAMP_FORMAT)
    )
  end
  
  it "adds an Authorization header" do
    request.add_date_header(clock)
    request.add_authorization_header(aws_key, aws_secret)
    request.headers["Authorization"].should eq("AWS #{aws_key}:#{signature}")
  end
  
  it "signs a Request" do
    request.sign(aws_key, aws_secret)
    request.headers.should include("Date")
    request.headers.should include("Authorization")
  end
  
end
