#
class CuttingPlan extends Drawable
    constructor: ( pos = [ 0, 0, 0 ], dir = [ 0, 0, -0.2 ] ) ->
        super()
        
        @add_attr
            pos    : new Point pos
            dir    : new Point dir
            opacity: new ConstrainedVal( 50, { min: 0, max: 100, div: 100 } )
        @b = []
#         @size_marker = 0.1
        
    z_index: ->
        return 1

    
    bounding_box: ->
        if @_bounding_box?
            return @_bounding_box
        get_min_max = ( item, x_min, x_max ) ->
            if item.update_min_max?
                item.update_min_max x_min, x_max
            else if item.sub_canvas_items?
                for sub_item in item.sub_canvas_items()
                    get_min_max sub_item, x_min, x_max
                    
        x_min = [ +1e40, +1e40, +1e40 ]
        x_max = [ -1e40, -1e40, -1e40 ]
        for item in this._parents[ 0 ]._children
            get_min_max item, x_min, x_max
        if x_min[ 0 ] == +1e40
            return [ [ -1, -1, -1 ], [ 1, 1, 1 ] ]
        @_bounding_box = [ x_min, x_max ]
        return @_bounding_box
    
    
    draw: ( info ) ->
        
        proj_pos = info.re_2_sc.proj @pos.pos.get()
        proj_dir = info.re_2_sc.proj @dir.pos.get()
        
        # draw plan
        @b = @bounding_box()
        width = @b[ 1 ][ 0 ] - @b[ 0 ][ 0 ]
        height = @b[ 1 ][ 1 ] - @b[ 0 ][ 1 ]
        half_width = width / 2
        half_height = height / 2
        
        lt = info.re_2_sc.proj [ @pos.pos[ 0 ].get() - half_width, @pos.pos[ 1 ].get() + half_height, @pos.pos[ 2 ].get() ]
        rt = info.re_2_sc.proj [ @pos.pos[ 0 ].get() + half_width, @pos.pos[ 1 ].get() + half_height, @pos.pos[ 2 ].get() ]
        rb = info.re_2_sc.proj [ @pos.pos[ 0 ].get() + half_width, @pos.pos[ 1 ].get() - half_height, @pos.pos[ 2 ].get() ]
        lb = info.re_2_sc.proj [ @pos.pos[ 0 ].get() - half_width, @pos.pos[ 1 ].get() - half_height, @pos.pos[ 2 ].get() ]

        info.ctx.lineWidth = 2
        info.ctx.lineCap = "square"
        info.ctx.beginPath()
        info.ctx.strokeStyle = "rgb( 70, 70, 70)"
        info.ctx.fillStyle = "rgba( 200, 200, 200, 200)"
        info.ctx.moveTo lt[ 0 ], lt[ 1 ]
        info.ctx.lineTo rt[ 0 ], rt[ 1 ]
        info.ctx.lineTo rb[ 0 ], rb[ 1 ]
        info.ctx.lineTo lb[ 0 ], lb[ 1 ]
        info.ctx.lineTo lt[ 0 ], lt[ 1 ]
        
        info.ctx.fill()
        info.ctx.stroke()
        info.ctx.closePath()
        
       
        # draw line indicating direction
        info.ctx.beginPath()
        info.ctx.strokeStyle = "orange"
        info.ctx.moveTo proj_pos[ 0 ], proj_pos[ 1 ]
        info.ctx.lineTo proj_dir[ 0 ], proj_dir[ 1 ]
        info.ctx.fill()
        info.ctx.stroke()
        
        
        # draw points
        info.ctx.lineWidth = 1
        
        #draw pos point
        info.ctx.beginPath()
        if info.pre_sele[ @pos.model_id ]?
            info.ctx.strokeStyle = "yellow"
        else
            info.ctx.strokeStyle = "#333311"
            
        if info.selected[ @pos.model_id ]?
            info.ctx.fillStyle = "red"
        else
            info.ctx.fillStyle = "#333311"
        info.ctx.arc proj_pos[ 0 ], proj_pos[ 1 ], 4, 0, Math.PI * 2, true


