require 'net/http'
require 'rexml/document'
require 'date'
module Simplificator
  module Webthumb

    #
    # Main access point for the webthumb API.
    # All methods calling the Server need the api key beeing set.
    #
    class Webthumb < Base
      # Request thumbnail creation from webthumb server. A Job object holding 
      # request information is returned (most important the job_id)
      # Some keys have been ruby-ized (i.e. outputType -> :output_type). All keys are
      # Symbols. Check out the webthumb API description for detailed explanation of the options
      # http://webthumb.bluga.net/apidoc
      # Options:
      # * url: the url to take the snapshot from
      # * output_type: chose output format (jpg or png)
      # * width: width of the browser
      # * height: height of the browser
      # * fullthumb: full sized snapshot (true or false)
      # * custom_thumbnail: create a custom sized thumbnail. A hash with width and height entries
      # * effect: specify a visual effect (mirror, dropshadow or border)
      # * delay: wait until the snapshot is taken
      # * notify: callback url which is called after snapshot is taken
      # * excerpt: taking an excerpt snapshot. A hash with for entries. width, height, x, y
      # * videothumb: experimental option, check Joshs blog (http://blog.joshuaeichorn.com/archives/2008/07/08/videothumb-addon-to-webthumb-is-alpha/)
      #   (true or false)
      # Only the url option is required. Check webthumb API for default values. Check also the different constants 
      # defined in Base.rb for valid values
      #
      def thumbnail(options = {})
        Job.from_thumbnail_xml(@api_key, @api_endpoint, do_request(build_thumbnail_xml(options)))
      end
      
      # Request the job status from server.
      # This can be used to look up job status from server when you just have the job ID, e.g. when you want to retrieve
      # the thumbs later or when you use callbacks.
      # The Job object returned from this method does not have all attributes set since. Webthumbs API does not return
      # the requested URL, the duration estimation and the cost values when checking the status. I hope this will change someday.
      def job_status(job_id)
        raise WebthumbException.new('Job id is required') if job_id == nil || job_id == ''
        Job.from_status_xml(@api_key, @api_endpoint, do_request(build_job_status_xml(job_id)))
      end
      
      # Check your credit status on the webthumbs server
      # Returns a hash with two keys. See webthumb API for detailed information.
      # * reserve: an integer
      # * subscription: an integer
      def credits()
        response = do_request(build_credits_xml())
        credit_elements = REXML::XPath.first(response, '/webthumb/credits').elements
        {:reserve => credit_elements['reserve'].text.to_i, :subscription => credit_elements['subscription'].text.to_i}
      end
      
      private 
      def build_thumbnail_xml(options)
        validate_thumbnail_options(options)
        
        
        root = build_root_node()
        request = root.add_element('request')
        request.add_element('url').add_text(options[:url])
        add_element(request, options, :output_type, 'outputType')
        # these elements have the same name as the key in options hash
        [:width, :height, :effect, :delay, :notify].each {|item| add_element(request, options, item)}
        # these options need conversion from true/false to 0/1
        if options[:fullthumb] == true
          request.add_element('fullthumb').add_text('1')
        end
        if options[:videothumb] == true
          request.add_element('videothumb').add_text('1')
        end
        if options.has_key?(:custom_thumbnail)
          request.add_element('customThumbnail', 
            'width' => options[:custom_thumbnail][:width].to_s, 
            'height' => options[:custom_thumbnail][:height].to_s)
				
        end
        if options.has_key?(:excerpt)
          excerpt = request.add_element('excerpt')
          [:x, :y, :width, :height].each {|item| add_element(excerpt, options[:excerpt], item)}
        end
        root
      end
      
      def build_job_status_xml(job_id)
        root = build_root_node()
        root.add_element('status').add_element('job').add_text(job_id)
        root
      end
      
      def build_credits_xml()
        root = build_root_node()
        root.add_element('credits')
        root
      end
      
      def validate_thumbnail_options(options)
        raise WebthumbException.new('Need an URL') if options[:url] == nil || options[:url] == ''
        #raise WebthumbException.new("output_type is invalid: #{options[:output_type]}") if options.has_key?(:output_type) and (not Base::VALID_OUTPUT_TYPES.include?(options[:output_type]))
      end
    end

  end
end




