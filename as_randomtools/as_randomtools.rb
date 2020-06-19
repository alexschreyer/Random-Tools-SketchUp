# ==================
# Main file for Random Tools
# By: Alexander Schreyer
# ==================


require 'sketchup.rb'


# ==================


module AS_Extensions

  module AS_Randomtools
  
  
    # ==================
    
    
    def self.random_extrusion
    # Randomly extrudes all selected faces
        
        mod = Sketchup.active_model
        toolname = "Random Face Push/Pull"
        
        # Get all selected faces
        all_faces = mod.selection.grep( Sketchup::Face )
        
        if !all_faces.empty?
        
            # Get all the parameters from input dialog
            prompts = [ "MIN Extrusion (distance) " , "MAX Extrusion (distance) " , "Create New Faces " ]
            defaults = [ "0" , "1'" , "Yes" ]
            lists = [ "" , "" , "Yes|No" ]
            res = UI.inputbox( prompts , defaults , lists , toolname )
            return if !res
            
            mod.start_operation toolname
            
            begin
            
                # Get extrusion distances and convert to length
                min = res[0].to_l
                max = res[1].to_l

                # Iterate through selection
                all_faces.each_with_index { |e,i|

                    # Extrude face
                    e.pushpull( min + rand * ( max - min ) , res[2] == "Yes" ? true : false )
                    
                    # Life is always better with some feedback while SketchUp works
                    Sketchup.status_text = toolname + " | Done with face #{(i+1).to_s}"

                }
                
            rescue Exception => e    
            
                UI.messagebox("Couldn't do it! Error: #{e}")
                
            end
            
            mod.commit_operation
            
        else  # Can't start tool
        
            UI.messagebox "Select at least one ungrouped face."
        
        end

    end  # random_extrusion    
    
    
    # ==================
    
    
    def self.random_vertices
    # Randomly positions vertices for all selected faces
        
        mod = Sketchup.active_model
        ent = mod.entities
        toolname = "Random Vertex Positions"
        
        # Get all selected edges
        all_edges = mod.selection.grep( Sketchup::Edge )
        
        if !all_edges.empty?
        
            # Get all the parameters from input dialog
            prompts = [ "MAX Variation RED (x distance) " , "MAX Variation GREEN (y distance) " , "MAX Variation BLUE (z distance) " ]
            defaults = [ "1'" , "1'" , "1'" ]
            res = UI.inputbox( prompts , defaults , toolname )
            return if !res
            
            mod.start_operation toolname
            
            begin
            
                # Get max distances and convert to length
                max_x = res[0].to_l
                max_y = res[1].to_l
                max_z = res[2].to_l
            
                # Get all the unique vertices
                vertices = []
                all_edges.each { |e| vertices << e.vertices }
                vertices.uniq!

                vertices.each_with_index { |v,i| 

                    t = Geom::Transformation.new [ rand * max_x , rand * max_y , rand * max_z ]
                    ent.transform_entities( t , v )
                    
                    # Life is always better with some feedback while SketchUp works
                    Sketchup.status_text = toolname + " | Done with vertex #{(i+1).to_s}"
                    
                }
                
            rescue Exception => e    
            
                UI.messagebox("Couldn't do it! Error: #{e}")
                
            end
            
            mod.commit_operation
            
        else  # Can't start tool
        
            UI.messagebox "Select at least one ungrouped edge (e.g. a face border or line)."
        
        end

    end  # random_vertices    
    
    
    # ==================    
    
    
    def self.random_place_faces
    # Randomly places components on faces
        
        mod = Sketchup.active_model
        ent = mod.entities
        sel = mod.selection
        toolname = "Place Components Randomly on Faces"
        
        # Get all the components in our selection
        comp = sel.grep( Sketchup::ComponentInstance )

        # Get all the faces in our selection
        all_faces = sel.grep( Sketchup::Face )
        
        if !( all_faces.empty? or comp.empty? )
        
            # Get all the parameters from input dialog
            lay = []
            mod.layers.each { |l| lay << l.display_name }
            
            prompts = [ "MAX Number of Copies per Face " , "MAX Rotation Variation (degrees) " , "Scale Variation Factor (0 = none) " , "Orientation " , "Place Copies on Tag/Layer " ]
            defaults = [ "10" , "360" , "0.5", "Normal" , lay[0] ]
            lists = [ "" , "" , "" , "Up|Normal" , lay.join("|") ]
            res = UI.inputbox( prompts , defaults , lists , toolname )
            return if !res
            
            mod.start_operation toolname
            
            begin
            
                # Get the first component's definition from our selection
                comp = comp[0].definition
            
                # Get parameters from dialog
                num = res[0].to_i
                max_rot = res[1].to_i
                scale_var = res[2].to_f
                
                # Select a new layer/tag so that we can turn the created copies on/off
                # Also add everything to a group to keep inspector manageable
                clayer = mod.layers[ res[4].to_s ]
                group = mod.entities.add_group
                group.layer = clayer

                # Iterate through all selected, ungrouped faces
                all_faces.each_with_index { |e,i|

                    # Get bounding box and normal vector for face
                    bbox = e.bounds
                    norm = e.normal

                    # Place copies on each face
                    num.times {

                        # Get a random point on the face's plane - based on bounding box
                        pt = Geom::Point3d.new
                        pt.x = bbox.min.x + rand * bbox.width
                        pt.y = bbox.min.y + rand * bbox.height
                        pt.z = bbox.min.z + rand * bbox.depth
                        plpt = pt.project_to_plane( e.plane )

                        # Some points will be off the face, ignore those. Otherwise...
                        if ( e.classify_point(plpt) == Sketchup::Face::PointInside ) 

                           # Scale copies randomly          
                           t_sca = Geom::Transformation.scaling plpt, ( 1 - scale_var / 2 + rand * scale_var )
                           
                           if res[3] == "Up"
                           
                               # Use the following if things need to point up:
                               t_loc = Geom::Transformation.new plpt, [0,0,1]
                               t_rot = Geom::Transformation.rotation plpt, [0,0,1] , (rand * max_rot).degrees      
                               
                           else    

                               # Use the following if you need to align things normal to face:
                               t_loc = Geom::Transformation.new plpt, norm
                               t_rot = Geom::Transformation.rotation plpt, norm, (rand * max_rot).degrees
                               
                           end

                           # Now place the copy and move it to the new layer
                           new = group.entities.add_instance comp, ( t_sca * t_rot * t_loc )
                           new.layer = clayer

                           # Life is always better with some feedback while SketchUp works
                           Sketchup.status_text = toolname + " | Done with face #{(i+1).to_s}"

                        end

                     }

                }

                
            rescue Exception => e    
            
                UI.messagebox("Couldn't do it! Error: #{e}")
                
            end
            
            mod.commit_operation
            
        else  # Can't start tool
        
            UI.messagebox "Select one component instance (a copy) and at least one ungrouped face."
        
        end

    end  # random_place_faces  
    
    
    # ==================    
    
    
    def self.random_place_edges
    # Randomly places components on edges
        
        mod = Sketchup.active_model
        ent = mod.entities
        sel = mod.selection
        toolname = "Place Components Randomly on Edges"
        
        # Get all the components in our selection
        comp = sel.grep( Sketchup::ComponentInstance )

        # Get all the edges in our selection
        all_edges = sel.grep( Sketchup::Edge )
        
        if !( all_edges.empty? or comp.empty? )
        
            # Get all the parameters from input dialog
            lay = []
            mod.layers.each { |l| lay << l.display_name }
            
            prompts = [ "MAX Number of Copies per Edge " , "MAX Rotation Variation (degrees) " , "Scale Variation Factor (0 = none) " , "Orientation " , "Place Copies on Tag/Layer " ]
            defaults = [ "2" , "360" , "0.5", "Normal" , lay[0] ]
            lists = [ "" , "" , "" , "Up|Normal" , lay.join("|") ]
            res = UI.inputbox( prompts , defaults , lists , toolname )
            return if !res
            
            mod.start_operation toolname
            
            begin
            
                # Get the first component's definition from our selection
                comp = comp[0].definition
            
                # Get parameters from dialog
                num = res[0].to_i
                max_rot = res[1].to_i
                scale_var = res[2].to_f
                
                # Select layer/tag so that we can turn the created copies on/off
                # Also add everything to a group to keep inspector manageable
                clayer = mod.layers[ res[4].to_s ]
                group = mod.entities.add_group
                group.layer = clayer

                # Iterate through all selected, ungrouped edges
                all_edges.each_with_index { |e,i|

                    # Get bounding box and normal vector (based on adjoining faces)
                    bbox = e.bounds
                    if e.faces.length == 1
                        norm = e.faces[0].normal
                    elsif e.faces.length == 2
                        norm = e.faces[0].normal + e.faces[1].normal
                    else
                        norm = [0,0,1]
                    end

                    # Place copies on each face
                    num.times {

                        # Get a random point on the line - based on bounding box
                        pt = Geom::Point3d.new
                        pt.x = bbox.min.x + rand * bbox.width
                        pt.y = bbox.min.y + rand * bbox.height
                        pt.z = bbox.min.z + rand * bbox.depth
                        plpt = pt.project_to_line( e.line )

                        # Some points could be off the line, ignore those. Otherwise...
                        if ( plpt.on_line?( e.line ) ) 

                           # Scale copies randomly          
                           t_sca = Geom::Transformation.scaling plpt, ( 1 - scale_var / 2 + rand * scale_var )
                           
                           if res[3] == "Up"
                           
                               # Use the following if things need to point up:
                               t_loc = Geom::Transformation.new plpt, [0,0,1]
                               t_rot = Geom::Transformation.rotation plpt, [0,0,1] , (rand * max_rot).degrees      
                               
                           else    

                               # Use the following if you need to align things normal to face:
                               t_loc = Geom::Transformation.new plpt, norm
                               t_rot = Geom::Transformation.rotation plpt, norm, (rand * max_rot).degrees
                               
                           end

                           # Now place the copy and move it to the new layer
                           new = group.entities.add_instance comp, ( t_sca * t_rot * t_loc )
                           new.layer = clayer

                           # Life is always better with some feedback while SketchUp works
                           Sketchup.status_text = toolname + " | Done with edge #{(i+1).to_s}"

                        end

                     }

                }

                
            rescue Exception => e    
            
                UI.messagebox("Couldn't do it! Error: #{e}")
                
            end
            
            mod.commit_operation
            
        else  # Can't start tool
        
            UI.messagebox "Select one component instance (a copy) and at least one ungrouped edge."
        
        end

    end  # random_place_edges    
    
    
    # ==================
    
    
    def self.randomize_objects
    # Randomizes objects/components (scale, rotation, position)
        
        mod = Sketchup.active_model
        sel = mod.selection
        toolname = "Randomize Objects (Scale, Rotation, Position)"
        
        # Get all components from selection
        all_objects = []
        all_objects.push( *sel.grep( Sketchup::ComponentInstance ) )
        
        if !all_objects.empty?
        
            prompts = [ "MAX Rotation Variation (degrees) " , "MAX Position Variation (distance) " , "Scale Variation Factor (0 = none) " ]
            defaults = [ "360" , "0" , "0.5" ]
            res = UI.inputbox( prompts , defaults , toolname )
            return if !res        
            
            mod.start_operation toolname
            
            begin
            
                max_rot = res[0].to_i
                pos_var = res[1].to_l
                scale_var = res[2].to_f
            
                # Iterate through all selected objects
                all_objects.each_with_index { |e,i|

                    # Transform this object
                    t_rot = Geom::Transformation.rotation e.transformation.origin , e.transformation.zaxis , ( rand * max_rot ).degrees
                    t_sca = Geom::Transformation.scaling e.transformation.origin , ( 1 - scale_var / 2 + rand * scale_var )
                    t_pos = Geom::Transformation.translation Geom::Vector3d.linear_combination( rand * pos_var , e.transformation.xaxis , rand * pos_var , e.transformation.yaxis )

                    # Combine transformations and apply
                    e.transform! ( t_rot * t_sca * t_pos )
                    
                    # Life is always better with some feedback while SketchUp works
                    Sketchup.status_text = toolname + " | Done with object #{(i+1).to_s}"
                
                }
                
            rescue Exception => e    
            
                UI.messagebox("Couldn't do it! Error: #{e}")
                
            end
            
            mod.commit_operation
            
        else  # Can't start tool
        
            UI.messagebox "Select at least one group or component instance (i.e. objects in your model)."
        
        end

    end  # randomize_objects     
    
    
    # ==================
    
    
    def self.random_texture_placement
    # Randomly positions existing textures on selected faces
        
        mod = Sketchup.active_model
        sel = mod.selection
        toolname = "Randomize Texture Positions"
        
        # Get all ungrouped faces and those that are inside groups (from selection)
        all_faces = []

        # Ungrouped faces first
        all_faces.push( *sel.grep( Sketchup::Face ) )

        # Grouped faces next
        sel.grep( Sketchup::Group ).each { |g|
          g.make_unique  # Need to do this, otherwise groups share same definition
          all_faces.push( *g.entities.grep( Sketchup::Face ) )
        }
        
        if !all_faces.empty?
            
            mod.start_operation toolname
            
            begin
            
                # Iterate through all faces and randomly arrange the textures
                all_faces.each_with_index { |f,i|

                    pt_array = []
                    pt_array[0] = f.vertices[0].position

                    # Radomly scale based on face size
                    pt_array[1] = Geom::Point3d.new(rand * f.bounds.width,rand * f.bounds.height,0)

                    # Arrange both the front and the back face textures
                    f.position_material(f.material, pt_array, true)
                    f.position_material(f.back_material, pt_array, false)
                    
                    # Life is always better with some feedback while SketchUp works
                    Sketchup.status_text = toolname + " | Done with face #{(i+1).to_s}"

                }
                
            rescue Exception => e    
            
                UI.messagebox("Couldn't do it! Error: #{e}")
                
            end
            
            mod.commit_operation
            
        else  # Can't start tool
        
            UI.messagebox "Select at least one face or group that has an image texture applied directly to its face(s). Note: This tool will make all copies of groups unique."
        
        end

    end  # random_texture_placement  


    # ==================
    
    
    def self.show_url( title , url )
    # Show website either as a WebDialog or HtmlDialog
    
      if Sketchup.version.to_f < 17 then   # Use old dialog
        @dlg = UI::WebDialog.new( title , true ,
          title.gsub(/\s+/, "_") , 1000 , 600 , 100 , 100 , true);
        @dlg.navigation_buttons_enabled = false
        @dlg.set_url( url )
        @dlg.show      
      else   #Use new dialog
        @dlg = UI::HtmlDialog.new( { :dialog_title => title, :width => 1000, :height => 600,
          :style => UI::HtmlDialog::STYLE_DIALOG, :preferences_key => title.gsub(/\s+/, "_") } )
        @dlg.set_url( url )
        @dlg.show
        @dlg.center
      end  
    
    end    


    def self.show_help
    # Show the website as an About dialog
    
      show_url( "#{@exttitle} - Help" , 'https://alexschreyer.net/projects/?tag=sketchup+plugins-extensions' )

    end # show_help


    # ==================


    if !file_loaded?(__FILE__)

      # Add to the SketchUp help menu
      menu = UI.menu( "Tools" ).add_submenu( @exttitle )
      
      menu.add_item( "Random Face Push/Pull" ) { self.random_extrusion }
      menu.add_item( "Random Vertex Positions" ) { self.random_vertices }
      
      menu.add_separator
      
      menu.add_item( "Place Components Randomly on Faces" ) { self.random_place_faces }
      menu.add_item( "Place Components Randomly on Edges" ) { self.random_place_edges }      
      
      menu.add_separator
      
      menu.add_item( "Randomize Objects (Scale, Rotation, Position)" ) { self.randomize_objects }
      menu.add_item( "Randomize Texture Positions" ) { self.random_texture_placement }
      
      menu.add_separator
      
      # And a link to get help
      menu.add_item( "Help" ) { self.show_help }

      # Let Ruby know we have loaded this file
      file_loaded(__FILE__)

    end # if


    # ==================


  end # module AS_Randomtools

end # module AS_Extensions


# ==================
