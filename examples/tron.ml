(* Tron? Game *)
open GtkObj
open GdkObj  

let m_pi = acos (-1.)
let clRed   = `NAME "red"  (* `BLACK *)
let clBlue  = `NAME "blue" (* `WHITE *)
let clBlack = `BLACK

type point = {mutable x: int; mutable y: int}

let main () =
(* Game State *)
  let gameSize = 64 in
  let gameState = Array.create_matrix cols:(gameSize+2) rows:(gameSize+2) fill:0 in
  let gameInit _ = 
    for i=1 to gameSize do
      for j=1 to gameSize do
        gameState.(i).(j) <- 0;
      done
    done;
    for i=0 to gameSize do
      gameState.(0).(i) <- 3;            (* left wall *)
      gameState.(i).(gameSize+1) <- 3;   (* floor *) 
      gameState.(gameSize+1).(i+1) <- 3; (* right wall *)
      gameState.(i+1).(0) <- 3           (* ceiling *)
    done in
  gameInit ();
  let lpos = {x=4; y=4} in
  let lspeed = {x=0; y=1} in
  let rpos = {x=gameSize-3; y=gameSize-3} in
  let rspeed = {x=0; y= -1} in
  let keys = "asdfhjkl" in
  let keyMapL = [|(-1, 0); (0, -1); (0, 1); (1, 0)|] in
  let keyMapR = [|(-1, 0); (0, 1); (0, -1); (1, 0)|] in

(* User Interface *)
  let window = new_window `TOPLEVEL border_width:10 title:"tron(?)" in
  window#connect#event#delete
     callback:(fun _ -> prerr_endline "Delete event occured"; false);
  window#connect#destroy callback:Main.quit;
  let vbx = new_box `VERTICAL packing:window#add in   
  let area = new_drawing_area width:((gameSize+2)*4) height:((gameSize+2)*4) packing:vbx#add in
  let drawing = area#misc#realize (); new drawing (area#misc#window) in
  drawing#set background:`WHITE;
  let area_expose _ =
        for i=1 to gameSize+2 do
          for j=1 to gameSize+2 do
            if gameState.(i-1).(j-1) = 1 then begin
               drawing#set foreground:clRed;
               drawing#rectangle filled:true x:((i-1)*4) y:((j-1)*4) width:4 height:4
            end
            else if gameState.(i-1).(j-1) = 2 then begin
               drawing#set foreground:clBlue;
               drawing#rectangle filled:true x:((i-1)*4) y:((j-1)*4) width:4 height:4
            end
            else if gameState.(i-1).(j-1) = 3 then begin
               drawing#set foreground:clBlack;
               drawing#rectangle filled:true x:((i-1)*4) y:((j-1)*4) width:4 height:4
            end 
          done
        done;
        false  in
  area#connect#event#expose callback:area_expose;
  let control = new_table rows:3 columns:7 packing:vbx#add in

  let abuttonClicked num lbl _ = begin
    let dialog = new_window `TOPLEVEL border_width:10 title:"Key remap" in
    let dvbx = new_box `VERTICAL packing:dialog#add in
    let entry  = new_entry max_length:1 packing: dvbx#pack in
    let txt = String.make len:1 fill:keys.[num] in
    entry#set_text txt;
    let dquit = new_button label:"OK" packing: dvbx#pack in 
    dquit#connect#clicked callback: (fun _ -> let chr = entry#text.[0] in
                                              let txt2 = String.make len:1 fill:chr in
                                              lbl#set_label txt2;
                                              keys.[num]<-chr; 
                                              dialog#destroy ());
    dialog#show_all ()
  end in
  let new_my_button label:label left:left top:top =
      let str = String.make len:1 fill:keys.[label] in
      let btn = new_button packing:(control#attach left:left top:top) in
      let lbl = new_label label:str packing:(btn#add) in 
      btn#connect#clicked callback:(abuttonClicked label lbl);
      btn in
  new_my_button label:0 left:1 top:2;
  new_my_button label:1 left:2 top:1;
  new_my_button label:2 left:2 top:3;
  new_my_button label:3 left:3 top:2;
  new_my_button label:4 left:5 top:2;
  new_my_button label:5 left:6 top:3;
  new_my_button label:6 left:6 top:1;
  new_my_button label:7 left:7 top:2;
  let quit = new_button label:"Quit" packing:(control#attach left:4 top:2) in
  quit#connect#clicked callback:
   (fun _ -> window#destroy ());
  let message = new_label label:"tron(?) game" packing:vbx#add in

  let game_step _ = begin
        let lx = lpos.x in let ly = lpos.y in
        gameState.(lx).(ly) <- 1;
        drawing#set foreground:clRed;
        drawing#rectangle filled:true x:(lx*4) y:(ly*4) width:4 height:4;
        let rx = rpos.x in let ry = rpos.y in
        gameState.(rx).(ry) <- 2;
        drawing#set foreground:clBlue;
        drawing#rectangle filled:true x:(rx*4) y:(ry*4) width:4 height:4 end in
  game_step ();
  let keyDown ev = begin
    let key = Gdk.Event.Key.keyval ev in
    for i=0 to (Array.length keyMapL)-1 do
       let (x, y) = keyMapL.(i) in
       let k = keys.[i] in
       if key = Char.code k then begin
         lspeed.x <- x;
         lspeed.y <- y 
       end;
       let (x, y) = keyMapR.(i) in
       let k = keys.[i+4] in
       if key = Char.code k then begin
         rspeed.x <- x;
         rspeed.y <- y 
       end
    done;       
    false end in
  window#connect#event#key_press callback:keyDown;
  let safe_check _ = 
    if lpos.x == rpos.x && lpos.y == rpos.y then
      3
    else
      (* player 1 *)
      (if gameState.(lpos.x).(lpos.y) != 0  then 2 else 0)
      +
      (* player 2 *)
      (if gameState.(rpos.x).(rpos.y) != 0  then 1 else 0)
      in
  let timerID = ref (* dummy *) (Timeout.add 100 callback:(fun _ -> true)) in
  let timerTimer _ = begin
     lpos.x <- lpos.x+lspeed.x;
     lpos.y <- lpos.y+lspeed.y;
     rpos.x <- rpos.x+rspeed.x;
     rpos.y <- rpos.y+rspeed.y;
     let result = safe_check() in
     if result!=0 then begin
        Timeout.remove (!timerID);
        message#set_label ("player "^string_of_int result^" won.")
     end
     else begin
       game_step()
     end;
     true
  end in
  let count = ref 3 in
  let timerTimer2 _ = begin
(*    message#set_label (string_of_int (!count)); *)
    if (!count==0) then begin
      Timeout.remove (!timerID);
      timerID := Timeout.add 100 callback:timerTimer
    end
    else begin
      count := !count-1;
    end;
    true
  end in
  let restartClicked _ = begin
    gameInit();
    lpos.x <- 4; lpos.y <- 4;
    lspeed.x <- 0; lspeed.y <- 1;
    rpos.x <- gameSize-3; rpos.y <- gameSize-3;
    rspeed.x <- 0; rspeed.y <- -1;
    drawing#set foreground:`WHITE;
    drawing#rectangle filled:true x:0 y:0 width:((gameSize+2)*4) height:((gameSize+2)*4);
    area_expose();
    count := 3;
    timerID := Timeout.add 500 callback:timerTimer2;
  end in
  let restart = new_button label: "Restart" packing:(control#attach left:4 top:3) in
  restart#connect#clicked callback:restartClicked;
  restartClicked ();

  window#show_all ();
  Main.main ()

let _ = Printexc.print main ()

