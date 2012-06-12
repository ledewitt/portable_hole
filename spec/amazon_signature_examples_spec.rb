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
  
  # # TODO: Query Issuess need to be figured out in Request.rb.
  # it "matches with a standard List request for the contents of a bucket" do
  #   request_to_signature(
  #     Time.utc(2007, 3, 27, 19, 42, 41),
  #     "http://johnsmith.s3.amazonaws.com/?prefix=photos&max-keys=50&marker=puppy",
  #     "GET",
  #      nil,
  #      { }
  #   ).should eq("htDYFYduRNen8P9ZfE/s9SuKy0U=")
  # end
  
  it "matches with a standard Fetch request for the a bucket ('johnsmith')" do
    request_to_signature(
      Time.utc(2007, 3, 27, 19, 44, 46),
      "http://johnsmith.s3.amazonaws.com/?acl",
      "GET",
       nil,
      { }
    ).should eq("c2WLPFtWHVgbEmeEG93a4cG37dM=")
  end
  
  # # TODO: !!!ALERT SPECIAL CASE!!! using x-amx-date method adjust the test
  # it "matches with a standard DELETE request" do
  #   request_to_signature(
  #     Time.utc(2007, 3, 27, 21, 20, 27),
  #     "http://johnsmith.s3.amazonaws.com/johnsmith/photos/puppy.jpg",
  #     "DELETE",
  #      nil,
  #      { }
  #   ).should eq("9b2sXq0KfxsxHtdZkzx/9Ngqyh8=")
  # end
  
  # TODO: !!!ALERT SPECIAL CASE!!! Add all the content tages and the X-Amx-Meta data
  # it "matches with a CNAME style virtual hosted bucket uplad request with meta data." do
  #   request_to_signature(
  #     Time.utc(2007, 3, 27, 21, 06, 08),
  #     "http://",
  #     "PUT",
  #     ,
  #     { }
  #   ).should eq("ilyl83RwaSoYIEdixDQcA4OnAnc=")    
  # end
  
  it "matches a list all my buckets request" do
    request_to_signature(
      Time.utc(2007, 3, 28, 01, 29, 59),
      "http://s3.amazonaws.com",
      "GET",
      nil,
      { }
    ).should eq("qGdzdERIC03wnaRNKh6OqZehG9s=")    
  end

  it "matches a examile of Unicode Keys" do
    request_to_signature(
      Time.utc(2007, 3, 28, 01, 49, 49),
      "http://s3.amazonaws.com/dictionary/fran%C3%A7ais/pr%c3%a9f%c3%a8re",
      "GET",
      nil,
      { }
    ).should eq("DNEZGsoieTZ92F3bUfSPQcbGmlM=")    
  end
  
  # # TODO: Special Case at the bottom of the documentation needs further investigation.
  # it "matches a Query String Request Authentication" do
  #   request_to_signature(
  #     nil,
  #     "http://johnsmith.s3.amazonaws.com",
  #     "GET",
  #     nil,
  #     { }
  #   ).should eq("vjbyPxybdZaNmGa%2ByT272YEAiv4%3D")    
  # end
  
end
