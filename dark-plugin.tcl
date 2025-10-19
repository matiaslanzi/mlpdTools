#==============================================================================
# Pure Data Warm & Cozy Dark Theme Plugin
#==============================================================================
# This plugin creates a warm, cozy dark theme for Pure Data patches and console
# Author: Your Name
# Version: 2.0
# Description: Applies a warm dark color scheme with amber/orange tones
#              for a comfortable coding experience
#==============================================================================

namespace eval dark_canvas_theme {
    
    #==========================================================================
    # WARM & COZY COLOR PALETTE
    #==========================================================================
    # Main theme colors - warm dark palette with amber/orange accents
    variable color_bg           #607b62    ; # Rich dark brown background
    variable color_fg           #000000    ; # Warm amber text
    variable color_hl_bg        #159081    ; # Warm brown highlight background
    variable color_hl_fg        #3cf758    ; # Light cream highlight text
    variable color_insert       #ffead1    ; # Bright orange cursor
    variable color_sel          #ffceaa    ; # Burnt orange selection
    variable color_debug        #cc9b68    ; # Soft green for debug info
    
    # Accent colors for special elements
    variable color_inlet        #c97064    ; # Warm coral for inlets
    variable color_outlet       #7c913d    ; # Sage green for outlets
    variable color_connection   #a237f3    ; # Golden brown for connections
    
    # Console/Log window colors
    variable color_log_fatal_fg #ff6b6b    ; # Bright red for fatal errors
    variable color_log_fatal_bg #4a1414    ; # Dark red background for fatal
    variable color_log_err      #ff8e8e    ; # Lighter red for errors
    variable color_log_normal   $color_fg   ; # Normal text uses main foreground
    variable color_log_normal_sel_fg #2c1810 ; # Dark text on light selection
    variable color_log_debug    #a8a070    ; # Muted yellow for debug
    variable color_log_verbose  #987238    ; # Dim brown for verbose output
    variable color_log_sel_bg   $color_hl_bg ; # Use main highlight for selection
    
    # System theme detection (for future compatibility)
    variable theme_name [option get . * TkTheme]
    
    #==========================================================================
    # COLOR DETECTION UTILITIES
    #==========================================================================
    # These functions help identify Pure Data's default colors so we can
    # replace them with our warm theme colors
    
