require 'rdoc/task'

RDOC_FILES = FileList['README.rdoc', 'lib/**/*.rb']

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  rdoc.title = "#{GEM_NAME} #{GEM_VERSION}"
  rdoc.main = 'README.rdoc'
  rdoc.rdoc_dir = 'doc/site/api'
  rdoc.options << "-a" << "-U" << "-D" << "-v"
  rdoc.rdoc_files.include(RDOC_FILES)
end

Rake::RDocTask.new(:ri) do |rdoc|
  rdoc.main = "README.rdoc"
  rdoc.rdoc_dir = "doc/ri"
  rdoc.options << "--ri-system"
  rdoc.rdoc_files.include(RDOC_FILES)
end
