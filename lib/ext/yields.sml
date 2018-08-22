(*
 * $File$
 *
 * $Author$
 * $Date$
 * $Revision$
 *)

val _ =
  let
    val (m, strs) = Utils.readArgs TextIO.stdIn
    val rules = map (Rule.fromString) strs
    val domain = Utils.range 0w0 m
    val yields = map (Rule.rulesYield rules false) domain
    val out = ListPair.zip (domain, yields)
    val nodes2strs = (map (fn (x,y) =>
                          (Utils.wordToString x) ^ " " ^ (Utils.wordToString y)
                     )) o WordPairSet.listItems
  in
    map (fn x => (
      print ((Utils.wordToString o #1) x);
      print " ";
      print ((Utils.joinStrings o nodes2strs o #2) x);
      print "\n"
    )) out
  end
