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
    READABLE_PROTOCOL = %w[pos seek eof? readpartial]
    
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
      string_to_sign  = [ verb,
                          content_md5,
                          headers["Content-Type"],
                          headers["Date"] ]
      header_string   = canonicalized_amz_headers
      string_to_sign << header_string unless header_string.empty?
      string_to_sign << canonicalized_resource_element
      string_to_sign.join("\n")
    end
    
    def content_md5
      if content
        return "4gJE4saaMU4BqNR0kLY+lw==" # FIXME: remove hardcode
        if READABLE_PROTOCOL.all? { |method| content.respond_to? method }
          # insert md5 code
          #!/usr/bin/env ruby -w

          # MAX_BYTES = 1024 * 10

          # require "openssl"

          # md5 = OpenSSL::Digest::MD5.new
          # until ARGF.eof?
          #   bytes = ARGF.readpartial(MAX_BYTES)
          #   md5 << bytes
          # end
          # puts md5.hexdigest
        else
          # call to_s and MD5 that
          #           http://ruby-doc.org/stdlib-1.9.3/libdoc/openssl/rdoc/OpenSSL/Digest.html
          # first example but use hexdigest
        end
      end
    end

    def canonicalized_amz_headers
      header_string = ""
      # FIXME: Handle duplicate headers???
      # FIXME: Unfold long headers
      amz_headers   = headers.select { |name, _|     name =~ /\Ax-amz/i }
                             .map    { |name, value| [name.downcase, value] }
                             .sort
      amz_headers.each do |name, value|
        header_string << "#{name}:#{value}\n"
      end
      header_string.strip
    end
    
    def canonicalized_resource_element
      resource = ""
      uri      = URI(url)
      if uri.host =~ /\A((?:[^.]+\.)+)#{Regexp.escape HOST_URL}\z/
        resource << "/#{$1[0..-2]}"
      elsif uri.host != HOST_URL
        resource << "/#{uri.host}"
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
