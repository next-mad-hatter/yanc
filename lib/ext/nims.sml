(*
 *
 * $File$
 *
 * $Author$
 * $Date$
 * $Revision$
 *
 *)

val _ =
  let
    val (m, strs) = Utils.readArgs TextIO.stdIn
    val rules = map (Rule.fromString) strs
    val domain = Utils.range 0w0 m
    val k = Rule.maxSplit rules
    val yields = (Array.fromList o map (Rule.rulesYield rules true)) domain
    val nim_mem = Array.array
          (Word.toInt ((m+0w1)*(k+0w1)), (false, WordSet.empty))
    val nims = map (WideNim.nim yields nim_mem (m+0w1) rules) domain
    val out = ListPair.zip (domain, nims)
  in
    map (fn x => (
      print ((Utils.wordToString o #1) x);
      print " ";
      print ((Utils.wordToString o #2) x);
      print "\n"
    )) out
  end
