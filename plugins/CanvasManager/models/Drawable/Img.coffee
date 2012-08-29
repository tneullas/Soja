#
class Img extends Drawable
    constructor: ( src = "", app = undefined, path = undefined, need_fit = true ) ->
        super()
        
        @add_attr
            src   : src
            _histo: new Vec
            
        if path?
            @add_attr
                _path: path
        
        @data = 
            zmin: 0
            zmax: 0
            buff: undefined # buffer image, to manage onload asynchronous stuff
            rgba: undefined # image that will be actually drawed
            begl: true

        onload = =>
            @_signal_change()
            @loaded = true
            @data.rgba = @data.buff
            @data.buff = new Image
            @data.buff.onload = onload
            
            if @_histo.length == 0
               @fill_histogram()
            
            if need_fit and app?
                need_fit = false
                app.fit 0
        @loaded = false
        @data.buff = new Image
        @data.buff.onload = onload
        if @src.get().length
            @data.buff.src = @src.get()
        
    z_index: ->
        return 1
        
    draw: ( info ) ->
        if @src.has_been_modified() or @data.begl
            @data.begl = false
            @data.buff.src = @src.get()
        
        if not @data.rgba?
            return false
        
        # preparation
        @X = [ 1, 0,  0 ]
        @Y = [ 0, 1,  0 ]
        @Z = [ 0, 0, -1 ]
        @O = [ 0, 0,  0 ]
        if info.shoot_cam?
            # base
            w = @data.rgba.width
            h = @data.rgba.height
            sc_2_rw = info.shoot_cam.sc_2_rw w, h
            Z = sc_2_rw.dir 0.5 * w, 0.5 * h
            x_min = info.get_x_min()
            x_max = info.get_x_max()
            
            # offset
            Xc = [
                0.5 * ( x_min[ 0 ] + x_max[ 0 ] ),
                0.5 * ( x_min[ 1 ] + x_max[ 1 ] ),
                0.5 * ( x_min[ 2 ] + x_max[ 2 ] ),
            ]
            dc = Math.max(
                ( x_max[ 0 ] - x_min[ 0 ] ),
                ( x_max[ 1 ] - x_min[ 1 ] ),
                ( x_max[ 2 ] - x_min[ 2 ] )
            )
            P = [
                Xc[ 0 ] + dc * Z[ 0 ],
                Xc[ 1 ] + dc * Z[ 1 ],
                Xc[ 2 ] + dc * Z[ 2 ],
            ]
            
            #
            ajusted = ( pos, dir, Z, P ) ->
                pp = Vec_3.dot Vec_3.sub( P, pos ), Z
                pq = pp / Vec_3.dot( Z, dir )
                [
                    pos[ 0 ] + dir[ 0 ] * pq,
                    pos[ 1 ] + dir[ 1 ] * pq,
                    pos[ 2 ] + dir[ 2 ] * pq,
                ]
            
            @O = ajusted sc_2_rw.pos( 0, h ), sc_2_rw.dir( 0, h ), Z, P
            dX = ajusted sc_2_rw.pos( w, h ), sc_2_rw.dir( w, h ), Z, P
            dY = ajusted sc_2_rw.pos( 0, 0 ), sc_2_rw.dir( 0, 0 ), Z, P
            
            
            #
            @X = Vec_3.mus 1 / w, Vec_3.sub dX, @O
            @Y = Vec_3.mus 1 / h, Vec_3.sub dY, @O
            @Z = Vec_3.nor Vec_3.cro @X, @Y
            
        # flat image
        if @data.zmin == @data.zmax
            # same z, aligned img
            #             if false and info.cam.X.equals( @X ) and info.cam.Y.equals( @Y )
            #                 w = @data.rgba.width
            #                 h = @data.rgba.height
            #                 a = info.re_2_sc.proj [ 0, 0, @data.zmin ]
            #                 b = info.re_2_sc.proj [ w, h, @data.zmin ]
            #                 info.ctx.drawImage @data.rgba, a[ 0 ], a[ 1 ], b[ 0 ] - a[ 0 ], b[ 1 ] - a[ 1 ]
            #             else
            if not @loaded? or @loaded != true
                console.log Img, this.src.get()
                console.log @loaded
            Img._draw_persp_rec info, @data.rgba, @data.zmin, @data.zmax, @O, @X, @Y, @Z

        
    update_min_max: ( x_min, x_max ) ->
        if @data.rgba?
            for d in [ 0 ... 3 ]
                x_min[ d ] = Math.min x_min[ d ], 0
            x_max[ 0 ] = Math.max x_max[ 0 ], @data.rgba.width
            x_max[ 1 ] = Math.max x_max[ 1 ], @data.rgba.height
            x_max[ 2 ] = Math.max x_max[ 2 ], 0
            
    fill_histogram: () ->
        canvas = document.createElement 'canvas'
        canvas.width = @data.rgba.width
        canvas.height = @data.rgba.height
        ctx = canvas.getContext '2d'
        ctx.drawImage @data.rgba, 0, 0, @data.rgba.width, @data.rgba.height
        canvasData = ctx.getImageData 0, 0, @data.rgba.width, @data.rgba.height
        data = canvasData.data
        
        for i in [ 0 .. 255 ]
            @_histo.push 0
            
        for el, i in data by 4
            if data[ i + 3 ] != 0
                index = Math.round( ( data[ i ] + data[ i + 1 ] + data[ i + 2 ] ) / 3 )
                @_histo[ index ].set @_histo[ index ].get() + 1
                

    information: ( div ) ->
        if @data.rgba?.height?
            if not @cm?
                @txt = new_dom_element
                    parentNode: div
                    
                d = new_dom_element
                    parentNode: div
                    # style     : { position: "absolute", top: 0, left: 0, width: "70%", bottom: 0 }

                #             bg = new Background
                # #             bg.gradient.remove_color 1
                #             bg.gradient.remove_color 0

                m = new Graph marker: 'bar', show_line: false, shadow: false, marker_size: 2, font_size: 10
                for p, i in @_histo
                    m.points.push [ i , p, 0 ]
                m.build_w2b_legend()
                
                @cm = new CanvasManager el: d, want_aspect_ratio: true, padding_ratio: 1.4, constrain_zoom: 'x', width: '', class_name: 'histogramm'
                @cm.cam.threeD.set false
                
                # @cm.items.push bg
                @cm.items.push m
                @cm.fit()

            @txt.innerHTML = "
                #{@src} <br>
                Height : #{@data.rgba.height}px <br>
                Width  : #{@data.rgba.width}px <br>
            "

            @cm.draw()

    @_draw_persp_rec: ( info, rgba, zmin, zmax, O, X, Y, Z, xmin = 0, ymin = 0, xmax = 1, ymax = 1, rec = 0 ) ->
        w = rgba.width
        h = rgba.height
        
        a = info.re_2_sc.proj Vec_3.add( O, Vec_3.add( Vec_3.add( Vec_3.mus( w * xmin, X ), Vec_3.mus( h * ymin, Y ) ), Vec_3.mus( zmin, Z ) ) )
        b = info.re_2_sc.proj Vec_3.add( O, Vec_3.add( Vec_3.add( Vec_3.mus( w * xmax, X ), Vec_3.mus( h * ymax, Y ) ), Vec_3.mus( zmin, Z ) ) )
        c = info.re_2_sc.proj Vec_3.add( O, Vec_3.add( Vec_3.add( Vec_3.mus( w * xmax, X ), Vec_3.mus( h * ymin, Y ) ), Vec_3.mus( zmin, Z ) ) )
        d = info.re_2_sc.proj Vec_3.add( O, Vec_3.add( Vec_3.add( Vec_3.mus( w * xmin, X ), Vec_3.mus( h * ymax, Y ) ), Vec_3.mus( zmin, Z ) ) )
        
        if a[ 0 ] >= info.w and b[ 0 ] >= info.w and c[ 0 ] >= info.w and d[ 0 ] >= info.w
            return true
        if a[ 0 ] < 0 and b[ 0 ] < 0 and c[ 0 ] < 0 and d[ 0 ] < 0
            return true
        if a[ 1 ] >= info.h and b[ 1 ] >= info.h and c[ 1 ] >= info.h and d[ 1 ] >= info.h
            return true
        if a[ 1 ] < 0 and b[ 1 ] < 0 and c[ 1 ] < 0 and d[ 1 ] < 0
            return true
        
        r = [ c[ 0 ] + d[ 0 ] - a[ 0 ], c[ 1 ] + d[ 1 ] - a[ 1 ] ] # approximation in screen
        if rec < 6 and Math.pow( r[ 0 ] - b[ 0 ], 2 ) + Math.pow( r[ 1 ] - b[ 1 ], 2 ) > 1
            ca = 0.5 + 1e-2
            cb = 1 - ca
            xm_0 = cb * xmin + ca * xmax
            ym_0 = cb * ymin + ca * ymax
            xm_1 = ca * xmin + cb * xmax
            ym_1 = ca * ymin + cb * ymax
            Img._draw_persp_rec info, rgba, zmin, zmax, O, X, Y, Z, xmin, ymin, xm_0, ym_0, rec + 1
            Img._draw_persp_rec info, rgba, zmin, zmax, O, X, Y, Z, xm_1, ymin, xmax, ym_0, rec + 1
            Img._draw_persp_rec info, rgba, zmin, zmax, O, X, Y, Z, xmin, ym_1, xm_0, ymax, rec + 1
            Img._draw_persp_rec info, rgba, zmin, zmax, O, X, Y, Z, xm_1, ym_1, xmax, ymax, rec + 1
            return true
            
        # if xmin == 0 and ymin == 0
        # console.log rec, Math.sqrt( Math.pow( r[ 0 ] - b[ 0 ], 2 ) + Math.pow( r[ 1 ] - b[ 1 ], 2 ) )
        sx = Math.ceil w * xmin
        sy = Math.ceil h * (    1 - ymax )
        dx = Math.ceil w * ( xmax - xmin )
        dy = Math.ceil h * ( ymax - ymin )
        dx = Math.min dx, w - sx
        dy = Math.min dy, h - sy

        x = [ ( c[ 0 ] - a[ 0 ] ) / dx, ( c[ 1 ] - a[ 1 ] ) / dx ]
        y = [ ( d[ 0 ] - a[ 0 ] ) / dy, ( d[ 1 ] - a[ 1 ] ) / dy ]

        info.ctx.save()
        info.ctx.setTransform x[ 0 ], x[ 1 ], y[ 0 ], y[ 1 ], d[ 0 ], d[ 1 ]
        info.ctx.transform 1, 0, 0, -1, 0, 0

#         try
        info.ctx.drawImage rgba, sx, sy, dx, dy, 0, 0, dx, dy
#         catch err
#             console.log err
        info.ctx.restore()
        