(* $Id$ *)

open Misc

type colormap
type visual
type gc
type 'a drawable
type window = [window] drawable
type pixmap = [pixmap] drawable
type bitmap = [bitmap] drawable
type font
type image
type atom = int
type 'a event

exception Error of string
let _ = Callback.register_exception "gdkerror" (Error"")

module Tags = struct
  type event_type =
    [ NOTHING DELETE DESTROY EXPOSE MOTION_NOTIFY BUTTON_PRESS
      TWO_BUTTON_PRESS THREE_BUTTON_PRESS
      BUTTON_RELEASE KEY_PRESS
      KEY_RELEASE ENTER_NOTIFY LEAVE_NOTIFY FOCUS_CHANGE
      CONFIGURE MAP UNMAP PROPERTY_NOTIFY SELECTION_CLEAR
      SELECTION_REQUEST SELECTION_NOTIFY PROXIMITY_IN
      PROXIMITY_OUT DRAG_BEGIN DRAG_REQUEST DROP_ENTER
      DROP_LEAVE DROP_DATA_AVAIL CLIENT_EVENT VISIBILITY_NOTIFY
      NO_EXPOSE OTHER_EVENT ]

  type visibility_state =
    [ UNOBSCURED PARTIAL FULLY_OBSCURED ]

  type input_source =
    [ MOUSE PEN ERASER CURSOR ]

  type notify_type =
    [ ANCESTOR VIRTUAL INFERIOR NONLINEAR NONLINEAR_VIRTUAL UNKNOWN ] 

  type modifier =
    [ SHIFT LOCK CONTROL MOD1 MOD2 MOD3 MOD4 MOD5 BUTTON1
      BUTTON2 BUTTON3 BUTTON4 BUTTON5 ]
end
open Tags

module Color = struct
  type t

  external color_white : colormap -> t = "ml_gdk_color_white"
  external color_black : colormap -> t = "ml_gdk_color_black"
  external color_parse : string -> t = "ml_gdk_color_parse"
  external color_alloc : colormap -> t -> bool = "ml_gdk_color_alloc"
  external color_create : red:int -> green:int -> blue:int -> t
      = "ml_GdkColor"

  external get_system_colormap : unit -> colormap
      = "ml_gdk_colormap_get_system"
  type spec = [Black Name(string) RGB(int * int * int) White]
  let alloc color ?:colormap [< get_system_colormap () >] =
    match color with
      `White -> color_white colormap
    | `Black -> color_black colormap
    | `Name _|`RGB _ as c ->
	let color =
	  match c with `Name s -> color_parse s
	  | `RGB (red,green,blue) -> color_create :red :green :blue
	in
	if not (color_alloc colormap color) then raise (Error"Color.alloc");
	color

  external red : t -> int = "ml_GdkColor_red"
  external blue : t -> int = "ml_GdkColor_green"
  external green : t -> int = "ml_GdkColor_blue"
  external pixel : t -> int = "ml_GdkColor_pixel"
end

module Rectangle = struct
  type t
  external create : x:int -> y:int -> width:int -> height:int -> t
      = "ml_GdkRectangle"
  external x : t -> int = "ml_GdkRectangle_x"
  external y : t -> int = "ml_GdkRectangle_y"
  external width : t -> int = "ml_GdkRectangle_width"
  external height : t -> int = "ml_GdkRectangle_height"
end

