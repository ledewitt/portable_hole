require "spec_helper"

require "portable_hole/request"

describe "Amazon signature examples" do
  def request_to_signature(time, *args)
    request = PortableHole::Request.new(*args)
    request.sign( "AKIAIOSFODNN7EXAMPLE",
                  "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
                  TestClock.new(time) )
    request.headers["Authorization"].split(":").last
  end
  
  it "matches with a standard GET request" do
    request_to_signature(
      Time.utc(2007, 3, 27, 19, 36, 42),
      "http://johnsmith.s3.amazonaws.com/photos/puppy.jpg",
      "GET",
      nil,
      { }
    ).should eq("bWq2s1WEIj+Ydj0vQ697zp+IXMU=")
  end
  
  it "matches with a standard PUT request" do
    request_to_signature(
      Time.utc(2007, 3, 27, 21, 15, 45),
      "http://johnsmith.s3.amazonaws.com/photos/puppy.jpg",
      "PUT",
      nil,
      { "Content-Type"   => "image/jpeg",
        "Content-Length" => 94328 }
    ).should eq("MyyxeRY7whkBe+bq8fHCL/2kKUg=")
  end
  
  it "matches with a standard List request of the contents of a bucket" do
    request_to_signature(
      Time.utc(2007, 3, 27, 19, 42, 41),
      "http://johnsmith.s3.amazonaws.com/?prefix=photos&max-keys=50&marker=puppy",
      "GET",
       nil,
       { }
    ).should eq("htDYFYduRNen8P9ZfE/s9SuKy0U=")
  end
end
