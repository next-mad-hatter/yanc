#
# = $File$ : 
#
# $Author$
# $Date$
# $Revision$
#


##
#
# This file includes convenience shell preloads as well as bits and snippets
# of quickly tried code.  Not intended to make any sense or be run by anyone.
#
##

require 'benchmark'
require 'set'
require_relative '../yanc.rb'

__END__

class YANC::Ruleset
  public :split_pile
  public :strict_split
end

$rs = YANC::Ruleset.new("./data/rules/strange", 10, false)

##
# Produces subdivisions of a height n pile into m unique ones.
#
def strict_split(n, m)
  (yield []; return) if n == 0 and m == 0
  (yield [n]; return) if m == 1
  return if n < m*(m+1)/2
  (yield((1..m).to_a); return) if n == m*(m+1)/2 # not really necessary :)
  (1..((2*n-m*(m-1))/(2*m))).each{|x|
    strict_split(n-m*x, m-1){|y| yield [x] + y.map{|z| z+x}}
  }
end


=begin
      ##
      # For a set S represented by self, we define min((N_0\S) here.
      #
      def compl_min
        #return (if self.empty? then 0 else ((0..self.max+1).to_set - self).min end)
        ## or this:
        all = [nil]
        self.each{|m| all[m] = m}
        all.index(nil) || all[-1] + 1
      end
=end

=begin
  ###### NIM EXP: NatSet version :)

  ##
  # A set's represented as its complement in N_0:
  #    (0, left) U points U [right, inf)
  #
  class NatSet

    attr_reader :right
    attr_reader :left
    attr_reader :points

    def initialize(args=[])
      @points = Set.new([])
      @left = 0
      @right = 0
      args.each{|x| add!(x)}
    end

    def add!(x)
      if @left == @right
        @left = x
        @right = x+1
        return x
      end
      if x < @left
        @points += (x+1..@left-1).to_set
        @left = x
      elsif x >= @right
        @points += (@right..x-1).to_set
        @right = x+1
      else
        @points.delete x
      end
      x
    end

    def min
      @left
    end

    def c_min
      if @left > 0 then 0 else @points.min || @right end
    end

    def include?(x)
      (x < left) or (x >= right) or @points.include? x
    end

    def union!(s)
      @points.delete_if{|x| not s.include? x}
      if @right < s.right
        (@right..s.right-1).each{|x| @points << x if s.include? x}
        @right = s.right
      end
      if @left > s.left
        (s.left..@left-1).each{|x| @points << x if s.include? x}
        @left = s.left
      end
      self
    end

  end

      z = NatSet.new([0])
      @nim_mem_exp = [[z,z]]

    def nim_experimental(n, m)
      return @nim_mem_exp[n][m] if @nim_mem_exp[n] and @nim_mem_exp[n][m]
      @nim_mem_exp[n] ||= []
      if m == 1
        res = NatSet.new
        @op_mem_cut[n].each{|x| res.union!(nim_experimental(*x)) }
        @nim_mem_exp[n][m] = NatSet.new([res.c_min])
      else
        res = NatSet.new
        strict_split(n,m){|v| res.add!(v.map{|x| nim_experimental(x,1).min}.inject(0,&:^))}
        (n-2).step(m-2,-2).each{|x| res.union!((nim_experimental(x,m-2)))} if m > 2
        res.add! 0 if m == 2 and n % 2 == 0 and n > 1
        @nim_mem_exp[n][m] = res
      end
    end

=end


class Set

  def power_set
    self.inject(Set[Set[]]) {|s,x|
      s + s.map{|e| e + Set[x]}
    }
  end

end

##
# Writing C-style code in ruby (not C :)) is thankfully no quicker than writing
# ruby code in ruby.
#
#class IntSet
#
#  attr_reader :num
#
#  def initialize(ns)
#    @num = 0
#    ns.each{|x|
#      @num |= (1 << x)
#    }
#  end
#
#  private
#
#  #def msb(x)
#  #    x.to_s(2).size - 1
#  #end
#
#  #def lsb(x)
#  #    msb(x & -x)
#  #end
#
#  public
#
#  #def first
#  #  throw "EMPTY SET QUERIED" if @num == 0
#  #  lsb(@num)
#  #end
#
#  def elements
#    s, n = [], 0
#    while 2**n <= @num do
#      s << n if @num[n] == 1
#      n += 1
#    end
#    s
#  end
#
#  def add!(n)
#    if n.is_a? IntSet
#      @num |= n.num
#    else
#      @num |= (1 << n)
#    end
#    self
#  end
#
#  def compl_min
#    n = 0
#    n += 1 while @num[n] == 1
#    n
#  end
#
#  def to_s
#    "IntSet #{elements.inspect}"
#  end
#
#end
#@nim_mem_exp = [[0],[0]] # for IntSet
#
##
# Branch-memoizing nim computation using IntSet.
#
#def nim_experimental(n,m)
#  return @nim_mem_exp[n][m] if @nim_mem_exp[n] and @nim_mem_exp[n][m]
#  @nim_mem_exp[n] ||= []
#  if m == 1
#    u = IntSet.new([])
#    @op_mem_cut[n].each{|x| u.add!(nim_experimental(*x))}
#    @nim_mem_exp[n][m] = u.compl_min
#  else
#    res = IntSet.new([])
#    strict_split(n,m){|v| res.add!(v.map{|x| nim_experimental(x,1)}.inject(0,&:^))}
#    (n-2).step(m-2,-2).each{|x| res.add!(nim_experimental(x,m-2))} if m > 2
#    res.add!(0) if m == 2 and n % 2 == 0 and n > 1
#    @nim_mem_exp[n][m] = res
#  end
#end