module GC = struct
  type gdkFunction = [ COPY INVERT XOR ]
  type gdkFill = [ SOLID TILED STIPPLED OPAQUE_STIPPLED ]
  type gdkSubwindowMode = [ CLIP_BY_CHILDREN INCLUDE_INFERIORS ]
  type gdkLineStyle = [ SOLID ON_OFF_DASH DOUBLE_DASH ]
  type gdkCapStyle = [ NOT_LAST BUTT ROUND PROJECTING ]
  type gdkJoinStyle = [ MITER ROUND BEVEL ]
  external create : window -> gc = "ml_gdk_gc_new"
  external set_foreground : gc -> Color.t -> unit = "ml_gdk_gc_set_foreground"
  external set_background : gc -> Color.t -> unit = "ml_gdk_gc_set_background"
  external set_font : gc -> font -> unit = "ml_gdk_gc_set_font"
  external set_function : gc -> gdkFunction -> unit = "ml_gdk_gc_set_function"
  external set_fill : gc -> gdkFill -> unit = "ml_gdk_gc_set_fill"
  external set_tile : gc -> pixmap -> unit = "ml_gdk_gc_set_tile"
  external set_stipple : gc -> pixmap -> unit = "ml_gdk_gc_set_stipple"
  external set_ts_origin : gc -> x:int -> y:int -> unit
      = "ml_gdk_gc_set_ts_origin"
  external set_clip_origin : gc -> x:int -> y:int -> unit
      = "ml_gdk_gc_set_clip_origin"
  external set_clip_mask : gc -> bitmap -> unit = "ml_gdk_gc_set_clip_mask"
  external set_clip_rectangle : gc -> Rectangle.t -> unit
      = "ml_gdk_gc_set_clip_rectangle"
  external set_subwindow : gc -> gdkSubwindowMode -> unit
      = "ml_gdk_gc_set_subwindow"
  external set_exposures : gc -> bool -> unit = "ml_gdk_gc_set_exposures"
  external set_line_attributes :
      gc -> width:int -> style:gdkLineStyle -> cap:gdkCapStyle ->
      join:gdkJoinStyle -> unit
      = "ml_gdk_gc_set_line_attributes"
  external copy : to:gc -> gc -> unit = "ml_gdk_gc_copy"
end

module Pixmap = struct
  external create : window -> width:int -> height:int -> depth:int -> pixmap
      = "ml_gdk_pixmap_new"
  external create_from_data :
      window -> string -> width:int -> height:int -> depth:int ->
      fg:Color.t -> bg:Color.t -> pixmap
      = "ml_gdk_pixmap_create_from_data_bc" "ml_gk_pixmap_create_from_data"
  external create_from_xpm :
      window -> ?:colormap -> ?transparent:Color.t ->
      file:string -> pixmap * bitmap
      = "ml_gdk_pixmap_colormap_create_from_xpm"
  external create_from_xpm_d :
      window -> ?:colormap -> ?transparent:Color.t ->
      data:string array -> pixmap * bitmap
      = "ml_gdk_pixmap_colormap_create_from_xpm_d"
end

module Bitmap = struct
  external create_from_data :
      window -> string -> width:int -> height:int -> bitmap
      = "ml_gdk_bitmap_create_from_data"
end

module Font = struct
  external load : string -> font = "ml_gdk_font_load"
  external load_fontset : string -> font = "ml_gdk_fontset_load"
  external string_width : font -> string -> int = "ml_gdk_string_width"
  external char_width : font -> char -> int = "ml_gdk_char_width"
  external string_measure : font -> string -> int = "ml_gdk_string_measure"
  external char_measure : font -> char -> int = "ml_gdk_char_measure"
end

module PointArray = struct
  type t = { len: int}
  external create : len:int -> t = "ml_point_array_new"
  external set : t -> pos:int -> x:int -> y:int -> unit = "ml_point_array_set"
  let set arr :pos =
    if pos < 0 || pos >= arr.len then invalid_arg "PointArray.set";
    set arr :pos
end

