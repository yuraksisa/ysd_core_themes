require 'singleton'

module Themes
  
  class ThemeManager
    include Singleton
        
    # Retrieves the instance
    #
    def initialize

      unless @@theme_path
        raise "ThemeManager has not been initialize. Use ThemeManager.setup"
      end
      
    end
    
    # Configure the Theme Manager
    #
    # params [Hash] options
    #   The options
    #     :theme_path
    #     :theme
    #
    #
    def self.setup(options)
     
      @@theme_path = options[:theme_path]
      @@selected_theme = options[:theme] || :default
      
      # Loads the themes
      @@themes = { }
      Dir.foreach(@@theme_path) do |filename|
         theme_root_path = File.join(@@theme_path, filename)
         if File.directory?(theme_root_path) and not filename.match(/^\./)
           @@themes[filename.to_sym]=Theme.new(filename, theme_root_path)
         end
      end
           
    end
   
    # ---------------------------------------------------------
   
    # Get the available themes
    #
    def theme_names
      @@themes.keys
    end

    # Retrieve the selected theme
    def selected_theme
      @@themes[@@selected_theme]
    end
    
    # Get the theme
    #
    def theme(name)
      if name
        @@themes[name]
      else
        default_theme
      end
    end
    
    
  end
  
  #
  # It represents a theme
  #
  class Theme

    attr_reader :name
    attr_reader :root_path
    attr_reader :regions
    
    #
    # @param [String] name
    #    The theme name
    #
    # @param [String] root_path
    #    The theme root path
    #
    def initialize(name, root_path)
      @name = name
      @root_path = root_path
      @regions = ['top', 'header', 'container_header', 'container_headline', 'content_top', 'content_left', 'content_right', 'content_bottom', 'container_bottom', 'bottom']
    end
      
    # Retrieve the resource full path that will allow load the file from the file system 
    #
    # @param [String] resource
    #     Resource path
    #
    # @param [String] type
    #     The resource type : static or template
    #
    # @param [String] extension
    #     If the resource belongs to a extension
    #
    # @return
    #     The full path of the resource or nil if it does not exist
    #  
    def resource_path(resource, type='template', extension=nil)
      
      path = nil
      
      if ['static', 'template'].index(type)
        if extension
          path=File.expand_path(File.join(root_path, 'extensions', extension, type, resource))
        else
          path=File.expand_path(File.join(root_path, type, resource))
        end
      
        (File.exist?(path) and File.file?(path))?path:nil
      
      end
    
    end  
          
  end

end