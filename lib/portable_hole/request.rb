require 'openssl'
require 'base64'
require "uri"

module PortableHole
  class Request
    HOST_URL          = "s3.amazonaws.com"
    TIMESTAMP_FORMAT  = "%a, %d %b %Y %H:%M:%S %z"
    SHA1              = OpenSSL::Digest::Digest.new("sha1")
    ALLOWED_RESOURCES = [ "acl",
                          "lifecycle",
                          "location",
                          "logging",
                          "notification",
                          "partNumber",
                          "policy",
                          "requestPayment",
                          "torrent",
                          "uploadId",
                          "uploads",
                          "versionId",
                          "versioning",
                          "versions", 
                          "website" ]
    
    def initialize(url, verb, content = nil, headers = { })
      @url     = url
      @verb    = verb
      @content = content
      @headers = headers
    end
    
    attr_reader :url, :verb, :content, :headers

    def add_date_header(clock = Time)
      headers["Date"] = clock.now.strftime(TIMESTAMP_FORMAT)
    end

    def add_authorization_header(aws_key, aws_secret)
      headers["Authorization"] = "AWS #{aws_key}:#{signature(aws_secret)}"
    end
    
    def sign(aws_key, aws_secret, clock = Time)
      add_date_header(clock)
      add_authorization_header(aws_key, aws_secret)
    end

    private
  
    def signature(aws_secret)
      hmac = OpenSSL::HMAC.digest(SHA1, aws_secret, string_to_sign)
      [hmac.force_encoding("UTF-8")].pack("m").strip
    end
    
    def string_to_sign
      string_to_sign = [ verb,
                         content_md5,
                         headers["Content-Type"],
                         headers["Date"] ]
      # TODO: handle AMZ headers
      string_to_sign << canonicalized_resource_element
      string_to_sign.join("\n")
    end
    
    def content_md5
      if content
        # TODO:  hash content
      end
    end
    
    def canonicalized_resource_element
      resource = ""
      uri      = URI(url)
      if uri.host =~ /\A((?:[^.]+\.)+)#{Regexp.escape HOST_URL}\z/
        resource << "/#{$1[0..-2]}"
      end
      
      if uri.query
        resource << subresource(uri)
      else
        resource << uri.request_uri
      end
    end
    
    def subresource(uri)
      q = uri.query.split("&")
      
      cleaned_query = q.find_all do | resource |
        ALLOWED_RESOURCES.include? resource[/\A[^=]+/]
      end

      final_query = cleaned_query.sort.join("&")

      if final_query.empty?
        "/"
      else
        uri.path << "?#{final_query}"
      end
    end
  end
end
