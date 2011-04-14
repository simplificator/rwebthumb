module Simplificator
  module Webthumb
    #
    #
    #
    #
    class Base
      # Valid output_types for thumbnail requests
      VALID_OUTPUT_TYPES = [:jpg, :png]
      # Valid values for size element in fetch requests
      VALID_SIZES = [:small, :medium, :medium2, :large, :full, :excerpt, :effect, :custom, :zip]

      attr_reader :api_key
      # Constructor
      #  api_key: the Webthumb api key, not nil and not blank
      #
      def initialize(api_key, api_endpoint = 'http://webthumb.bluga.net/api.php')
        raise WebthumbException.new('Need an not nil and not blank api_key') if api_key == nil || api_key == ''
        @api_key = api_key
        @api_endpoint = api_endpoint
        @api_uri = URI.parse(@api_endpoint)
      end

      # Parse the datetime string and returns a DateTime object in UTC time
      # Webthumb returns the time in MST (Mountain Standard Time) which is some 7 hours
      # behind UTC
      def self.parse_webthumb_datetime(s)
        Time.parse("#{s} MST").getutc
      end

      def do_request(xml)
        request = Net::HTTP::Post.new(@api_uri.path)
        request.body = xml.to_s
        response = Net::HTTP.new(@api_uri.host, @api_uri.port).start {|p| p.request(request) }
        case response
        when Net::HTTPOK
          case response.content_type.downcase
          when 'text/xml'
            REXML::Document.new(response.body)
          when 'text/plain'
            raise WebthumbException.new("Unsupported content type #{response.content_type}: Body was: #{response.body}")
          when 'image/jpg', 'image/jpeg', 'image/png', 'archive/zip'
            raise WebthumbException.new("No data returned though content type is #{response.content_type}") if response.body.length == 0
            response.body
          else
            raise WebthumbException.new("Unsupported content type #{response.content_type}")
          end
        else
          raise CommunicationException('Response code was not HTTP OK')
        end
      end


      # builds the root node for webthumb requtes
      def  build_root_node()
        root = REXML::Element.new('webthumb')
        api = root.add_element('apikey')
        api.text = @api_key
        root
      end

      protected
      #
      # add a XML element if value is present.
      # can be used to create XML for webthumb requests from ruby options hash.
      #
      # root: the root XML element where element is added to
      # options: the hash where value is taken from
      # key: the key to lookup the value in options
      # name: the name of the XML element. defaults to key
      #
      def add_element(root, options, key, name = key.to_s)
        root.add_element(name).add_text(options[key].to_s) if options.has_key?(key)
      end

    end
    class WebthumbException < RuntimeError
    end
    class CommunicationException < RuntimeError
    end
  end
end