module Draw = struct
  external point : 'a drawable -> gc -> x:int -> y:int -> unit
      = "ml_gdk_draw_point"
  external line : 'a drawable -> gc -> x:int -> y:int -> x:int -> y:int -> unit
      = "ml_gdk_draw_line_bc" "ml_gdk_draw_line"
  external rectangle :
      'a drawable -> gc ->
      filled:bool -> x:int -> y:int -> width:int -> height:int -> unit
      = "ml_gdk_draw_rectangle_bc" "ml_gdk_draw_rectangle"
  let rectangle w gc ?:filled [< false >] = rectangle w gc :filled
  external arc :
      'a drawable -> gc -> filled:bool -> x:int -> y:int ->
      width:int -> height:int -> start:int -> angle:int -> unit
      = "ml_gdk_draw_arc_bc" "ml_gdk_draw_arc"
  let arc w gc :x :y :width :height ?:filled [< false >] ?:start [< 0.0 >]
      ?:angle [< 360.0 >] =
    arc w gc :x :y :width :height :filled
      start:(truncate(start *. 64.))
      angle:(truncate(angle *. 64.))
  external polygon : 'a drawable -> gc -> filled:bool -> PointArray.t -> unit
      = "ml_gdk_draw_polygon"
  let polygon w gc l ?:filled [< false >] =
    let len = List.length l in
    let arr = PointArray.create :len in
    List.fold_left l acc:0
      fun:(fun (x,y) acc:pos -> PointArray.set arr :pos :x :y; pos+1);
    polygon w gc :filled arr
  external string : 'a drawable -> font: font -> gc -> x: int -> y: int -> 
    string: string -> unit
      = "ml_gdk_draw_string_bc" "ml_gdk_draw_string"	
end

