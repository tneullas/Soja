# List of files
class Directory extends Lst
    constructor: () ->
        super()

    base_type: ->
        File
    
    find: ( name ) ->
        for f in this
            if f.name.equals name
                return f
        return undefined
        
    add_file: ( name, obj, params = {} ) ->
        o = @find name
        if not o?
            @push new File name, obj, params

    get_file_info: ( info ) ->
        info.icon = "directory"
