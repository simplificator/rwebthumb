module Simplificator
  module Webthumb 
    class Job < Base
      
      attr_reader :duration_estimate, :submission_datetime, :cost, :job_id, :url
      
      # Constant for the status attribute when job is beeing processed
      STATUS_PROCESSING = 100
      # Constant for the status attribute when job is done
      STATUS_PICKUP = 200
    
      # Factory method to build a Job object from a REXML xml element
      def self.from_thumbnail_xml(api_key, xml)
        job_element = REXML::XPath.first(xml, '/webthumb/jobs/job')
        submission_datetime = self.parse_webthumb_datetime(job_element.attributes['time'])
        Job.new(api_key, job_element.text, job_element.attributes['url'], submission_datetime, job_element.attributes['estimate'].to_i, job_element.attributes['cost'].to_i)
      end 
      
      def self.from_status_xml(api_key, xml)
        status_element = REXML::XPath.first(xml, '/webthumb/jobStatus/status')
        submission_datetime = self.parse_webthumb_datetime(status_element.attributes['submissionTime'])
        job = Job.new(api_key, status_element.attributes['id'], nil, submission_datetime, 5, nil, 
          status_element.text == 'Complete' ? STATUS_PICKUP : STATUS_PROCESSING)
      end
    
      def initialize(api_key, job_id, url, submission_datetime, duration_estimate, cost, status = STATUS_PROCESSING)
        super(api_key)
        @job_id = job_id
        @url = url
        @submission_datetime = submission_datetime
        @duration_estimate = duration_estimate
        @cost = cost
        @status = status
        @cache = {}
      end
    
      def check_status
        response = do_request(build_status_xml())
        @status = REXML::XPath.first(response, '/webthumb/jobStatus/status').text == 'Complete' ? STATUS_PICKUP : STATUS_PROCESSING
        if pickup?
          @completion_time = response.attributes['completionTime']
          @duration = 'not yet... need to convert times first' 
        end
        @status
      end
      
      def fetch_when_complete(size = :small)
        while not pickup?
          sleep @duration_estimate
          check_status
        end
        fetch(size)
      end
      
      def fetch(size = :small)
        unless @cache.has_key?(size)
          response = do_request(build_fetch_xml(size))
          @cache[size] = response
        end
        @cache[size]
      end
      
      def write_file(data, name)
        raise WebthumbException.new('NO data given') if data == nil || data.size == 0
        File.open(name, 'wb+') do |file|
          file.write(data)
          file.close
          file
        end
      end
      
      def pickup?
        @status == STATUS_PICKUP
      end	
      def processing?
        @status == STATUS_PROCESSING
      end
      
      private
      def build_fetch_xml(size = :small)
        raise WebthumbException.new("size parameter must be one of #{VALID_SIZES.join(', ')} but was #{size}") unless Base::VALID_SIZES.include?(size)
        root = build_root_node()
        fetch = root.add_element('fetch')
        fetch.add_element('job').add_text(@job_id)
        fetch.add_element('size').add_text(size.to_s)
        root
      end
      def build_status_xml()
        root = build_root_node()
        status = root.add_element('status')
        status.add_element('job').add_text(@job_id)
        root
      end

      def to_s
        "Job: #{@job_id} / Status: #{@status} / Submission Time #{@submission_time} / Duration Estimate #{@duration_estimate}"
      end
    end
  end
end