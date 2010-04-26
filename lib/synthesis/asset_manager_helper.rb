module Synthesis
  module AssetManagerHelper
    
    def javascript_manager(*args)
      @page_js = args
    end

    def stylesheet_manager(*args)
      @page_css = args
    end

    def javascript_manager_base(*sources)
      sources << @controller_js           if @controller_js
      @page_js.each { |a| sources << a }  if @page_js
      options = sources.last.is_a?(Hash) ? sources.pop.stringify_keys : { }

      if sources.include?(:defaults) 
        sources = sources[0..(sources.index(:defaults))] + 
          ['prototype', 'effects', 'dragdrop', 'controls'] + 
          (File.exists?("#{Rails.root}/public/javascripts/application.js") ? ['application'] : []) + 
          sources[(sources.index(:defaults) + 1)..sources.length]
        sources.delete(:defaults)
      end

      sources.collect!{|s| s.to_s}
      sources = (should_merge? ? 
        AssetPackage.targets_from_sources("javascripts", sources) : 
        AssetPackage.sources_from_targets("javascripts", sources))
        
      sources.collect {|source| javascript_include_tag(source, options) }.join("\n")
    end

    def stylesheet_manager_base(*sources)
      sources << @controller_css          if @controller_css
      @page_css.each { |a| sources << a } if @page_css
      options = sources.last.is_a?(Hash) ? sources.pop.stringify_keys : { }

      sources.collect!{|s| s.to_s}
      sources = (should_merge? ? 
        AssetPackage.targets_from_sources("stylesheets", sources) : 
        AssetPackage.sources_from_targets("stylesheets", sources))

      sources.collect { |source| stylesheet_link_tag(source, options) }.join("\n")    
    end

    
    def auto_load_controller_assets
      current_controller = self.controller_path
      @controller_js  = current_controller if File.exists?("#{RAILS_ROOT}/public/javascripts/views/#{ current_controller }.js")
      @controller_css = current_controller if File.exists?("#{RAILS_ROOT}/public/stylesheets/views/#{ current_controller }.css")
    end

    
    def should_merge?
      AssetPackage.merge_environments.include?(Rails.env)
    end

  end
end