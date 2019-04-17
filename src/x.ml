(* This file is part of ecoss.
 *
 * Copyright (C) 2019 Yann Régis-Gianas, Théo Zimmermann
 *
 * ecoss is distributed under the terms of the MIT license. See the
 * included LICENSE file for details. *)

exception UndefinedReference

let ref_as_functions ?init () =
  match init with
    | Some init ->
       let x = ref init in
       ((( := ) x), (fun () -> !x))
    | None ->
       let x = ref None in
       let set v = x := Some v in
       let get () =
         match !x with
           | None -> raise UndefinedReference
           | Some x -> x
       in
       (set, get)

let critical_command cmd =
  if Sys.command cmd <> 0 then
    failwith (Printf.sprintf "%s has failed." cmd)

let ( $$ ) f g x =
  let y = f x in
  g y

let unSome = function
  | None -> assert false
  | Some x -> x

let ( !! ) f x =
  unSome (f x)

let seq_of_list l =
  let rec aux l () =
    match l with
      | [] -> Seq.Nil
      | x :: xs -> Seq.Cons (x, aux xs)
  in
  aux l

let list_of_seq s =
  Seq.fold_left (fun xs x -> x :: xs) [] s |> List.rev

let histogram () =
  let t = Hashtbl.create 13 in
  let count k = Hashtbl.(
    replace t k (1 + try find t k with Not_found -> 0)
  ) in
  let get () = Hashtbl.to_seq t |> list_of_seq in
  (count, get)
