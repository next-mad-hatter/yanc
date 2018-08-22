(*
 * $File$
 *
 * $Author$
 * $Date$
 * $Revision$
 *)

local
  structure WordKey =
  struct
    type ord_key = Word.word
    val compare = Word.compare
  end
in
  structure WordSet: ORD_SET = SplaySetFn(WordKey)
end

local
  structure WordPairKey =
  struct
    type ord_key = Word.word * Word.word
    fun compare ((a,b),(x,y)) = let
      val t = Word.compare (a,x)
    in
      if t = EQUAL then Word.compare (b,y) else t
    end
  end
in
  structure WordPairSet: ORD_SET = RedBlackSetFn(WordPairKey)
end

structure Utils =
struct

  (*
   * Returns [a,b] as a list of values.
   *)
  local
    fun ranger a b l =
      if a > b then l else
      if a = b then a::l else
      ranger a (b-0w1) (b::l)
  in
    fun range a b = ranger a b []
  end

  (*
   * Returns min(N_0\s)
   *)
  fun compl_min s =
    if WordSet.compare (s, WordSet.empty) = EQUAL then 0w0 else
      let
        fun f x [] = x
          | f x (y::ys) = if x < y then x else f (y+0w1) ys
      in
        f 0w0 (WordSet.listItems s)
      end

  structure RegExp: REGEXP = RegExpFn
    (structure P = AwkSyntax; structure E = BackTrackEngine)

  fun matches e s =
  let
    val r = RegExp.compileString e
    val m = (RegExp.find r) Substring.getc (Substring.full s)
  in
    isSome m
  end

  val splitString = (String.tokens (fn c => c = #" " orelse c = #"\t"))

  val joinStrings =
  let
    fun con x "" = x
      | con "" y = y
      | con x y = x ^ " " ^ y
    fun joinr s [] = s
      | joinr s (x::xs) = joinr (con s x) xs
  in
    joinr ""
  end

  val wordToString = Word.fmt StringCvt.DEC

  val wordFromString = valOf o (StringCvt.scanString (Word.scan StringCvt.DEC))

  fun readArgs input =
  let
    val n = (wordFromString o valOf o TextIO.inputLine) input
    fun read rules =
      let
        val line = TextIO.inputLine input
      in
        if line = NONE then rules
        else if line = SOME "" orelse line = SOME "\n" then (read rules)
        else read ((valOf line)::rules)
      end
    handle Option => rules
  in
    (n, read [])
  end

end

