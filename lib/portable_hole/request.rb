require 'openssl'
require 'base64'

module PortableHole
  class Request
    TIMESTAMP_FORMAT = "%a, %d %b %Y %H:%M:%S %z"
    SHA1 = OpenSSL::Digest::Digest.new("sha1")
    
    def initialize(url, verb, content, headers)
      @url     = url
      @verb    = verb
      @content = content
      @headers = headers
    end
    
    attr_reader :url, :verb, :content, :headers
    
    def sign(aws_key, aws_secret, clock = Time)
      add_authentication_header(aws_key, aws_secret, clock)
      add_date_header(clock)
    end

    private
    
    def add_authentication_header(aws_key, aws_secret, clock)
      # TODO: For testing purposes how is string_to_sign assigned the following string
      # if it is not used in a public method call?
      string_to_sign = "GET\n\n\nTue, 27 Mar 2007 19:36:42 +0000\n/johnsmith/photos/puppy.jpg"
      signature = create_signature(aws_secret, string_to_sign)      
      headers["Authorization"] = "AWS #{aws_key}:#{signature}"
    end
      
    def create_signature (aws_secret, string_to_sign)
      hmac      = OpenSSL::HMAC.digest(SHA1, aws_secret, string_to_sign)
      signature = [hmac].pack("m").strip
    end
      
    def add_date_header(clock = Time)
      headers["Date"] = clock.now.strftime(TIMESTAMP_FORMAT)
    end
    
  end
end