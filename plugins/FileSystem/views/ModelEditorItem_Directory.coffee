# Browsing and dnd
class ModelEditorItem_Directory extends ModelEditorItem
    constructor: ( params ) ->
        super params
        
        @breadcrumb = new Lst
        @breadcrumb.push @model
        
       
        @selected_file = []
        @clipboard     = [] # contain last 'copy' or 'cut' file
        
        @allow_shortkey = true # allow the use of shortkey like Ctrl+C / Delete. Set to false when renaming
        
        @line_height = 30 # enough to contain the text
        
        
        @container = new_dom_element
                parentNode: @ed                
                nodeName  : "div"
                        
        @icon_scene = new_dom_element
                parentNode: @container
                nodeName  : "div"
                className : "icon_scene"
                
        @icon_up = new_dom_element
                parentNode: @icon_scene
                nodeName  : "img"
                src       : "img/parent.png"
                alt       : "Parent"
                title     : "Parent"
                onclick: ( evt ) =>
                    # watching parent
                    @load_model_from_breadcrumb @breadcrumb.length - 2
                    
        @icon_new_folder = new_dom_element
                parentNode: @icon_scene
                nodeName  : "img"
                src       : "img/add_folder.png"
                alt       : "New folder"
                title     : "New folder"
                onclick: ( evt ) =>
                    n = new File "New folder", 0
                    n._info.add_attr
                        icon: "directory"
                        model_type: "Directory"
                        
                    @model.push n
                    @refresh()
                    
        @icon_cut = new_dom_element
                parentNode: @icon_scene
                nodeName  : "img"
                src       : "img/cut.png"
                alt       : "cut"
                title     : "Cut"
                onclick: ( evt ) =>
                    @cut()
                    
        @icon_copy = new_dom_element
                parentNode: @icon_scene
                nodeName  : "img"
                src       : "img/copy.png"
                alt       : "copy"
                title     : "Copy"
                onclick: ( evt ) =>
                    @copy()
                    
        @icon_paste = new_dom_element
                parentNode: @icon_scene
                nodeName  : "img"
                src       : "img/paste.png"
                alt       : "paste"
                title     : "Paste"
                onclick: ( evt ) =>
                    @paste()

        @icon_del_folder = new_dom_element
                parentNode: @icon_scene
                nodeName  : "img"
                src       : "img/trash.png"
                alt       : "Delete"
                title     : "Delete"
                onclick: ( evt ) =>
                    @delete_file()
                ondragover: ( evt ) =>
                    return false
                ondrop: ( evt ) =>
                    @delete_file()
                    evt.stopPropagation()
                    return false
        
        @upload_form = new_dom_element
                parentNode: @icon_scene
                nodeName  : "form"
                
        @txt_upload = new_dom_element
                parentNode: @icon_scene
                nodeName  : "span"
                txt       : "Add new file(s) "
                
        @upload = new_dom_element
                parentNode: @icon_scene
                nodeName  : "input"
                type      : "file"
                accept    : "image/*"
                multiple  : "true"
                onchange: ( evt ) ->
                    if this.files.length > 0
                        for file in this.files
                            console.log file
    #                     @handleFiles '', this.files
                
        @breadcrumb_dom = new_dom_element
                parentNode: @container                
                nodeName  : "div"
                    
        @all_file_container = new_dom_element
                parentNode: @container
                nodeName  : "div"
