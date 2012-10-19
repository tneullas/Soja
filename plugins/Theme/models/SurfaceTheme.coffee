# Copyright 2012 Structure Computation  www.structure-computation.com
# Copyright 2012 Hugo Leclerc
#
# This file is part of Soda.
#
# Soda is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Soda is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with Soda. If not, see <http://www.gnu.org/licenses/>.



# 
class SurfaceTheme extends Model
    constructor: ( color = new Color( 200, 200, 200, 255 ) ) ->
        super()
        
        @add_attr
            color: color

    beg_ctx: ( info ) ->
        info.ctx.fillStyle = @color.to_rgba()
        info.ctx.strokeStyle = @color.to_rgba()
        
    end_ctx: ( info ) ->
        
    draw: ( info, func ) ->
        info.ctx.beginPath()
        func info
        info.ctx.fill()
        info.ctx.stroke()
        
    
        
