# dep Char.coffee
# dep Ptr.coffee

class Str extends Model
    @attr =
        data: Ptr Char
        size: 0
        
    Model.__conv_list.push ( val ) ->
        if typeof val == "string" then Str

    Str::__defineGetter__ "length", ->
        @size.val
        
    get: -> 
        res = ""
        obj = @data.obj
        if obj?
            view = new Int32Array obj.__orig.__data, obj.__offset / 8, @length
            for i in view
                res += String.fromCharCode i
        res
        
    charCodeAt: ( n ) ->
        obj = @data.obj
        view = new Int32Array obj.__orig.__data, obj.__offset / 8, @length
        view[ n ]
        
    __set: ( val ) ->
        out = @__ch_str val
        
        # TODO memory (or use Vec)
        res = mmew Char, val.length
        @size.__set val.length
        @data.__set res.ptr
        
        view = new Int32Array res.__data, res.__offset / 8, val.length
        for i in [ 0 ... val.length ]
            view[ i ] = val.charCodeAt( i )
        
        out
        
    __ch_str: ( val ) ->
        if @size.val != val.length
            true
        else
            for i in [ 0 ... val.length ]
                if val.charCodeAt( i ) != @data.at( i )
                    return true
            false
    
    # true if ModelEditorInput works for this
    Str::__defineGetter__ "__input_edition", ->
        true
        
        
