require 'net/http'
require 'rexml/document'
require 'date'
module Simplificator
  module Webthumb

	
    class Webthumb < Base
      def thumbnail(options = {})
        Job.from_thumbnail_xml(@api_key, do_request(build_thumbnail_xml(options)))
      end

      def job_status(job_id)
        Job.from_status_xml(@api_key, do_request(build_job_status_xml(job_id)))
      end
      
      def credits()
        root = build_root_node()
        root.add_element('credits')
        elements = do_request(root).elements['webthumb'].elements['credits'].elements
        {:reserve => elements['reserve'].text.to_i, :subscription => elements['subscription'].text.to_i}
      end
      
      private 
      def build_thumbnail_xml(options)
        validate_thumbnail_options(options)
        
        
        root = build_root_node()
        request = root.add_element('request')
        request.add_element('url').add_text(options[:url])
        add_element(request, options, :output_type, 'outputType')
        [:width, :height, :effect, :delay, :notofy].each {|item| add_element(request, options, item)}
			
        if options[:fullthumb] == true
          request.add_element('fullthumb').add_text('1')
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
      
      def validate_thumbnail_options(options)
        raise WebthumbException.new('Need an URL') if options[:url] == nil || options[:url] == ''
        raise WebthumbException.new("output_type is invalid: #{options[:output_type]}") if options.has_key?(:output_type) and (not Base::VALID_OUTPUT_TYPES.include?(options[:output_type]))
        
      end
    end

  end
end




