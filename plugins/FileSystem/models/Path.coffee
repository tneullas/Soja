# contains (privately on the server) a path to data on the server
class Path extends Model
    # @file is optionnal. Must be a javascript File object
    constructor: ( @file ) ->
        super()

        size = if @file.fileSize? then @file.fileSize else @file.size
        
        @add_attr
            remaining: size
            to_upload: size

    get_file_info: ( info ) ->
        info.remaining = @remaining
        info.to_upload = @to_upload
        
    _get_fs_data: ( out ) ->
        super out
        # permit to send the data after the server's answaer
        if @file? and @_server_id & 3
            FileSystem._files_to_upload[ @_server_id ] = this
