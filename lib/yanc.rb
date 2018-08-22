#!/usr/bin/ruby
#
# = $File$ :
#
# $Author$
# $Date$
# $Revision$
#

###############################################################################
#                                                                             #
#    *** Classical Topics in Computer Science : Task 2 -- Group 13 ***        #
#                                                                             #
#                        Yet Another NIM Cruncher.                            #
#                                                                             #
###############################################################################

require 'java' if RUBY_PLATFORM == 'java'
require 'set'

require 'open3'

module YANC

  INF = Float::INFINITY

  class CustomException < Exception
  end

  module Utils

    def self.warn(str)
      $stderr.puts str
    end

    def self.stop_time
      t = Time.now
      yield
      Time.now - t
    end

    ##
    # Rids us of annoying message when running as compiled java code.
    #
    def self.exit(n)
      if RUBY_PLATFORM == 'java' then java.lang.System.exit(n) else Kernel.exit(n) end
    end

  end

  ##
  # This should be done via refinements in more recent ruby versions.
  #
  [Array, Range, Set].each do |c|

    if c.instance_methods.include? :uniq_sum
      raise CustomException.new("Will not redefine uniq_sum")
    end

    c.class_eval do

      ##
      # An inplace-accumulating (hence faster) equivalent of
      #               (fold union) o (map b),
      # for blocks returning enumerable containers.
      #
      def uniq_sum
        s = Set[]
        self.each{|r| yield(r).each{|t| s << t}}
        s
      end

    end

  end

  class Rule

    attr_reader :min, :max, :splits

    ##
    # +args+ should contain integer rule parameters.
    #
    def initialize(*args)
      raise CustomException.new("Bad rule #{args.inspect}") if args.length < 3
      @min, @max, *@splits = *args
      raise CustomException.new("Bad rule #{args.inspect}") if @min > @max
      if @min == 0 and (@splits.include? 1 or @splits.include? 0)
        raise CustomException.new("Nonterminating rule #{args.inspect}")
      end
      @splits = Set.new(splits)
      @splits.delete(INF)
      @splits.delete_if{|x| x > 0 } if @min == INF
      raise CustomException.new("Not well defined: #{args.inspect} yields empty rule") if @splits.empty?
    end

    def to_s
      [@min, @max].map{|x| if x == INF then "INF" else x.to_s end}.join(" ") + " " + @splits.to_a.join(" ")
    end

    def pp
      "#{@min}-#{@max} -> " + @splits.to_a.join(" ")
    end

    def hash
      [@min, @max, @splits].hash
    end

    def eql?(x)
      x.is_a? self.class and @min == x.min and @max == x.max and @splits == x.splits
    end

    def ==(x)
      eql?(x)
    end

    def +(x)
      # we could merge rules' intervals here but do not need it anywhere for now
      raise CustomException.new("Cannot add rules #{self.to_s} and #{x.to_s}") if x.min != @min or x.min != @min
      Rule.new(min, max, *(@splits + x.splits))
    end

  end

  class Ruleset

    attr_reader :rules

    ##
    # Rules can be provided explicitly or via filename.
    #
    def initialize(rules, max_height, nims_only)
      @rules = if rules.is_a? String then read_rules(rules) else rules end
      Utils.warn("WARNING: split set unexpectedly large: #{max_splits_set.inspect}") if max_splits_set.length > 5
      @max_height = max_height
      build_ops(nims_only)
    end

    private

    def read_rules(file)
      s = []
      File.readlines(file).map{|x| x.gsub(/#.*$/,'')}.
        map(&:strip).select{|x| x != ''}.
        map{|x| x.split.map{|y| if y.upcase == "INF" then INF else y.to_i end}
      }.each{|x|
        # we do want to merge rules of same intervals
        r = Rule.new(*x)
        i = s.find_index{|o| o.min == r.min and o.max == r.max}
        if i then s[i] += r else s << r end
      }
      s
    end

    def max_splits_set
      @rules.uniq_sum{|x| x.splits}
    end

    def build_ops(nims_only=false)
      res = false
      t = Utils.stop_time{ res = fetch_nims }
      if res
        Utils.warn("NIMs computed in #{t}s.")
      else
        raise CustomException.new("External nim computation failed")
      end

      return if nims_only

      res = false
      t = Utils.stop_time{ res = fetch_map }
      if res
        Utils.warn("Legal moves map built in #{t}s.")
      else
        raise CustomException.new("External map computation failed")
      end
    end

    def fetch_map
      ext = File.expand_path(File.dirname(__FILE__)) + "/ext/yields"
      @op_mem = []
      unread = (0..@max_height).to_set
      thread = nil
      Open3.popen3(ext) do |i,o,e,t|
        i.puts @max_height
        @rules.each{|r| i.puts r.to_s}
        i.close
        o.each_line do |l|
          x = l.strip.split.map(&:to_i)
          @op_mem[x[0]] = x[1..-1].each_slice(2).to_set
          unread.delete x[0]
        end
        err = e.read
        Utils.warn err unless err.strip.empty?
        o.read
        o.close
        e.close
        thread = t
      end
      if thread.value.termsig
        Utils.warn "Subprocess received signal #{thread.value.termsig.to_s}."
      end
      return (thread.value.success? and unread.empty?)
    end

    def fetch_nims
      ext = File.expand_path(File.dirname(__FILE__)) + "/ext/nims"
      @nim_mem = [0]
      unread = (1..@max_height).to_set
      thread = nil
      Open3.popen3(ext) do |i,o,e,t|
        i.puts @max_height
        @rules.each{|r| i.puts r.to_s}
        i.close
        o.each_line do |l|
          x = l.strip.split.map(&:to_i)
          @nim_mem[x[0]] = x[1]
          unread.delete x[0]
        end
        err = e.read
        Utils.warn err unless err.strip.empty?
        o.read
        o.close
        e.close
        thread = t
      end
      if thread.value.termsig
        Utils.warn "Subprocess received signal #{thread.value.termsig.to_s}."
      end
      return (thread.value.success? and unread.empty?)
    end

    def ensure_max_height(n, mem)
      return if n <= @max_height and mem and mem[n]
      Utils.warn("WARNING: rebuild required.")
      @max_height = [@max_height, n].max
      build_ops
    end

    public

    def nim(n)
      ensure_max_height(n, @nim_mem)
      @nim_mem[n]
    end

    private

    ##
    # Applied to a single pile, returns all its possible subdivisions into
    # given number of new ones, retaining the total volume.  If compact options
    # is given, shortens subdivisions mod 2.
    #
    def split_pile(n, count, compact)
      (yield []; return) if n == 0 and count == 0
      return if n < count or count == 0
      (yield [n]; return) if count == 1
      (1..(n/count)).each{|x|
        split_pile(n-x-(count-1)*(x-1), count-1, compact){|y| yield(
          (if compact and y[0] == 1 then (y.shift and []) else [x] end) +
          y.map{|z| z + x - 1}
        )}
      }
    end

    public

    ##
    # Returns list of all positions reachable from single pile.
    #
    def legal_moves(n)
      ensure_max_height(n, @op_mem)
      r = Set[]
      @op_mem[n].each{|x| split_pile(*x, false){|v| r << v}}
      r
    end

    def hash
      @rules.hash
    end

    def eql?(x)
      x.is_a? self.class and @rules == x.rules
    end

    def ==(x)
      eql?(x)
    end

    def to_s
      "[" + @rules.map(&:pp).join(" ; ") + "]"
    end

  end

  ##
  # Represents a single position (a list of pile values, here as a counting hash).
  #
  class Position

    attr_reader :ruleset
    attr_reader :piles

    def initialize(ruleset, piles, opts={})
      options = {:delete_zero => false}.merge(opts)
      @ruleset = ruleset
      if piles.is_a? Hash
        @piles = piles
        if options[:delete_zero]
          @piles.delete(0)
          @piles.delete_if{|x,y| y == 0}
        end
      elsif piles.is_a? Array
        @piles = Hash.new(0)
        piles.map{|x| @piles[x] += 1 unless x == 0}
      else
        raise CustomException.new("Could not convert #{piles.inspect} (#{piles.class}) to Position.")
      end
    end

    def hash
      [@piles, @ruleset].hash
    end

    def eql?(x)
      x.is_a? self.class and @piles == x.piles and @ruleset == x.ruleset
    end

    def ==(x)
      eql?(x)
    end

    def +(pos)
      raise CustomException.new("Cannot add positions from disagreeing rulesets.") unless pos.ruleset == @ruleset
      Position.new(@ruleset, @piles.merge(pos.piles){|k,x,y| x+y})
    end

    ##
    # Legal moves in (pile, new position it yields) format.
    #
    def legal_moves
      return [] if @piles.empty?
      @piles.keys.uniq_sum{|n|
        @ruleset.legal_moves(n).map{|p| [n, Position.new(@ruleset, p)]}
      }
    end

    def apply_move(move)
      s,p = *move
      x = @piles.dup
      x[s] -= 1
      x.delete(s) if x[s] == 0
      Position.new(@ruleset, x) + p
    end

    def nim
      @piles.keys.select{|x| @piles[x] % 2 > 0}.map{|s| @ruleset.nim(s) }.inject(0,&:^)
    end

    def winning_moves
      legal_moves.select{|x| apply_move(x).nim == 0}
    end

    def best_move
      legal_moves.find{|x| apply_move(x).nim == 0} or legal_moves.first
    end

    def has_pile?(n)
      @piles.keys.include? n
    end

    def to_s
      s = @piles.sort.map{|x,y| if y > 1 then y.to_s + "*" else "" end + x.to_s }.join(" ")
      if s.empty? then "0" else s end
    end

    def pp
      ["[", if to_s == "0" then "_" else to_s end, "]"].join(" ")
    end

  end

  module Utils

    ##
    # The ugly pretty printer.  Write-only code follows.
    #
    def self.pretty_print(ruleset, max_height, line_width)
      values = (0..max_height).map{|x| ruleset.nim(x)}
      max_len = values.max.to_s.length
      max_row = (max_height.div 10)
      return [
       "  Precomputed nimbers:",
       "-" * [line_width,(max_row*10).to_s.length + 3 + 9 + 10*max_len + 2].max,
       " " * ((max_row*10).to_s.length + 1) + " | " + (0..9).map{|x| x.to_s.rjust(max_len)}.join(" "),
       "-" * [line_width,(max_row*10).to_s.length + 3 + 9 + 10*max_len + 2].max,
       (0..max_row*10).step(10).map {|x|
         " " + x.to_s.rjust((max_row*10).to_s.length) + " | " +
         (0..9).map{|y| values[x+y].to_s.rjust(max_len)}.join(" ")
       }.join("\n"),
       "-" * [line_width,(max_row*10).to_s.length + 3 + 9 + 10*max_len + 2].max,
      ].join("\n")
    end

  end

end

###############################################################################
#
#
#                        Let Runtime Be Our Judge
#
#
###############################################################################

if __FILE__ == $0 # or true # for ruby-prof

  # acceptable for code this size
  include YANC

  options = {
    :line_width => 42,
    :rules_file => nil,
    :prompt => "> ",
    :max_height => 500,
    :dump => false,
    :first_move => true,
    :echo => false,
    :plain_dump => false,
    :readln_style => false,
    :delegate => true,
  }

  if ARGV.delete("-h")
    puts
    puts "Usage: #{File.basename($0)} [-h|-d] [-p] [-m MAX_HEIGHT] [-v] [-u] rules_file [input_file(s)]"
    puts
    puts "Commands:"
    puts
    puts "  -h               : print this message and exit"
    puts "  -d               : dump computed nimbers and exit"
    puts
    puts "Options:"
    puts
    puts "  rules_file       : ruleset"
    puts "  input_file(s)    : to be read in place of stdin"
    puts
    puts "  -m MAX_HEIGHT    : maximum pile height nimbers are to be precomputed for (default: #{options[:max_height]})"
    puts "  -p               : if -d is given, produces plain (one number -> nimber pair per line) dump"
    puts "  -u               : user moves first"
    puts "  -v               : echo input (useful if input has no echo)"
    puts "  -e               : user prefers enter to space key (ignores -u)"
    puts
    Utils.exit(0)
  end
  options[:dump] = true if ARGV.delete("-d")
  options[:echo] = true if ARGV.delete("-v")
  options[:first_move] = false if ARGV.delete("-u")
  options[:plain_dump] = true if ARGV.delete("-p")
  options[:readln_style] = true if ARGV.delete("-e")
  while i = ARGV.index("-m")
    if i+1 == ARGV.length
      puts "Error: missing max height parameter"
      Utils.exit(1)
    end
    m = ARGV.delete_at(i+1)
    unless /^\d+$/ =~ m
      puts "Error: bad max height parameter #{m}"
      Utils.exit(1)
    end
    options[:max_height] = m.to_i
    ARGV.delete_at(i)
  end
  unless ARGV.length > 0
    puts "Error: ruleset file required"
    Utils.exit(1)
  end
  options[:rules_file] = ARGV.shift

  begin
    ruleset = Ruleset.new(options[:rules_file], options[:max_height], options[:dump])
  rescue StandardError, CustomException => e
    puts "Error: " + e.to_s
    Utils.exit(1)
  end

  if options[:dump]
    if options[:plain_dump]
      (0..options[:max_height]).map{|x| puts [x, ruleset.nim(x)].join(" ") }
    else
      puts Utils.pretty_print(ruleset, options[:max_height], options[:line_width])
    end
    Utils.exit(0)
  end

  puts "=" * options[:line_width]
  puts
  puts "  Welcome to Yet Another NIM Cruncher."
  puts ""
  puts "    $Revision$"
  puts "    $Date$"
  puts ""
  puts "=" * options[:line_width]

  puts Utils.pretty_print(ruleset, options[:max_height], options[:line_width])
  puts
  puts "To play,"
  puts
  unless options[:readln_style]
    puts "  * enter a list of initial pile heights"
    puts "    (multiples entered as n*m), separated by whitespace,"
  else
    puts "  * enter the initial configuration"
    puts "    by following onscreen instructions,"
  end
  puts
  puts "  * followed by your moves when prompted to,"
  puts "    format being \"old_pile_height new_pile_height(s)\"."
  puts
  unless options[:readln_style]
    puts "Type either of:"
  else
    puts "Having entered initial configuration, you can type either of:"
  end
  puts
  puts "  \"quit\"   to quit"
  puts "  \"rules\"  to see the ruleset"
  puts "  \"help\"   for a list of possible moves"
  puts
  puts "at any time."
  puts

  old_pos = nil
  if options[:readln_style]
    starting_piles = []
    piles_count = nil
    begin
      print "Enter initial number of piles: "
      instr = ARGF.readline
      puts instr if options[:echo]
      instr.strip!
      raise CustomException.new("Illegal input") unless /^\d+$/ =~ instr
      piles_count = instr.to_i
    rescue CustomException => e
      puts e
      retry
    end
    (1..piles_count).each do |n|
      begin
        print "Enter height of pile #{n.to_s.rjust(piles_count.to_s.length)}: "
        instr = ARGF.readline
        puts instr if options[:echo]
        instr.strip!
        raise CustomException.new("Illegal input") unless /^\d+$/ =~ instr
        starting_piles[n-1] = instr.to_i
      rescue CustomException => e
        puts e
        retry
      end
    end
    old_pos = Position.new(ruleset, starting_piles)
    begin
      print "Do you wish to move first? (Y/N) "
      instr = ARGF.readline
      puts instr if options[:echo]
      instr.strip!
      raise CustomException.new("Illegal input") unless /^Y|N$/ =~ instr
      options[:first_move] = (instr.upcase == "N")
    rescue CustomException => e
      puts e
      retry
    end
    puts old_pos.pp
  end

  cheat_count = 0
  my_move = options[:first_move]
  print options[:prompt] unless old_pos and my_move

  loop do

    if old_pos and my_move
      old_pos.winning_moves.
        sort{|x,y| [x[0],x[1].piles.keys.length] <=> [y[0],y[1].piles.keys.length]}.
        each{|x| puts " + " + x.join(" -> ")}
      move = old_pos.best_move
      unless move
        puts
        print "Adversary wins "
        puts(if cheat_count == 0 then "this time." else "by way of cheating." end)
        Utils.exit(0)
      end
      puts "=> " + move.join(" -> ")
      old_pos = old_pos.apply_move(old_pos.best_move)
      puts old_pos.pp
      if old_pos.legal_moves.empty?
        puts
        puts "Adversary loses again."
        Utils.exit(0)
      end
      my_move = false
      print options[:prompt]
      next
    end

    if old_pos and old_pos.legal_moves.empty?
      puts
      puts "Adversary loses again."
      Utils.exit(0)
    end

    # WEIRD: why does ARGF.eof? return true while stdin is still open?
    begin
      line = ARGF.readline
    rescue
      puts
      puts "Adversary flees cowardly."
      Utils.exit(0)
    end
    line.strip!
    if line == ""
      print options[:prompt]
      next
    end
    puts line if options[:echo]

    if line == "quit"
      puts
      puts "Adversary flees cowardly."
      Utils.exit(0)
    end

    if line == "rules"
      puts "=" * options[:line_width]
      puts ruleset.rules.map{|x| "  " + x.pp}.join("\n")
      puts "=" * options[:line_width]
      print options[:prompt]
      next
    end

    if /.*help.*/ =~ line.downcase
      unless old_pos
        puts "Adversary requests help, but must provide a starting position first."
      else
        puts "Adversary requests help."
        old_pos.legal_moves.each{|p| puts "Try " + p.join(" ")}
      end
      print options[:prompt]
      next
    end

    unless old_pos
      s = Hash.new(0)
      unless /^(\s*\d+(\*(\d+))?\s*)+$/ =~ line
        puts "Illegal position description."
        print options[:prompt]
        next
      end
      line.strip.split.each {|w|
        if /^(\d+)\*(\d+)$/ =~ w
          if $2.to_i != 0
            s[$2.to_i] += $1.to_i unless $1.to_i == 0 or $1.to_i == 0
          end
        else
          s[w.to_i] += 1 unless w.to_i == 0
        end
      }
      old_pos = Position.new(ruleset, s)
      puts old_pos.pp + if my_move then "[*#{old_pos.nim.to_s}]" else "" end
      unless my_move
        print options[:prompt]
        next
      end
    end

    unless my_move
      unless /^\s*\d+\s*(\s*\d+(\*\d+)?\s*)+$/ =~ line
        puts "Illegal move description."
        print options[:prompt]
        next
      end
      k = (line.strip.split)[0].to_i
      unless old_pos.has_pile? k
        puts "There is no pile of height #{k} at current time."
        print options[:prompt]
        next
      end
      s = Hash.new(0)
      (line.strip.split)[1..-1].each {|w|
        if /^(\d+)\*(\d+)$/ =~ w
          if $2.to_i != 0
            s[$2.to_i] += $1.to_i unless $1.to_i == 0 or $1.to_i == 0
          end
        else
          s[w.to_i] += 1 unless w.to_i == 0
        end
      }
      unless old_pos.legal_moves.include? [k, Position.new(ruleset, s)]
        print "NOTE: Adversary cheats by entering illegal move."
        print " Again." if cheat_count > 0
        puts
        cheat_count +=1
      end
      old_pos = old_pos.apply_move([k, Position.new(ruleset, s)])
      puts old_pos.pp + "[*#{old_pos.nim.to_s}]"
      my_move = true
    end

  end

end