#                 ondragover: ( evt ) =>
#                     @all_file_container.id = "drop_zone"
#                     return false
#                 ondragleave: ( evt ) =>
#                     @all_file_container.id = ""
#                     return false
#                 ondrop: ( evt ) =>
#                     @all_file_container.id = ""
#                     evt.stopPropagation()
#                     return false

        @refresh()
        
        key_map = {
            8 : ( evt ) => # backspace
                @load_model_from_breadcrumb @breadcrumb.length - 2
                        
#             13 : ( evt ) => # enter
                
            37 : ( evt ) => # left
                if @selected_file.length > 0
                    if evt.shiftKey
                        # TODO shift selected need to use a reference file and not push the next or previous file ( this is to prevent multiple occurence of file when shift leftand then shift+right etc)
                        index_last_file_selected = @selected_file[ @selected_file.length - 1 ]
                        if index_last_file_selected > 0
                            @selected_file.push index_last_file_selected - 1
                            
                    else
                        ind = @selected_file[ @selected_file.length - 1 ]
                        if ind != 0
                            @selected_file = []
                            @selected_file.push ind - 1
                        else
                            @selected_file = []
                            @selected_file.push 0
                
                # case no file is selected
                else
                    @selected_file.push 0 
                @draw_selected_file()
                
#             38 : ( evt ) => # up
                
            39 : ( evt ) => # right
                if @selected_file.length > 0
                    if evt.shiftKey
                        index_last_file_selected = @selected_file[ @selected_file.length - 1 ]
                        if index_last_file_selected < @model.length - 1
                            @selected_file.push index_last_file_selected + 1
                            
                    else
                        ind = @selected_file[ @selected_file.length - 1 ]
                        if ind < @model.length - 1
                            @selected_file = []
                            @selected_file.push ind + 1
                        else
                            @selected_file = []
                            @selected_file.push @model.length - 1
                
                # case no file is selected
                else
                    @selected_file.push 0 
                    
                @draw_selected_file()
                
#             40 : ( evt ) => # down
                
            65 : ( evt ) => # A
                if evt.ctrlKey # select all
                    @selected_file = []
                    for child, i in @model
                        @selected_file.push i
                    @draw_selected_file()
                    
            88 : ( evt ) => # X
                if evt.ctrlKey # cut
                    @cut()
                
            67 : ( evt ) => # C
                if evt.ctrlKey # copy
                    @copy()
                
            86 : ( evt ) => # V
                if evt.ctrlKey # paste
                    @paste()
                
            46 : ( evt ) => # suppr
                @delete_file()
                
            113 : ( evt ) => # F2
                file_contain = document.getElementsByClassName('selected_file')[ 0 ]?.getElementsByClassName('linkDirectory')
                if file_contain?
                    @rename_file file_contain[ 0 ], @model[ @search_ord_index_from_id @selected_file[ 0 ] ]
                
#             116 : ( evt ) => # F5
#                 @refresh()
        }

        document.onkeydown = ( evt ) =>
            if @allow_shortkey == true
                if key_map[ evt.keyCode ]?
                    evt.stopPropagation()
                    evt.preventDefault()
                    key_map[ evt.keyCode ]( evt )
                    return true

    refresh: ->
        @empty_window()
        @init()

    cut: ->
        if @selected_file.length > 0
            @clipboard = []
            for ind_children in @selected_file
                real_ind = @search_ord_index_from_id ind_children
                @clipboard.push @model[ real_ind ]
            @cutroot = @model
            
    copy: ->
        if @selected_file.length > 0
            @clipboard = []
            for ind_children in @selected_file
                real_ind = @search_ord_index_from_id ind_children
                @clipboard.push @model[ real_ind ]
            @cutroot = undefined
            
    paste: ->
        if @cutroot?
            for mod in @clipboard
                pos = @cutroot.indexOf mod
                if pos != -1
                    @cutroot.splice pos, 1
        for file in @clipboard
