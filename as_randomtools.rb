=begin

Copyright 2020-2020, Alexander C. Schreyer
All rights reserved

THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE.

License:        GPL (http://www.gnu.org/licenses/gpl.html)

Author :        Alexander Schreyer, www.alexschreyer.net, mail@alexschreyer.net

Website:        https://alexschreyer.net/projects/random-tools-extension-for-sketchup/

Name :          Random Tools

Version:        1.1

Date :          6/25/2020

Description :   A set of tools to randomize various things in a SketchUp Model: Object placement,
                rotation, scale, face extrusion, vertices, textures. Also allows to place objects
                randomly on faces or on edges and to swap components.
                
                This extension combines several of my random scripts from my book and sketchupfordesign.com.

Usage :         Tools > Random Tools
                or Random Tools toolbar

History:        1.0 (6/19/2020):
                - Initial release
                1.1 (6/25/2020):
                - Added correct help webpage URL
                - Added toolbar
                - Randomizing objects now works on groups as well (uses bounding box center)
                - Vertices now randomize correctly about their position
                - New function: Randomly swap objects (components only)
                1.2 (TBD)
                - Now saves dialog values
                - Fixed issue with vertices double-counting
                - Fixed issue with pre-2020 layer names

=end


# ========================


require 'sketchup.rb'
require 'extensions.rb'


# ========================


module AS_Extensions

  module AS_Randomtools
  
    @extversion           = "1.1"
    @exttitle             = "Random Tools"
    @extname              = "as_randomtools"
    
    @extdir = File.dirname(__FILE__)
    @extdir.force_encoding('UTF-8') if @extdir.respond_to?(:force_encoding)
    
    loader = File.join( @extdir , @extname , "as_randomtools.rb" )
   
    extension             = SketchupExtension.new( @exttitle , loader )
    extension.copyright   = "Copyright 2020-#{Time.now.year} Alexander C. Schreyer"
    extension.creator     = "Alexander C. Schreyer, www.alexschreyer.net"
    extension.version     = @extversion
    extension.description = "A set of tools to randomize various things in a SketchUp Model: Object placement, rotation, scale, face extrusion, vertices, textures. Also allows to place objects randomly on faces or on edges and to swap components."
    
    Sketchup.register_extension( extension , true )
         
  end  # module AS_Randomtools
  
end  # module AS_Extensions


# ========================
