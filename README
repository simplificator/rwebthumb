== rwebthumb

= what is it
A Ruby wrapper for the webthumb API from http://webthumb.bluga.net and a generator
for the easythumb API

= Installation
sudo gem update --system (in case you are not yet on version 1.2.0 or higher)
sudo gem sources -a http://gems.github.com (only once)
sudo gem install simplificator-rwebthumb


= Usage
# require the libs
require 'rubygems'
require 'rwebthumb'
include Simplificator::Webthumb

# Creating a Webthumb Object. This is used as your main access point.
wt = Webthumb.new('YOUR API KEY')

# Create a new thumbnail job
job = wt.thumbnail(:url => 'http://simplificator.com')

# fetch the thumbnail. this might throw an exception from server side
# if thumb is not ready yet
job.fetch(:large)

# you can check the status of a job
job.check_status()

# or fetch the thumbnail when it is complete
job.fetch_when_complete(:large)

# once thumbnails are fetched they are cached within the job. so a new fetch will not go to the server again

# there is a helper method to write the images to disk
job.write_file(job.fetch(:custom), '/tmp/test.jpg')

# if you have a job ID then you can use this to get a Job object and then use the fetch_xyz methods
wt.job_status(JOB_ID)

# generate a Easythumb URL
et = Easythumb.new('YOUR_API_KEY', 'YOUR_USER_ID')
# This returns an URL which you can directly use in your webpage
et.build_url(:url => 'http://simplificator.com', :size => :large, :cache => 1)