#             new_file = file
            new_file = file.deep_copy()
            console.log new_file, file
            @model.push new_file
        @refresh()
        
        
    rename_file: ( file, child_index ) ->
        # start rename file
        @allow_shortkey = false
        file.contentEditable = "true"
        file.focus()
        # stop rename file
        file.onblur = ( evt ) =>
            @allow_shortkey = true
            title = file.innerHTML
            child_index.name.set title
            file.contentEditable = "false"
    
    empty_window: ->
        @all_file_container.innerHTML = ""
        @selected_file = []
    
    load_folder: ( children ) ->
        # watching children
        console.log "loading : ", children
        fs = new FileSystem
        
        #TODO, use path
        fs.load "/test_browser" + "/" + children.name.get() , ( m, err ) =>
            console.log "fs load : ", m, err
            @model = m
            @breadcrumb.push m
            
            @refresh()

        
    draw_breadcrumb: ->
        @breadcrumb_dom.innerHTML = ""
        for folder, i in @breadcrumb
            do ( i ) =>
                if i == 0
                    f = new_dom_element
                        parentNode: @breadcrumb_dom
                        nodeName  : "span"
                        className : "breadcrumb"
                        txt       : "Root"
                        onclick   : ( evt ) =>
                            @load_model_from_breadcrumb 0
                        
                else
                    l = new_dom_element
                        parentNode: @breadcrumb_dom
                        nodeName  : "span"
                        txt       : " > "
                        
                    f = new_dom_element
                        parentNode: @breadcrumb_dom
                        nodeName  : "span"
                        className : "breadcrumb"
                        txt       : folder.name.get()
                        onclick   : ( evt ) =>
                            @load_model_from_breadcrumb i

            
    load_model_from_breadcrumb: ( ind ) ->
        if ind != -1
            @delete_breadcrumb_from_index ind
            @model = @breadcrumb[ ind ]
            @refresh()
        
    delete_breadcrumb_from_index: ( index ) ->
        for i in [ @breadcrumb.length-1 ... index ]
            @breadcrumb.pop()
    
    search_ord_index_from_id: ( id ) ->
        sorted = @model.sorted sort_dir
        for i in @model
            pos = @model.indexOf sorted[ id ]
            if pos != -1
                return pos
        
    
    delete_file: ->
        if @selected_file.length
            index_array = []
            for i in @selected_file
                index = @search_ord_index_from_id i
                index_array.push index
                
            for i in [ index_array.length - 1 .. 0 ]
                @model.splice( index_array[ i ] , 1)
                
            @selected_file = []
            @refresh()
            
    draw_selected_file: ->
        file_contain = document.getElementsByClassName 'file_container'
        for file, j in file_contain
            if parseInt(@selected_file.indexOf j) != -1
                add_class file, 'selected_file'
            else
                rem_class file, 'selected_file'

    sort_dir = ( a, b ) -> 
    # following is commented because it doesn't sort item that are pasted
#         c = 0
#         d = 0
#         if b.data instanceof Directory
#             c = 1
#         if a.data instanceof Directory
#             d = 1
#         if d - c != 0
#             return 1
        if a.name.get().toLowerCase() > b.name.get().toLowerCase() then 1 else -1
    
    init: ->
        console.log "init ",@model
        sorted = @model.sorted sort_dir
#         if @breadcrumb.length > 1
#             parent = new File Directory, ".."
#             sorted.unshift parent
            
        for elem, i in sorted
            do ( elem, i ) =>
            
                file_container = new_dom_element
                    parentNode: @all_file_container
                    nodeName  : "div"
                    className : "file_container"
                    
                    ondragstart: ( evt ) =>
                        @popup_closer_zindex = document.getElementById('popup_closer').style.zIndex
                        document.getElementById('popup_closer').style.zIndex = -1
                        
                        @drag_source = []
                        @drag_source = @selected_file.slice 0
                        if parseInt(@selected_file.indexOf i) == -1
                            @drag_source.push i
                        
                        evt.dataTransfer.effectAllowed = if evt.ctrlKey then "copy" else "move"
                        
                    ondragover: ( evt ) =>
                        return false
                        
                    ondragend: ( evt ) =>
                        document.getElementById('popup_closer').style.zIndex = @popup_closer_zindex
                    
                    ondrop: ( evt ) =>
                        # drop file got index = i
                        if sorted[ i ]._info.model_type.get() == "Directory"
