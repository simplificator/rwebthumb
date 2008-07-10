require 'helper'
class WebthumbTest < Test::Unit::TestCase
  
  
  
  def test_build_fetch()
    xml = Webthumb.new('1234').send(:build_thumbnail_xml, :url => 'http://simplificator.com')
    assert_equal('http://simplificator.com', REXML::XPath.first(xml, 'request/url').text)
  end

  def test_build_job_status_xml()
    xml = Webthumb.new('1234').send(:build_job_status_xml, 'abcd')
    assert_equal('abcd', REXML::XPath.first(xml, 'status/job').text)
  end
end