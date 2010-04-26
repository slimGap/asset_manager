require 'synthesis/asset_package'
require 'synthesis/asset_manager_helper'
ActionView::Base.send :include, Synthesis::AssetManagerHelper
ActionController::Base.send :include, Synthesis::AssetManagerHelper
