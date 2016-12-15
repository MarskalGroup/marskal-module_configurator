require 'yard'
require 'rdoc/task'

YARD::Rake::YardocTask.new do |yard|
  yard.options = ['-odoc/yard'] # optional

  yard.files   = ['lib/**/*.rb', '-', '*.md']   # 'make sure that '-'' element is in there or it doesnt process the .md files properly
  # yard.options = ['--any', '--extra', '--opts'] # optional
  # yard.stats_options = ['--list-undoc']         # optional
end

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = 'doc/rdoc'
  # rdoc.options = "-x 'stash' -x 'test' -x 'notes' -x 'bin' -x 'Gemfile' -m 'README.md'"
  rdoc.main = "README.md"
  rdoc.rdoc_files.include('test/support_files/**/*.rb', "*.md", "lib/**/*.rb", 'Gemfile.lock')
end

namespace 'marskal' do
  namespace 'rdoc' do
    desc 'Erases /docs folder and Generates docs in all the available formats'
    task :generate_all_docs do
      FileUtils.remove_dir "doc", true
      l_formats = [{ task: 'rdoc', format: 'default RDoc'},
                   { task: 'yard', format: 'Yard'}
      ]
      l_formats.each_with_index do |l_format, l_index|
        Rake::Task[l_format[:task]].invoke
        puts "\nCompleted #{l_index + 1} of #{l_formats.length}: Docs Generated in #{l_format[:format]}"
      end
    end
  end
end
