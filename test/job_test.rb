require File.join(File.dirname(__FILE__), 'helper')
class JobTest < Test::Unit::TestCase
  JOB_XML = <<-EOF
    <webthumb>
      <jobs>
        <job estimate='20' time='2008-02-27 12:49:48' url='http://blog.joshuaeichorn.com' cost='1'>wt47c5f71c37c3a</job>
      </jobs>
    </webthumb>
  EOF

  JOBLESS_XML = <<-EOF
    <webthumb>
    </webthumb>
  EOF

  def setup_job_from_xml(xml)
    job_xml = REXML::Document.new(xml)
    @job = Job.from_thumbnail_xml('1234', job_xml)
  end

  def test_from_thumbnail_xml
    setup_job_from_xml(JOB_XML)
    assert_equal('1234', @job.api_key)
    assert_equal(20, @job.duration_estimate)
    assert_equal(Time.parse('2008-02-27 19:49:48 UTC'), @job.submission_datetime)
    assert_equal('http://blog.joshuaeichorn.com', @job.url)
    assert_equal(1, @job.cost)
    assert_equal('wt47c5f71c37c3a', @job.job_id)
  end

  def test_build_fetch()
    setup_job_from_xml(JOB_XML)
    xml = @job.send(:build_fetch_xml)
    assert_equal('small', REXML::XPath.first(xml, 'fetch/size').text)
    assert_equal('wt47c5f71c37c3a', REXML::XPath.first(xml, 'fetch/job').text)
  end

  def test_build_status_xml()
    setup_job_from_xml(JOB_XML)
    xml = @job.send(:build_status_xml)
    assert_equal('wt47c5f71c37c3a', REXML::XPath.first(xml, 'status/job').text)
  end

  def test_from_thumbnail_xml_without_any_jobs()
    setup_job_from_xml(JOBLESS_XML)
    assert_nil @job
  end
end
