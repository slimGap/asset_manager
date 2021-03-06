#Add Standard Directories
%w{stylesheets javascripts}.each do |base|
  ext = base=='stylesheets' ? 'css' : 'js'
  %w{common vendor views}.each {|dir| `mkdir public/#{base}/#{dir}` }
  
  # Add you own common files (ext: jquery)
  %w{application prototype dragdrop controls effects scaffold}.each do |common_files|
    `mv public/#{base}/#{common_files}.#{ext} public/#{base}/common/#{common_files}.#{ext}`
  end
end

# Performs a gsub on lines within a file
def gsub_file(path, regexp, *args, &block)
  content = File.read(path).gsub(regexp, *args, &block)
  File.open(path, 'wb') { |file| file.write(content) }
end

puts 'Adding before_filter to application_controller'

line = 'class ApplicationController < ActionController::Base'
new_line = "\#asset_manager plugin - required to load controller-scoped assets automaticly\nbefore_filter :auto_load_assets"

gsub_file 'app/controllers/application_controller.rb', /(#{Regexp.escape(line)})/mi do |match|
  "#{match}\n #{new_line}\n"
end

puts 'Creating config/asset_manager.yml'
`rake asset:manager:create_yml`         #Run the rake task for generating config/asset_manager.yml

puts '############## Reminder #################'
puts 'Place the following lines in your app/views/layout/* files'
puts ''
puts '<%= stylesheet_manager_base %>'
puts '<%= javascript_manager_base %>'
puts '############## Reminder #################'