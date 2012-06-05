# Starting point.

# require 'openssl'
# require 'base64'

module PortableHole
  class Request
    TIMESTAMP_FORMAT = "%a, %d %b %Y %H:%M:%S %z"
    
    def initialize(url, verb, content, headers)
      @url     = url
      @verb    = verb
      @content = content
      @headers = headers
    end
    
    attr_reader :url, :verb, :content, :headers
    
    def add_date_header(clock = Time)
      headers["Date"] = clock.now.strftime(TIMESTAMP_FORMAT)
    end
    
    # def sign(...)
    #   # TODO: add_date_header(...)
    #   #       add_a..._header(...)
    # end

    # def initialize(access_key, secret_key)
    #   @access_key = access_key
    #   @secret_key = secret_key
    # end
    # 
    # def sign(date, request_type, resource)
    #   raw_hmac = OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), @secret_key, string_to_sign(date, request_type, resource))
    #   sig = Base64.encode64(raw_hmac).chomp
    # 
    #   "Authorization: AWS %s:%s" % [@access_key, sig]
    # end
    private
    
    # ...
  end
end
