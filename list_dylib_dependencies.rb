dylibs = Dir.glob("*.dylib")
dependencies = []
dylibs.each do |path|
  name = path.split("/").last
  x = %x[otool -L #{path}]
  lines = x.split("\n")
  lines = lines.map(&:strip)
  op_lines = lines.select{|l| l.include?("opt")}.map{|m| m.split.first}
  dependencies << op_lines
end

dependencies = dependencies.flatten.uniq.select{|l| !dylibs.include?(l.split("/").last)}.sort

dependencies.each do |line|
  puts line
end