module Event = struct
  external unsafe_copy : pointer -> #event_type event
      = "ml_gdk_event_copy"
  external get_type : 'a event -> 'a = "ml_GdkEventAny_type"
  external get_window : 'a event -> window = "ml_GdkEventAny_window"
  external get_send_event : 'a event -> bool = "ml_GdkEventAny_send_event"

  module Expose = struct
    type t = [ EXPOSE ] event
    let cast (ev : event_type event) : t =
      match get_type ev with `EXPOSE -> Obj.magic ev
      |	_ -> invalid_arg "Gdk.Event.Expose.cast"
    external area : t -> Rectangle.t = "ml_GdkEventExpose_area"
    external count : t -> int = "ml_GdkEventExpose_count"
  end

  module Visibility = struct
    type t = [ VISIBILITY_NOTIFY ] event
    let cast (ev :  event_type event) : t =
      match get_type ev with `VISIBILITY_NOTIFY -> Obj.magic ev
      |	_ -> invalid_arg "Gdk.Event.Visibility.cast"
    external visibility : t -> visibility_state
	= "ml_GdkEventVisibility_state"
  end

  module Motion = struct
    type t = [ MOTION_NOTIFY ] event
    let cast (ev : event_type event) : t =
      match get_type ev with `MOTION_NOTIFY -> Obj.magic ev
      |	_ -> invalid_arg "Gdk.Event.Motion.cast"
    external time : t -> int = "ml_GdkEventMotion_time"
    external x : t -> float = "ml_GdkEventMotion_x"
    external y : t -> float = "ml_GdkEventMotion_y"
    external pressure : t -> float = "ml_GdkEventMotion_pressure"
    external xtilt : t -> float = "ml_GdkEventMotion_xtilt"
    external ytilt : t -> float = "ml_GdkEventMotion_ytilt"
    external state : t -> int = "ml_GdkEventMotion_state"
    external is_hint : t -> bool = "ml_GdkEventMotion_is_hint"
    external source : t -> input_source = "ml_GdkEventMotion_source"
    external deviceid : t -> int = "ml_GdkEventMotion_deviceid"
    external x_root : t -> float = "ml_GdkEventMotion_x_root"
    external y_root : t -> float = "ml_GdkEventMotion_y_root"
  end

  module Button = struct
    type t =
	[ BUTTON_PRESS TWO_BUTTON_PRESS THREE_BUTTON_PRESS BUTTON_RELEASE ]
	  event
    let cast (ev : event_type event) : t =
      match get_type ev with
	`BUTTON_PRESS|`TWO_BUTTON_PRESS|`THREE_BUTTON_PRESS|`BUTTON_RELEASE
	-> Obj.magic ev
      |	_ -> invalid_arg "Gdk.Event.Button.cast"
    external time : t -> int = "ml_GdkEventButton_time"
    external x : t -> float = "ml_GdkEventButton_x"
    external y : t -> float = "ml_GdkEventButton_y"
    external pressure : t -> float = "ml_GdkEventButton_pressure"
    external xtilt : t -> float = "ml_GdkEventButton_xtilt"
    external ytilt : t -> float = "ml_GdkEventButton_ytilt"
    external state : t -> int = "ml_GdkEventButton_state"
    external button : t -> int = "ml_GdkEventButton_button"
    external source : t -> input_source = "ml_GdkEventButton_source"
    external deviceid : t -> int = "ml_GdkEventButton_deviceid"
    external x_root : t -> float = "ml_GdkEventButton_x_root"
    external y_root : t -> float = "ml_GdkEventButton_y_root"
  end

  module Key = struct
    type t = [ KEY_PRESS KEY_RELEASE ] event
    let cast (ev : event_type event) : t =
      match get_type ev with `KEY_PRESS|`KEY_RELEASE -> Obj.magic ev
      |	_ -> invalid_arg "Gdk.Event.Key.cast"
    external time : t -> int = "ml_GdkEventKey_time"
    external state : t -> int = "ml_GdkEventKey_state"
    external keyval : t -> int = "ml_GdkEventKey_keyval"
    external string : t -> string = "ml_GdkEventKey_string"
  end

  module Crossing = struct
    type t = [ ENTER_NOTIFY LEAVE_NOTIFY ] event
    let cast (ev : event_type event) : t =
      match get_type ev with `ENTER_NOTIFY|`LEAVE_NOTIFY -> Obj.magic ev
      |	_ -> invalid_arg "Gdk.Event.Crossing.cast"
    external subwindow : t -> window = "ml_GdkEventCrossing_subwindow"
    external detail : t -> notify_type = "ml_GdkEventCrossing_detail"
  end

  module Focus = struct
    type t = [ FOCUS_CHANGE ] event
    let cast (ev : event_type event) : t =
      match get_type ev with `FOCUS_CHANGE -> Obj.magic ev
      |	_ -> invalid_arg "Gdk.Event.Focus.cast"
    external focus_in : t -> bool = "ml_GdkEventFocus_in"
  end

  module Configure = struct
    type t = [ CONFIGURE ] event
    let cast (ev : event_type event) : t =
      match get_type ev with `CONFIGURE -> Obj.magic ev
      |	_ -> invalid_arg "Gdk.Event.Configure.cast"
    external x : t -> int = "ml_GdkEventConfigure_x"
    external y : t -> int = "ml_GdkEventConfigure_y"
    external width : t -> int = "ml_GdkEventConfigure_width"
    external height : t -> int = "ml_GdkEventConfigure_height"
  end

  module Property = struct
    type t = [ PROPERTY_NOTIFY ] event
    let cast (ev : event_type event) : t =
      match get_type ev with `PROPERTY_NOTIFY -> Obj.magic ev
      |	_ -> invalid_arg "Gdk.Event.Property.cast"
    external atom : t -> atom = "ml_GdkEventProperty_atom"
    external time : t -> int = "ml_GdkEventProperty_time"
    external state : t -> int = "ml_GdkEventProperty_state"
  end

  module Selection = struct
    type t = [ SELECTION_CLEAR SELECTION_REQUEST SELECTION_NOTIFY ] event
    let cast (ev : event_type event) : t =
      match get_type ev with
	`SELECTION_CLEAR|`SELECTION_REQUEST|`SELECTION_NOTIFY -> Obj.magic ev
      |	_ -> invalid_arg "Gdk.Event.Selection.cast"
    external selection : t -> atom = "ml_GdkEventSelection_selection"
    external target : t -> atom = "ml_GdkEventSelection_target"
    external property : t -> atom = "ml_GdkEventSelection_property"
    external requestor : t -> int = "ml_GdkEventSelection_requestor"
    external time : t -> int = "ml_GdkEventSelection_time"
  end

  module Proximity = struct
    type t = [ PROXIMITY_IN PROXIMITY_OUT ] event
    let cast (ev : event_type event) : t =
      match get_type ev with `PROXIMITY_IN|`PROXIMITY_OUT -> Obj.magic ev
      |	_ -> invalid_arg "Gdk.Event.Proximity.cast"
    external time : t -> int = "ml_GdkEventProximity_time"
    external source : t -> input_source = "ml_GdkEventProximity_source"
    external deviceid : t -> int = "ml_GdkEventProximity_deviceid"
  end
end