#         marker_top = info.re_2_sc.proj [ @pos.pos[ 0 ].get(), @pos.pos[ 1 ].get() + @size_marker, @pos.pos[ 2 ].get() ]
#         marker_bot = info.re_2_sc.proj [ @pos.pos[ 0 ].get(), @pos.pos[ 1 ].get() - @size_marker, @pos.pos[ 2 ].get() ]
#         marker_lef = info.re_2_sc.proj [ @pos.pos[ 0 ].get() - @size_marker, @pos.pos[ 1 ].get(), @pos.pos[ 2 ].get() ]
#         marker_rig = info.re_2_sc.proj [ @pos.pos[ 0 ].get() + @size_marker, @pos.pos[ 1 ].get(), @pos.pos[ 2 ].get() ]
#         marker_fro = info.re_2_sc.proj [ @pos.pos[ 0 ].get(), @pos.pos[ 1 ].get(), @pos.pos[ 2 ].get() - @size_marker ]
#         marker_bac = info.re_2_sc.proj [ @pos.pos[ 0 ].get(), @pos.pos[ 1 ].get(), @pos.pos[ 2 ].get() + @size_marker ]
#         info.ctx.moveTo marker_top[ 0 ], marker_top[ 1 ]
#         info.ctx.lineTo marker_bot[ 0 ], marker_bot[ 1 ]
#         info.ctx.moveTo marker_lef[ 0 ], marker_lef[ 1 ]
#         info.ctx.lineTo marker_rig[ 0 ], marker_rig[ 1 ]
#         info.ctx.moveTo marker_fro[ 0 ], marker_fro[ 1 ]
#         info.ctx.lineTo marker_bac[ 0 ], marker_bac[ 1 ]
        info.ctx.fill()
        info.ctx.stroke()
        info.ctx.closePath()
        
        #draw dir point
        info.ctx.beginPath()
        if info.pre_sele[ @dir.model_id ]?
            info.ctx.strokeStyle = "yellow"
        else
            info.ctx.strokeStyle = "#333311"
            
        if info.selected[ @dir.model_id ]?
            info.ctx.fillStyle = "red"
        else
            info.ctx.fillStyle = "#333311"
        info.ctx.arc proj_dir[ 0 ], proj_dir[ 1 ], 4, 0, Math.PI * 2, true
        
        info.ctx.fill()
        info.ctx.stroke()
        info.ctx.closePath()
        
        

    
    get_movable_entities: ( res, info, pos, phase ) ->
        x = pos[ 0 ]
        y = pos[ 1 ]
        if phase == 0
#             marker_top = info.re_2_sc.proj [ @pos.pos[ 0 ].get(), @pos.pos[ 1 ].get() + @size_marker, @pos.pos[ 2 ].get() ]
#             marker_bot = info.re_2_sc.proj [ @pos.pos[ 0 ].get(), @pos.pos[ 1 ].get() - @size_marker, @pos.pos[ 2 ].get() ]
#             marker_lef = info.re_2_sc.proj [ @pos.pos[ 0 ].get() - @size_marker, @pos.pos[ 1 ].get(), @pos.pos[ 2 ].get() ]
#             marker_rig = info.re_2_sc.proj [ @pos.pos[ 0 ].get() + @size_marker, @pos.pos[ 1 ].get(), @pos.pos[ 2 ].get() ]
#             marker_fro = info.re_2_sc.proj [ @pos.pos[ 0 ].get(), @pos.pos[ 1 ].get(), @pos.pos[ 2 ].get() - @size_marker ]
#             marker_bac = info.re_2_sc.proj [ @pos.pos[ 0 ].get(), @pos.pos[ 1 ].get(), @pos.pos[ 2 ].get() + @size_marker ]            
#             if x > marker_lef[ 0 ] and x < marker_rig[ 0 ] and y > marker_top[ 1 ] and y < marker_bot[ 1 ]
#                 res.push
#                     item: @pos
#                     dist: d
#                     type: "CuttingPlan"

            proj = info.re_2_sc.proj @pos.pos.get()
            dx = x - proj[ 0 ]
            dy = y - proj[ 1 ]
            d = Math.sqrt dx * dx + dy * dy
            if d <= 10
                res.push
                    item: @pos
                    dist: d
                    type: "CuttingPlan"
                    
                    
            proj = info.re_2_sc.proj @dir.pos.get()
            dx = x - proj[ 0 ]
            dy = y - proj[ 1 ]
            d = Math.sqrt dx * dx + dy * dy
            if d <= 10
                res.push
                    item: @dir
                    dist: d
                    type: "CuttingPlan"