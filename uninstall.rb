# Performs a gsub on lines within a file
def gsub_file(path, regexp, *args, &block)
  content = File.read(path).gsub(regexp, *args, &block)
  File.open(path, 'wb') { |file| file.write(content) }
end

puts 'Removing before_filter to application_controller'

line = "\#asset_manager plugin - required to load controller-scoped assets automaticly\nbefore_filter :auto_load_controller_assets"
gsub_file 'app/controllers/application_controller.rb', /(#{Regexp.escape(line)})/mi do |match|
  ""
end

puts 'Removing file: config/asset_manager.yml'
File.delete('config/asset_manager.yml')

puts '############## Reminder #################'
puts 'Remove the following lines from your app/views/layout/* files'
puts ''
puts '<%= stylesheet_manager_base %>'
puts '<%= javascript_manager_base %>'
puts '############## Reminder #################'