require 'helper'
class BaseTest < Test::Unit::TestCase
  def test_api_key_required
    assert_raises(WebthumbException) { Base.new('') }
    assert_raises(WebthumbException) { Base.new(nil) }
  end
  
  def test_parse_webthumb_date
    [['2000-1-1 14:00:00', '2000-1-1 07:00:00'], ['2000-1-1 07:00:00', '2000-1-1 00:00:00'], ['2000-8-1 07:44:2', '2000-8-1 00:44:02']].each do |item|
      utc = DateTime.strptime(item[0], '%Y-%m-%d %H:%M:%S')
      mst = Base.parse_webthumb_datetime(item[1])
      assert_equal(utc, mst)
    end
  end
  
  def test_build_root_node()
    root = Base.new('1234').build_root_node()
    assert_not_nil(root)
    assert_not_nil(REXML::XPath.first(root, '/'))
    assert_not_nil(REXML::XPath.first(root, '/apikey'))
    assert_equal('1234', REXML::XPath.first(root, '/apikey').text)
  end
end