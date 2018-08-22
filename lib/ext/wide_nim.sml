(*
 *
 * $File$
 *
 * $Author$
 * $Date$
 * $Revision$
 *
 *)

structure WideNim =
struct
  fun nim yield_mem nim_mem dim rules n =
  let
    fun nimr (0w0,0w0) = WordSet.singleton 0w0
      | nimr (n,0w1) =
        if (#1 o Array.sub) (nim_mem, Word.toInt (n+dim)) then
           (#2 o Array.sub) (nim_mem, Word.toInt (n+dim)) else
          let
            val nodes = (WordPairSet.listItems o Array.sub)
                        (yield_mem, Word.toInt n)
            val nims = ((foldl WordSet.union WordSet.empty) o (map nimr)) nodes;
            val new_nims = WordSet.singleton (Utils.compl_min nims)
          in
            Array.update (nim_mem, Word.toInt (n+dim), (true, new_nims));
            new_nims
          end
      | nimr (n,m) =
        if (#1 o Array.sub) (nim_mem, Word.toInt (n+m*dim)) then
           (#2 o Array.sub) (nim_mem, Word.toInt (n+m*dim)) else
          let
            val splits = IntSplits.strictSplit m n
            val s2n = (foldl Word.xorb 0w0) o
              (map (nim yield_mem nim_mem dim rules))
            val split_nims = foldl (fn (x,y) => WordSet.add(y,x)) WordSet.empty
              (map s2n splits)
            val zero_nim =
              if (m = 0w2) andalso (n mod 0w2 = 0w0) then
                WordSet.singleton 0w0
              else
                WordSet.empty
            val add_nodes =
              if (m > 0w2) then
                map (fn x => 0w2*x+m-0w2+((n-m) mod 0w2))
                (Utils.range 0w0 ((n-m) div 0w2))
              else []
            val add_nims =
              ((foldl WordSet.union WordSet.empty) o
               (map (fn x => nimr (x,m-0w2)))) add_nodes
            val new_nims =
              WordSet.union(WordSet.union(split_nims, zero_nim), add_nims)
          in
            Array.update (nim_mem, Word.toInt (n+m*dim), (true, new_nims));
            new_nims
          end
  in
    if n = 0w0 then 0w0 else
      (List.hd o WordSet.listItems o nimr) (n,0w1)
  end
end

