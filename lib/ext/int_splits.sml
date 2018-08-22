(*
 * $File$
 *
 * $Author$
 * $Date$
 * $Revision$
 *)

signature INT_SPLITS =
sig

  (*
   * Defined for non-negative arguments,
   *   (strict_split s)
   * returns all subdivisions of an integer into s unique ones,
   * keeping the total.
   *)
  val strictSplit : word -> word -> word list list

  (*
   * Defined for non-negative arguments,
   *   (wide_split s)
   * returns all subdivisions of an integer into s new ones,
   * keeping the total.
   *)
  val wideSplit : word -> word -> word list list

end

structure IntSplits :> INT_SPLITS =
struct

  fun curry f x y = f (x,y)

  val merge = foldl op@ ([]: word list list)

  fun strictSplit 0w0 0w0 = [[]]
    | strictSplit 0w1 n = [[n]]
    | strictSplit m n =
      if n < m*(m+0w1) div 0w2 then [] else
      let
        val unpack = fn x => (fn l => x::l) o (map ((curry op+) x))
        val res = fn x => map (unpack x) (strictSplit (m-0w1) (n-m*x))
        val xs = Utils.range 0w1 ((0w2*n-m*(m-0w1)) div (0w2*m))
      in
        (merge o (map res)) xs
      end

  fun wideSplit 0w0 0w0 = [[]]
    | wideSplit 0w1 n = [[n]]
    | wideSplit m n =
      if n < m then [] else
      let
        val unpack = fn x =>  (fn l => x::l) o (map ((curry op+) (x-0w1)))
        val res = fn x => map (unpack x)
          (wideSplit (m-0w1) (n-x-(m-0w1)*(x-0w1)))
        val xs = Utils.range 0w1 (n div m)
      in
        (merge o (map res)) xs
      end

end

