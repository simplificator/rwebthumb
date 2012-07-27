module Simplificator
  module Webthumb
    class Job < Base

      attr_reader :duration_estimate, :submission_datetime, :cost, :job_id, :url

      # Constant for the status attribute when job is beeing processed
      STATUS_PROCESSING = 100
      # Constant for the status attribute when job is done
      STATUS_PICKUP = 200

      # Factory method to build a Job object from a REXML xml element
      def self.from_thumbnail_xml(api_key, api_endpoint, xml)
        job_element = REXML::XPath.first(xml, '/webthumb/jobs/job')
        return nil if job_element.nil?

        submission_datetime = self.parse_webthumb_datetime(job_element.attributes['time'])
        Job.new(api_key, api_endpoint, job_element.text, job_element.attributes['url'], submission_datetime, job_element.attributes['estimate'].to_i, job_element.attributes['cost'].to_i)
      end
      # Factory method to create a Job object from a status XML.
      # this does not set all attributes of the Job (url, duration_estimate, cost) since the API of webthumb does not
      # return the same information on job creation and status requests.
      def self.from_status_xml(api_key, api_endpoint, xml)
        status_element = REXML::XPath.first(xml, '/webthumb/jobStatus/status')
        submission_datetime = self.parse_webthumb_datetime(status_element.attributes['submissionTime'])
        job = Job.new(api_key, api_endpoint, status_element.attributes['id'], nil, submission_datetime, 5, nil,
          (status_element.text || '').downcase == 'complete' ? STATUS_PICKUP : STATUS_PROCESSING)
      end
      # Constructor.
      # *api_key: webthumb API key. Required by all the operations which query the server
      # *job_id: id of the job. Required.
      # *url: the url of the site to snapshot. Optional
      # *submission_datetime: UTC Datetime of job submission
      # *duration_estimate: integer value indicating estimated job duration in seconds
      # *cost: integer value indicating how many credit this request costet. Optional
      # *status: one of the STATUS_XXX constants defined in Base. Defaults to STATUS_PROCESSING
      def initialize(api_key, api_endpoint, job_id, url, submission_datetime, duration_estimate, cost, status = STATUS_PROCESSING)
        super(api_key, api_endpoint)
        @job_id = job_id
        @url = url
        @submission_datetime = submission_datetime
        @duration_estimate = duration_estimate
        @cost = cost
        @status = status
        @cache = {}
      end

      # Checks the status of the job on webthumb server.
      # Returns one of the STATUS_XXX constants from Base.
      # A call to this method updates the @status attribute.
      def check_status
        response = do_request(build_status_xml())
        status_elem = REXML::XPath.first(response,'/webthumb/jobStatus/status')
        @status = (status_elem.text || '').downcase == 'complete' ? STATUS_PICKUP : STATUS_PROCESSING
      
        if pickup?
          
          if status_elem
            @completion_time = status_elem.attributes['completionTime']
            @pickup_url = status_elem.attributes['pickup']
            @browser_width = (status_elem.attributes['browserWidth'] || "0").to_i
            @browser_height = (status_elem.attributes['browserHeight'] || "0").to_i          
          end
        end
        @status
      end
    
      # Returns the pickup url after a successful status request. You can use this to either download the zip file 
      # directly or use the zip file as the base name to derive the individual download paths.
      def pickup_url
          @pickup_url
      end
      
      # Returns the browser width after a successful status request.
      def browser_width
        @browser_width
      end
      
      # Returns the browser height after a successful status request.
      def browser_height
        @browser_height
      end
      
      def fetch_when_complete(size = :small)
        while not pickup?
          sleep @duration_estimate
          check_status
        end
        fetch(size)
      end

      # Fetch an image from the webthumb server.
      # If the job has not yet finished then the server will return an error so check status first or use fetch_when_complete()
      # Images are cached in the context of this Job so consequent calls are not requested from server again.
      # Cache is experimental, dont know if it is a good idea.
      def fetch(size = :small)
        unless @cache.has_key?(size)
          response = do_request(build_fetch_xml(size))
          @cache[size] = response
        end
        @cache[size]
      end

      # Write the data to disk.
      # *data: the bytes of the image as returned by fetch/fetch_when_complete
      # *name: a filename
      # Will return a File object
      def write_file(data, name)
        raise WebthumbException.new('No data given') if data == nil || data.size == 0
        File.open(name, 'wb+') do |file|
          file.write(data)
          file.close
          file
        end
      end

      # Is the status attribute set to STATUS_PICKUP ?
      def pickup?
        @status == STATUS_PICKUP
      end
      # Is the status attribute set to STATUS_PROCESSING ?
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
        extra = @pickup_url ? " / Completion Time: #{@completion_time} / Pickup Url: #{@pickup_url}" : ''
        "Job: #{@job_id} / Status: #{@status} / Submission Time #{@submission_datetime} / Duration Estimate #{@duration_estimate}#{extra}"
      end
    end
  end
end