def split_pile(n, count, compact)
  yield [] and return if n == 0 and count == 0
  return if n < count or count == 0
  yield [n] and return if count == 1
  (1..(n/count)).each{|x|
    split_pile(n-x-(count-1)*(x-1), count-1, compact){|y|
      yield(
        (if compact and y[0] == 1 then (y.shift and []) else [x] end) + y.map{|z| z + x - 1}
      )
    }
  }
end
test = Enumerator.new{|res| split_pile{|x| res << x}}

Benchmark.bm do |x|
  n, m, a = 30, 30, (0..30).to_a
  b = [[a]*m] * n
  n.times{ p = []; m.times { p << a.shuffle }; b << p }
  x.report{10.times{ b.inject(&:+).uniq.to_set }}
  x.report{10.times{ s = Set[]; b.each{|r| r.each{|t| s << t }} }}
  x.report{10.times{ b.inject(Set[]){|s,r| s + r} }}
  #puts "N", (b.inject(&:+).uniq.to_set) == b.to_set.flatten
end

def strict_split(n,m)
  return [[]] if n == 0 and m == 0
  return [[n]] if m == 1
  return [] if n < m*(m+1)/2
  return [(1..m).to_a] if n == m*(m+1)/2 # not really necessary :)
  (1..((2*n-m*(m-1))/(2*m))).map{|x|
    strict_split(n-m*x,m-1).map{|y| [x] + y.map{|z| z+x}}
  }.inject(&:+)
end

def split_compact(n, s)
  return (if s == 0 then [[]] else [] end) if n == 0
  return (if n == 0 then [[]] else [] end) if s == 0
  return [] if n < s
  return [[n]] if s == 1
  (1..(n/s)).map{|x|
    split_compact(n-x-(s-1)*(x-1), s-1).map{|r|
      (if r[0] == 1 then (r.shift and []) else [x] end) + r.map{|z| z + x - 1}
    }
  }.inject(&:+)
end

def shorten(a)
  if a.empty?
    a
  elsif a[0] == a[1]
    shorten(a[2..-1])
  else
    [a[0]] + shorten(a[1..-1])
  end
end
puts shorten([1,2,6,3,3,3,7,7,8,8,8]).join(" ")

Customer = Struct.new(:name, :address) do
  def greeting
    "Hello #{name}!"
  end
end
dave = Customer.new("Dave", "123 Main")
puts dave.greeting

Dog = Struct.new(:bark, :bite) do
  def initialize(*args)
    super(*args)
    self.bark = "really loud" unless bark
  end
end

Benchmark.bm do |x|
  # How do I do (lambdas).each class_eval?
  def v1(s)
    all = [nil]
    s.each{|m| all[m] = m}
    all.index(nil) || all[-1] + 1
  end
  def v2(s)
    if s.empty? then 0 else ((0..s.max+1).to_set - s).min end
  end
  a = (0..500).to_set
  b = (0..10).to_set
  Set.class_eval do
    def bar_min
      v1(self)
    end
  end
  x.report{100.times{ a.bar_min; b.bar_min }}
  Set.class_eval do
    def bar_min
      v2(self)
    end
  end
  x.report{100.times{ a.bar_min; b.bar_min }}
end

Benchmark.bm do |x|
  x.report{100.times{ y = nil; 10000.times{|i| y = i } }}
  # iirc this used to be slower in 1.8
  x.report{100.times{ 10000.times{|i| y = i } }}
end

Benchmark.bm do |x|
  a = ((0..100).to_a * 100 + (0..50).to_a * 100).shuffle
  h = Hash.new(0)
  x.report{100.times{ a.map{ |n| h[n] += 1 } }}
  h = Hash.new(0)
  x.report{100.times{ a.map{ |n| h[n] += 1 unless x == 0 } }}
  h = Hash.new(0)
  x.report{100.times{ a.map{ |n| h[n] += 1 } ; h.delete_if{|k,v| v == 0} }}
end

Benchmark.bm do |x|
  a = (0..5000).to_a.shuffle
  b = (0..10).to_a.shuffle
  x.report{100.times{ b.product(a) }}
  x.report{100.times{ a.product(b) }}
end

