=begin

Copyright 2020-2025, Alexander C. Schreyer
All rights reserved

THIS SOFTWARE IS PROVIDED 'AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHOR OR ANY COPYRIGHT HOLDER BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY ARISING FROM, OUT OF OR IN CONNECTION WITH THIS SOFTWARE OR THE USE OR OTHER DEALINGS IN THIS SOFTWARE.

WHERE APPLICABLE, THIRD-PARTY MATERIALS AND THIRD-PARTY PLATFORMS ARE PROVIDED 'AS IS' AND THE USER OF THIS SOFTWARE ASSUMES ALL RISK AND LIABILITY REGARDING ANY USE OF (OR RESULTS OBTAINED THROUGH) THIRD-PARTY MATERIALS OR THIRD-PARTY PLATFORMS.

License:        GPL (https://www.gnu.org/licenses/gpl-3.0.html)

Author :        Alexander Schreyer, www.alexschreyer.net, mail@alexschreyer.net

Website:        https://alexschreyer.net/projects/random-tools-extension-for-sketchup/

Name :          Random Tools

Version:        1.5

Date :          10/04/2025

Description :   A set of tools to randomize various things in a SketchUp Model: Object placement,
                rotation, scale, face extrusion, vertices, textures. Also allows to place objects
                randomly on faces, edges or vertices and to swap or delete components.
                
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
                1.2 (unreleased)
                - Now saves dialog values
                - Fixed issue with vertices double-counting
                - Fixed issue with pre-2020 layer names
                1.2.1 (7/12/2020)
                - Fixed inch-saving bug in preferences
                - New function: Place on vertices
                1.3 (3/14/2022)
                - Added random delete tool
                1.4 (8/23/2022)
                - Fixed positioning and rotation (was only positive, now +/-)
                - Fixed random erase within groups
                - Now allows for fractional (probability) placement for faces and edges
                1.5 (10/04/2025)
                - Fixed vertices within groups crash

=end


# ========================


require 'sketchup.rb'
require 'extensions.rb'


# ========================


module AS_Extensions

  module AS_Randomtools
  
    @extversion           = "1.5"
    @exttitle             = "Random Tools"
    @extname              = "as_randomtools"
    
    @extdir = File.dirname(__FILE__)
    @extdir.force_encoding('UTF-8') if @extdir.respond_to?(:force_encoding)
    
    loader = File.join( @extdir , @extname , "as_randomtools.rb" )
   
    extension             = SketchupExtension.new( @exttitle , loader )
    extension.copyright   = "Copyright 2020-#{Time.now.year} Alexander C. Schreyer"
    extension.creator     = "Alexander C. Schreyer, www.alexschreyer.net"
    extension.version     = @extversion
    extension.description = "A set of tools to randomize various things in a SketchUp Model: Object placement, rotation, scale, face extrusion, vertices, textures. Also allows to place objects randomly on faces, edges or vertices and to swap or delete components."
    
    Sketchup.register_extension( extension , true )
         
  end  # module AS_Randomtools
  
end  # module AS_Extensions


# ========================
