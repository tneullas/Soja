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
class Background extends Drawable
    constructor: ()->
        super()


        @add_attr
            gradient: new Gradient
            
        @gradient.add_color [  0,  0,    0, 255 ], 0
        @gradient.add_color [ 76, 76,  100, 255 ], 1
        
    z_index: ->
        return 0
    
    draws_a_background: ->
        true
    
    draw: ( info ) ->
        lineargradient = info.ctx.createLinearGradient( 0, 0, 0, info.h )
        for col in @gradient.color_stop
            lineargradient.addColorStop col.position.get(), col.color.to_rgba()
        info.ctx.fillStyle = lineargradient
        info.ctx.fillRect( 0, 0, info.w, info.h )
        