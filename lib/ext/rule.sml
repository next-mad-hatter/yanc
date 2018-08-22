(*
 * $File$
 *
 * $Author$
 * $Date$
 * $Revision$
 *)

structure ExtWord =
struct

  exception Nonterm
  exception Invalid

  datatype ext_word = Inf | Val of word

  fun fromString "INF" = Inf
    | fromString x =
      if Utils.matches "^[0-9]+$" x then
        (Val o Utils.wordFromString) x
      else
        raise Invalid

  fun fromWord x = Val x

  fun toString Inf = "INF"
    | toString (Val x) = (Utils.wordToString) x

  fun compare (Inf, Inf) = EQUAL
    | compare (Val x, Inf) = LESS
    | compare (Inf, Val x) = GREATER
    | compare (Val x, Val y) = Word.compare(x, y)

  fun min a b = if compare (a,b) = LESS then a else b
  fun max a b = if compare (a,b) = GREATER then a else b

  fun range Inf _ = raise Nonterm
    | range _ Inf = raise Nonterm
    | range (Val a) (Val b) = Utils.range a b

end

structure Rule =
struct

  exception Invalid

  type rule = {
    min: ExtWord.ext_word,
    max: ExtWord.ext_word,
    splits: WordSet.set
  }

  fun fromList (x::y::xs) =
    let
      val min = ExtWord.fromString x
      val max = ExtWord.fromString y
      val splits = (WordSet.fromList o map Utils.wordFromString) xs
    in
      if ExtWord.compare (min, max) = GREATER then raise Invalid
      else if min = ExtWord.fromWord 0w0 andalso WordSet.member (splits, 0w1)
           then raise Invalid
      else if min = ExtWord.fromWord 0w0 andalso WordSet.member (splits, 0w0)
           then raise Invalid
      else if min = ExtWord.fromString "INF" andalso
              not (WordSet.member (splits, 0w0))
           then raise Invalid
      else if WordSet.compare (WordSet.empty, splits) = EQUAL
           then raise Invalid
      else {
        min = min,
        max = max,
        splits =
          if min = ExtWord.fromString "INF" then WordSet.singleton 0w0 else
            splits
      }
    end
    | fromList _ = raise Invalid

  val fromString = fromList o Utils.splitString

  fun toString (r: rule) =
    let
      val min = (ExtWord.toString o #min) r
      val max = (ExtWord.toString o #max) r
      val splits = ((map Utils.wordToString) o WordSet.listItems o #splits) r
    in
      Utils.joinStrings (min::max::splits)
    end

  fun ruleYields (r:rule) n =
    if #min r = ExtWord.fromString "INF" then WordPairSet.singleton (0w0,0w0)
    else let
      val a = ExtWord.max (ExtWord.fromWord 0w0) (#min r)
      val b = ExtWord.min (ExtWord.fromWord n) (#max r)
      val ns = map (fn x => n-x) (ExtWord.range a b)
      val ps = ListXProd.mapX (fn x => x) (ns, (WordSet.listItems o #splits) r)
      fun valid (0w0,0w0) = true
        | valid (_,0w0) = false
        | valid (n,s) = (n >= s)
    in
      WordPairSet.fromList (List.filter valid ps)
    end

  fun maxSplit (rs: rule list) =
    let
      fun max [] =  0w0
        | max (x::xs) = foldl (fn (a,b) => if a > b then a else b) x (x::xs)
    in
      (max o map (List.last o WordSet.listItems o #splits)) rs
    end

  fun rulesYield (rs: rule list) compact n =
  let
    fun cut s =
      let
        fun del [] = []
          | del ((a,b)::xs) =
            if b <= 0w2 then (a,b)::del(xs) else
              let
                fun f(x,y) = x >= a orelse y >= b orelse
                             not((x-a) mod 0w2 = 0w0) orelse
                             not((y-b) mod 0w2 = 0w0)
                val ys = List.filter f xs
              in
                (a,b)::del(ys)
              end
      in
        (WordPairSet.fromList o del o List.rev o WordPairSet.listItems) s
      end
    val ss = ((foldl WordPairSet.union WordPairSet.empty) o
              (map (fn r => ruleYields r n))) rs
  in
    if compact then cut ss else ss
  end

end
