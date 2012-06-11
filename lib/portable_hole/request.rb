require 'openssl'
require 'base64'

module PortableHole
  class Request
    TIMESTAMP_FORMAT = "%a, %d %b %Y %H:%M:%S %z"
    SHA1 = OpenSSL::Digest::Digest.new("sha1")
    
    def initialize(url, verb, content_md5, content_type, headers)
      @url          = url
      @verb         = verb
      @content_md5  = content_md5
      @content_type = content_type
      @headers      = headers
    end
    
    attr_reader :url, :verb, :content_md5, :content_type, :headers
    
    def sign(aws_key, aws_secret, clock = Time)
      add_date_header(clock)
      add_authorization_header(aws_key, aws_secret)
    end

    def add_authorization_header(aws_key, aws_secret)
      string_to_sign = "#{@verb}\n#{@content_md5}\n#{@content_type}\n#{@headers["Date"]}\n#{@url}"
      signature = create_signature(aws_secret, string_to_sign)      
      headers["Authorization"] = "AWS #{aws_key}:#{signature}"
    end

    def add_date_header(clock = Time)
      headers["Date"] = clock.now.strftime(TIMESTAMP_FORMAT)
    end

    private
          
    def create_signature (aws_secret, string_to_sign)
      hmac      = OpenSSL::HMAC.digest(SHA1, aws_secret, string_to_sign)
      signature = [hmac].pack("m").strip
    end
      
  end
end