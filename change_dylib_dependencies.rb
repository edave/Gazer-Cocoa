dylibs = Dir.glob("*.dylib")
dylibs.each do |path|
  name = path.split("/").last
  x = %x[otool -L #{path}]
  lines = x.split("\n")
  lines = lines.map(&:strip)
  op_lines = lines.select{|l| l.include?("opt")}.map{|m| m.split.first}
  op_lines.each do |line|
    lib = line.split("/").last
    %x[install_name_tool -change #{line} @executable_path/../Frameworks/#{lib} #{path}]
  end
end
