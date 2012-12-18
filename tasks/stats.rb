desc "Prints lines of code metrics"
task :stats do
  lines, codelines, total_lines, total_codelines = 0, 0, 0, 0

  FileList["lib/keymap/**/*.rb"].each { |file_name|
    next if file_name =~ /vendor/
    f = File.open(file_name)

    while (line = f.gets)
      lines += 1
      next if line =~ /^\s*$/
      next if line =~ /^\s*#/
      codelines += 1
    end
    puts "L: #{sprintf("%4d", lines)}, LOC #{sprintf("%4d", codelines)} | #{file_name}"

    total_lines += lines
    total_codelines += codelines

    lines, codelines = 0, 0
  }

  puts "Total: Lines #{total_lines}, LOC #{total_codelines}"
end
