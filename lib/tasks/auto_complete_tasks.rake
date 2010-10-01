require 'fileutils'
PUBLIC = File.join Rails.root, "public"
PLUGIN_ROOT = File.join Rails.root, "vendor", "plugins", "auto_complete_jquery"

namespace :autocomplete do
  
  desc 'Installs all the files for autocomplete'
  task :install do
    js_path = File.join PUBLIC, "javascripts"
    css_path = File.join PUBLIC, "stylesheets"
    img_path = File.join PUBLIC, "images"
    
    js_files  = Dir.glob File.join(Plugin.root, "javascripts", "*.js")
    css_files = Dir.glob File.join(Plugin.root, "stylesheets", "*.css")
    img_files = Dir.glob File.join(Plugin.root, "images", "*.gif")
    
    FileUtils.cp_r js_files, js_path
    FileUtils.cp_r css_files, css_path
    FileUtils.cp_r img_files, img_path
    
    puts "Files Installed Successfully!"
  end
  
end