    # Check if a color is black (Pure Data's default background)
    proc is_black {color} {
        if {[lsearch {black #000 #000000} $color] >= 0} {
            return 1
        } else {
            return 0
        }
    }
    
    # Check if a color is blue (Pure Data's default selection color)
    proc is_blue {color} {
        if {[lsearch {blue #00f #0000ff} $color] >= 0} {
            return 1
        } else {
            return 0
        }
    }
    
    # Check if a color is off-white (Pure Data's default light elements)
    proc is_offwhite {color} {
        if {$color eq "#fcfcfc"} {
            return 1
        } else {
            return 0
        }
    }
    
    # Check if a color is white (Pure Data's default text/foreground)
    proc is_white {color} {
        if {[lsearch {white #fff #ffffff} $color] >= 0} {
            return 1
        } else {
            return 0
        }
    }
    
    #==========================================================================
    # CANVAS ITEM STYLING
    #==========================================================================
    # This function applies our warm color scheme to different types of
    # Pure Data canvas items (objects, connections, UI elements, etc.)
    
    proc color_canvas_item {canv item_type tags} {
        variable color_bg
        variable color_fg
        variable color_inlet
        variable color_outlet
        variable color_connection
        
        # Get the primary tag for this item
        set tag [lindex $tags 0]
        
        # Set default outline color (most items get foreground color outline)
        catch {
            $canv itemconfigure $tag -outline $color_fg
        }
        
        # Apply colors based on item type and tags
        if {[regexp {X[12]$} $tag]} {
            # X1/X2 items (usually object borders) - use background color
            $canv itemconfigure $tag -fill $color_bg
            
        } elseif {[lsearch {line text} $item_type] >= 0} {
            # Lines and text elements - use foreground color
            $canv itemconfigure $tag -fill $color_fg
            
        } elseif {[lsearch $tags "x"] >= 0} {
            # Items tagged with "x" - leave unchanged (special cases)
            
        } elseif {[lsearch $tags "inlet"] >= 0} {
            # Inlet connections - use warm coral color
            $canv itemconfigure $tag -fill $color_inlet -outline $color_inlet
            
        } elseif {[lsearch $tags "outlet"] >= 0} {
            # Outlet connections - use sage green color
            $canv itemconfigure $tag -fill $color_outlet -outline $color_outlet
            
        } elseif {[lsearch $tags "array"] >= 0} {
            # Array elements - use connection color for visibility
            $canv itemconfigure $tag -fill $color_connection
            
        } elseif {[regexp {BASE\d*$} $tag]} {
            # Base elements (object backgrounds) - use background color
            $canv itemconfigure $tag -fill $color_bg
            
        } elseif {[regexp {BUT$} $tag] && $item_type eq "oval"} {
            # Oval buttons - hollow with background fill
            $canv itemconfigure $tag -fill $color_bg
            
        } elseif {[regexp {BUT0$} $tag] && $item_type eq "rectangle"} {
            # Active rectangular buttons - filled with foreground color
            $canv itemconfigure $tag -fill $color_fg -outline $color_fg
            
        } elseif {[regexp {BUT\d+$} $tag] && $item_type eq "rectangle"} {
            # Inactive rectangular buttons - background color
            $canv itemconfigure $tag -fill $color_bg -outline $color_bg
        }
    }
    
    #==========================================================================
    # CANVAS COMMAND INTERCEPTOR
    #==========================================================================
    # This function intercepts canvas drawing commands and applies our color
    # scheme to items as they are created or modified
    
    proc canvas_trace {cmd code result op} {
        variable color_bg
        variable color_fg
        variable color_sel
        
        # Only process successful commands
        if {$code != 0} {
            return
        }
        
        set canv [lindex $cmd 0]
        set canv_cmd [lindex $cmd 1]
        
        if {$canv_cmd eq "create"} {
            # Handle item creation - apply colors to new items
            set tags_idx [lsearch $cmd -tags]
            
            if {$tags_idx >= 0} {
                incr tags_idx
                set tags [lindex $cmd $tags_idx]
                set tag [lindex $tags 0]
                set item_type [lindex $cmd 2]
                
                # Apply our color scheme to the new item
                color_canvas_item $canv $item_type $tags
            }
            
        } elseif {$canv_cmd eq "itemconfigure"} {
            # Handle item reconfiguration - replace default colors
            set tag [lindex $cmd 2]
            set fill_clr [$canv itemcget $tag -fill]
            set outline_clr ""
            
            # Safely get outline color (not all items have outlines)
            catch {
                set outline_clr [$canv itemcget $tag -outline]
            }
            
            # Replace fill colors
            if {[is_black $fill_clr]} {
                $canv itemconfigure $tag -fill $color_fg
            } elseif {[is_blue $fill_clr]} {
                $canv itemconfigure $tag -fill $color_sel
            } elseif {[is_offwhite $fill_clr]} {
                $canv itemconfigure $tag -fill $color_bg
            } elseif {[is_white $fill_clr]} {
                $canv itemconfigure $tag -fill $color_fg
            }
            
            # Replace outline colors
            if {[is_black $outline_clr]} {
                $canv itemconfigure $tag -outline $color_fg
            } elseif {[is_blue $outline_clr]} {
                $canv itemconfigure $tag -outline $color_sel
            } elseif {[is_offwhite $outline_clr]} {
                $canv itemconfigure $tag -outline $color_bg
            } elseif {[is_white $outline_clr]} {
                $canv itemconfigure $tag -outline $color_fg
            }
        }
    }
    
    #==========================================================================
    # CANVAS INITIALIZATION
    #==========================================================================
    # This function is called when a new Pure Data canvas is created
    # It sets up the basic canvas colors and installs our color interceptor
    
    proc canvas_created {cmd code result op} {
        variable color_bg
        variable color_hl_fg
        variable color_hl_bg
        variable color_insert
        
        # Only process successful canvas creation
        if {$code != 0} {
            return
        }
        
        # Get the canvas widget reference
        set container [lindex $cmd 1]
        set canv [tkcanvas_name $container]
        
        # Apply our warm color scheme to the canvas
        $canv configure -background $color_bg           ; # Warm dark background
        $canv configure -selectforeground $color_hl_fg  ; # Light cream selection text
        $canv configure -selectbackground $color_hl_bg  ; # Warm brown selection background
        $canv configure -insertbackground $color_insert ; # Bright orange cursor
        
        # Install our color interceptor for this canvas
        trace add execution $canv leave [namespace code canvas_trace]
    }
    
    #==========================================================================
    # THEME ACTIVATION
    #==========================================================================
    # Set up the theme by intercepting canvas creation and configuring
    # the console window
    
    # Install canvas creation interceptor
    trace add execution ::pdtk_canvas_new leave [namespace code canvas_created]
    
    # Configure the Pure Data console window with warm colors
    if {[winfo exists .pdwindow.text]} {
        .pdwindow.text configure -background $color_bg
        .pdwindow.text configure -selectbackground $color_log_sel_bg
        .pdwindow.text configure -foreground $color_fg
    }
    
    # Configure console log message colors
    if {[winfo exists .pdwindow.text.internal]} {
        # Fatal errors - bright red with dark red background
        .pdwindow.text.internal tag configure log0 \
            -foreground $color_log_fatal_fg \
            -background $color_log_fatal_bg
        
        # Regular errors - lighter red
        .pdwindow.text.internal tag configure log1 \
            -foreground $color_log_err
        
        # Normal messages - warm amber
        .pdwindow.text.internal tag configure log2 \
            -foreground $color_log_normal \
            -selectforeground $color_log_normal_sel_fg
        
        # Debug messages - muted yellow
        .pdwindow.text.internal tag configure log3 \
            -foreground $color_log_debug
        
        # Verbose messages (levels 4-24) - dim brown
        for {set i 4} {$i <= 24} {incr i} {
            .pdwindow.text.internal tag configure log$i \
                -foreground $color_log_verbose
        }
    }
    
    #==========================================================================
    # UTILITY FUNCTIONS (for future enhancements)
    #==========================================================================
    
    # Function to reload the theme (useful for development)
    proc reload_theme {} {
        # This could be expanded to reapply colors to existing canvases
        puts "Theme reloaded - restart Pure Data to see full effect"
    }
    
    # Function to adjust brightness (for user customization)
    proc adjust_brightness {factor} {
        # This could be used to make the theme lighter or darker
        # Implementation would modify the color variables
        puts "Brightness adjustment not yet implemented"
    }
}

# Optional: Print a message when the theme loads
puts "🔥 Warm & Cozy Dark Theme for Pure Data loaded successfully!"
puts "   Background: Rich dark brown with warm amber text"
puts "   Accents: Burnt orange selections, coral inlets, sage outlets"