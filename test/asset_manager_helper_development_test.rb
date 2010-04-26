$:.unshift(File.dirname(__FILE__) + '/../lib')

ENV['RAILS_ENV'] = "development"
require File.dirname(__FILE__) + '/../../../../config/environment'
require 'test/unit'
require 'rubygems'
require 'mocha'

require 'action_controller/test_process'

ActionController::Base.logger = nil
ActionController::Routing::Routes.reload rescue nil

class AssetManagerHelperDevelopmentTest < Test::Unit::TestCase
  include ActionController::Assertions::DomAssertions
  include ActionController::TestCase::Assertions
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::AssetTagHelper
  include Synthesis::AssetManagerHelper

  def setup
    Synthesis::AssetPackage.asset_base_path    = "#{Rails.root}/vendor/plugins/asset_manager/test/assets"
    Synthesis::AssetPackage.asset_manager_yml = YAML.load_file("#{Rails.root}/vendor/plugins/asset_manager/test/asset_manager.yml")

    Synthesis::AssetPackage.any_instance.stubs(:log)

    @controller = Class.new do
      def request
        @request ||= ActionController::TestRequest.new
      end
    end.new
  end
  
  def build_js_expected_string(*sources)
    sources.map {|s| javascript_include_tag(s) }.join("\n")
  end
    
  def build_css_expected_string(*sources)
    sources.map {|s| stylesheet_link_tag(s) }.join("\n")
  end
    
  def test_js_basic
    assert_dom_equal build_js_expected_string("prototype"),
      javascript_manager_base("prototype")
  end

  def test_js_multiple_packages
    assert_dom_equal build_js_expected_string("prototype", "foo"), 
      javascript_manager_base("prototype", "foo")
  end
  
  def test_js_unpackaged_file
    assert_dom_equal build_js_expected_string("prototype", "foo", "not_part_of_a_package"), 
      javascript_manager_base("prototype", "foo", "not_part_of_a_package")
  end
  
  def test_js_multiple_from_same_package
    assert_dom_equal build_js_expected_string("prototype", "effects", "controls", "not_part_of_a_package", "foo"), 
      javascript_manager_base("prototype", "effects", "controls", "not_part_of_a_package", "foo")
  end

  def test_js_by_package_name
    assert_dom_equal build_js_expected_string("prototype", "effects", "controls", "dragdrop"), 
      javascript_manager_base(:base)
  end
  
  def test_js_multiple_package_names
    assert_dom_equal build_js_expected_string("prototype", "effects", "controls", "dragdrop", "foo", "bar", "application"), 
      javascript_manager_base(:base, :secondary)
  end

  def test_css_basic
    assert_dom_equal build_css_expected_string("screen"),
      stylesheet_manager_base("screen")
  end

  def test_css_multiple_packages
    assert_dom_equal build_css_expected_string("screen", "foo", "subdir/bar"), 
      stylesheet_manager_base("screen", "foo", "subdir/bar")
  end
  
  def test_css_unpackaged_file
    assert_dom_equal build_css_expected_string("screen", "foo", "not_part_of_a_package", "subdir/bar"), 
      stylesheet_manager_base("screen", "foo", "not_part_of_a_package", "subdir/bar")
  end
  
  def test_css_multiple_from_same_package
    assert_dom_equal build_css_expected_string("screen", "header", "not_part_of_a_package", "foo", "bar", "subdir/foo", "subdir/bar"), 
      stylesheet_manager_base("screen", "header", "not_part_of_a_package", "foo", "bar", "subdir/foo", "subdir/bar")
  end

  def test_css_by_package_name
    assert_dom_equal build_css_expected_string("screen", "header"), 
      stylesheet_manager_base(:base)
  end
  
  def test_css_multiple_package_names
    assert_dom_equal build_css_expected_string("screen", "header", "foo", "bar", "subdir/foo", "subdir/bar"), 
      stylesheet_manager_base(:base, :secondary, "subdir/styles")
  end
  
end
