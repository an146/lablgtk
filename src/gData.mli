(* $Id$ *)

open Gtk

class data_signals :
  'a[> data] obj -> ?after:bool ->
  object
    inherit GObj.gtkobj_signals
    val obj : 'a obj
    method disconnect : callback:(unit -> unit) -> GtkSignal.id
  end

class adjustment_signals :
  'a[> adjustment data] obj -> ?after:bool ->
  object
    inherit data_signals
    val obj : 'a obj
    method changed : callback:(unit -> unit) -> GtkSignal.id
    method value_changed : callback:(unit -> unit) -> GtkSignal.id
  end

class adjustment :
  value:float ->
  lower:float ->
  upper:float ->
  step_incr:float -> page_incr:float -> page_size:float ->
  object
    inherit GObj.gtkobj
    val obj : Gtk.adjustment obj
    method as_adjustment : Gtk.adjustment obj
    method clamp_page : lower:float -> upper:float -> unit
    method connect : ?after:bool -> adjustment_signals
    method set_value : float -> unit
    method value : float
  end
class adjustment_wrapper : Gtk.adjustment obj -> adjustment


class tooltips :
  ?delay:int -> ?foreground:Gdk.Color.t -> ?background:Gdk.Color.t ->
  object
    inherit GObj.gtkobj
    val obj : Gtk.tooltips obj
    method connect : ?after:bool -> data_signals
    method disable : unit -> unit
    method enable : unit -> unit
    method set :
      ?delay:int ->
      ?foreground:Gdk.Color.t -> ?background:Gdk.Color.t -> unit
    method set_tip : #GObj.is_widget -> ?text:string -> ?private:string -> unit
  end
class tooltips_wrapper : Gtk.tooltips obj -> tooltips