#                             console.log @drag_source
#                             console.log @breadcrumb[ @breadcrumb.length - 2 ]
                            if sorted[ i ].name == ".."
#                                 @breadcrumb[ @breadcrumb.length - 2 ].data.children.push sorted[ ind ]
                            else
                                # add selected children to target directory
                                index = @search_ord_index_from_id i
                                for ind in @drag_source
                                    @model[ index ].data.children.push sorted[ ind ]
                                
                            # remove selected children from current directory
                            for sorted_ind in @drag_source
                                index = @search_ord_index_from_id sorted_ind
                                @model.splice index, 1
    
                            @selected_file = []
                            @refresh()
                        
                        evt.stopPropagation()
                        return false
                        
                    onmousedown : ( evt ) =>
                        if evt.ctrlKey
                            ind = parseInt(@selected_file.indexOf i)
                            if ind != -1
                                @selected_file.splice ind, 1
                            else
                                @selected_file.push i
                                
                        else if evt.shiftKey
                            if @selected_file.length == 0
                                @selected_file.push i
                            else
                                index_last_file_selected = @selected_file[ @selected_file.length - 1 ]
                                @selected_file = []
                                for j in [ index_last_file_selected .. i ]
                                    @selected_file.push j
                                
                        else
                            @selected_file = []
                            @selected_file.push i
                        
                        @draw_selected_file()
                
                if elem._info.model_type.get() == "ImgItem"
                    @picture = new_dom_element
                        parentNode: file_container
                        className : "picture"
                        nodeName  : "img"
                        src       : elem.data._name
                        alt       : ""
                        title     : elem.data._name
                        ondblclick: ( evt ) =>
                            @fundblclick evt, sorted[ i ]
                            
                    text = new_dom_element
                        parentNode: file_container
                        className : "linkDirectory"
                        nodeName  : "div"
                        txt       : elem.name
                        onclick: ( evt ) =>
                            @rename_file text, sorted[ i ]
                
                else if elem._info.model_type.get() == "Mesh"
                    @picture = new_dom_element
                        parentNode: file_container
                        nodeName  : "img"
                        src       : "img/unknown.png"
                        alt       : ""
                        title     : ""
                        ondblclick: ( evt ) =>
                            @fundblclick evt, sorted[ i ]
                            
                    text = new_dom_element
                        parentNode: file_container
                        className : "linkDirectory"
                        nodeName  : "div"
                        txt       : elem.name
                        onclick: ( evt ) =>
                            @rename_file text, sorted[ i ]
                            
                else if elem._info.model_type.get() == "Directory"
                    @picture = new_dom_element
                        parentNode: file_container
                        nodeName  : "img"
                        src       : "img/orange_folder.png"
                        alt       : elem.name
                        title     : elem.name
                        ondblclick: ( evt ) =>
                            if sorted[ i ].name.get() == ".."
                                @load_model_from_breadcrumb @breadcrumb.length - 2
                            else
                                @load_folder sorted[ i ]
                        
                    text = new_dom_element
                        parentNode: file_container
                        className : "linkDirectory"
                        nodeName  : "div"
                        txt       : elem.name
                        onclick: ( evt ) =>
                            @rename_file text, sorted[ i ]
                            
                else
                    @picture = new_dom_element
                        parentNode: file_container
                        nodeName  : "img"
                        src       : "img/unknown.png"
                        alt       : ""
                        title     : "" 
                        
                    text = new_dom_element
                        parentNode: file_container
                        className : "text"
                        nodeName  : "div"
                        txt       : elem.name
                        onclick: ( evt ) =>
                            @rename_file text, sorted[ i ]
                
        @draw_breadcrumb()
        
        # use for dropable area
        bottom = new_dom_element
            parentNode: @all_file_container
            nodeName  : "div"
            style:
                clear: "both"

# registering
ModelEditor.default_types.unshift ( model ) -> ModelEditorItem_Directory if model instanceof Directory