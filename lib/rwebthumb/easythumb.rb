require 'cgi'
require 'digest/md5'
module Simplificator
  module Webthumb
    class Easythumb
      VALID_SIZES = [:small, :medium, :medium2, :large]
      def initialize(api_key, user_id, api_endpoint = 'http://webthumb.bluga.net/easythumb.php')
        @api_key = api_key
        @user_id = user_id
        @api_endpoint = api_endpoint
      end
      
      # Build an Easythumb URL
      # options are
      #  url: the url to take a snapshot from. required.
      #  size: the size of the thumbnail to take (VALID_SIZES). Defaults to :medium
      #  cache: the maximum allowed age in the cache (1-30). Defaults to 15
      def build_url(options = {})
        raise WebthumbException.new(':url is required') if (options[:url] == nil || options[:url] == '')
        options[:size] ||= :medium
        options[:cache] ||= 15
        hash_out = Digest::MD5.hexdigest("#{Time.now.strftime('%Y%m%d')}#{options[:url]}#{@api_key}")
        "#{@api_endpoint}?user=#{@user_id}&cache=#{options[:cache]}&size=#{options[:size]}&url=#{CGI.escape(options[:url])}&hash=#{hash_out}"
      end
    end
  end
end