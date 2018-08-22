#
# = $File$ : 
#
# $Author$
# $Date$
# $Revision$
#

puts "0 0 2 3 4"
(1..500).each do |i|
  s = (0..4).to_a.select{|x| (i % (x+1)) != 1}
  puts("#{i} #{i} " + s.join(" ")) unless s.empty?
end
