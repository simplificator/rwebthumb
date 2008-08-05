require 'helper'
class WebthumbTest < Test::Unit::TestCase
  
  
  
  def test_build_fetch()
    xml = Webthumb.new('1234').send(:build_thumbnail_xml, 
      :url => 'http://simplificator.com', 
      :videothumb => true, :fullthumb => true, :effect => 'dropshadow', :output_type => :jpg, 
      :width => 1024, :height => 2048, :custom_thumbnail => {:width => 300, :height => 400},
      :excerpt => {:x => 30, :y => 40, :width => 600, :height => 345}, :delay => 20, :notify => 'http://foo.bar.com')
    assert_equal('http://simplificator.com', REXML::XPath.first(xml, 'request/url').text)
    assert_equal('1', REXML::XPath.first(xml, 'request/videothumb').text)
    assert_equal('1', REXML::XPath.first(xml, 'request/fullthumb').text)
    assert_equal('dropshadow', REXML::XPath.first(xml, 'request/effect').text)
    assert_equal('jpg', REXML::XPath.first(xml, 'request/outputType').text)
    assert_equal('1024', REXML::XPath.first(xml, 'request/width').text)
    assert_equal('2048', REXML::XPath.first(xml, 'request/height').text)
    assert_equal('300', REXML::XPath.first(xml, 'request/customThumbnail').attributes['width'])
    assert_equal('400', REXML::XPath.first(xml, 'request/customThumbnail').attributes['height'])
    assert_equal('30', REXML::XPath.first(xml, 'request/excerpt/x').text)
    assert_equal('40', REXML::XPath.first(xml, 'request/excerpt/y').text)
    assert_equal('600', REXML::XPath.first(xml, 'request/excerpt/width').text)
    assert_equal('345', REXML::XPath.first(xml, 'request/excerpt/height').text)
    assert_equal('20', REXML::XPath.first(xml, 'request/delay').text)
    assert_equal('http://foo.bar.com', REXML::XPath.first(xml, 'request/notify').text)
    
    
  end

  def test_build_job_status_xml()
    xml = Webthumb.new('1234').send(:build_job_status_xml, 'abcd')
    assert_equal('abcd', REXML::XPath.first(xml, 'status/job').text)
  end
end