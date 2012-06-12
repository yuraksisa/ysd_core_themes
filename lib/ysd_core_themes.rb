require 'singleton'
require 'yaml'

module Themes

  #
  # The ThemeManager is the responsible of managing themes
  #
  # Themes is defined in a directory structure, and each theme has a definition file, in yaml format,
  # with the name of the theme.
  #
  #  - themes
  #    - default
  #    - yuraksisa
  #
  # Usage:
  #
  #   Themes::ThemeManager.setup(root_path)
  #   Themes::ThemeManager.instance.selected_theme.resource_path(path, type, extension)
  #
  #  
  class ThemeManager
    include Singleton
    
    attr_reader :themes_path
            
    def initialize

      unless defined?(@@themes_root_path)
        raise "ThemeManager has not been initialize. Use ThemeManager.setup"
      end
      
      @themes_path = @@themes_root_path
      load_themes
      select_theme(:default)
      
    end
    
    # Configure the Theme Manager
    #
    # @param [String] root_path
    #
    #  The path where themes are located
    #
    #
    def self.setup(root_path)
         
      unless defined?(@@theme_manager)   
         
        @@themes_root_path = root_path     
        @@theme_manager = ThemeManager.instance
      
      end
                   
    end
   
    #
    # Get the available themes
    #
    def theme_names
      @themes.keys
    end

    #
    # Retrieve the selected theme
    #
    def selected_theme
      @themes[@selected_theme]
    end
    
    #
    # Sets the selected theme
    #
    def select_theme(name)
      @selected_theme = name if @themes.has_key?(name)
    end
    
    #
    # Get the theme
    # 
    # @param [String] name
    #   the theme name
    #
    # @return [Theme]
    #   A theme instance
    #
    def theme(name)
      @themes[name]
    end
    
    private
    
    #
    # Load the themes from the themes_path
    #
    def load_themes

      unless File.exist?(@themes_path)
        raise "Themes path #{@themes_path} does not exist"
      end
      
      @themes = {}
      
      Dir.foreach(@themes_path) do |filename|
         theme_root_path = File.join(@themes_path, filename)
         if File.directory?(theme_root_path) and not filename.match(/^\./)
           @themes[filename.to_sym]=Theme.new(filename, theme_root_path)
         end
      end
    
      if @themes.empty?
        raise "There are not themes in #{@themes_path}"
      end
    
    end
    
    
  end
  
  #
  # Each instance of Theme represents a theme
  #
  #
  class Theme

    attr_reader :name
    attr_reader :description
    attr_reader :root_path
    attr_reader :regions
    attr_reader :scripts
    attr_reader :styles
        
    #
    # @param [String] name
    #    The theme name
    #
    # @param [String] root_path
    #    The theme root path
    #
    def initialize(name, root_path)
      
      @root_path = root_path    
      
      path = "#{root_path}/#{name}.yaml"
           
      options = if File.exist?(path)      
                  options = YAML::load(File.open(path))
                else
                  []
                end
      
      @name        = name
      @description = options['description']
      @regions     = options['regions'] || Theme.default_regions
      @scripts     = options['scripts']
      @styles      = options['styles']
        
    end
    
    # Retrieve the default regions
    #
    # @return [Array]
    #
    #   An array of string with the name of the regions
    #
    def self.default_regions
    
      ['top', 'header', 'container_header', 'container_headline', 'content_top', 'content_left', 'content_right', 'content_bottom', 'container_bottom', 'bottom']
    
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