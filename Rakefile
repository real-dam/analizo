def puts_with_color(msg, color = nil)
  color ||= :yellow
  colors = {
    :yellow => 33,
    :green => 32,
    :red => 31,
  }
  color_code = colors[color] || colors[:yellow]
  if $stdout.isatty
    puts("\033[%s;40m%s\033[m" % [color_code, msg])
  else
    puts(msg)
  end
end

def banner(msg, color = nil)
  puts_with_color('=' * 72, color)
  puts_with_color(msg, color)
  puts_with_color('=' * 72, color)
end

$TEST_TASKS = []
def test_task(name, &block)
  $TEST_TASKS << name
  task(name, &block)
end

desc 'Perl unit tests'
test_task 'test:unit' do
  sh('prove -Ilib t/')
end

desc 'Acceptance tests'
test_task 'test:acceptance' do
  sh 'perl test.pl'
end

task :default do
  unless system('which doxyparse > /dev/null')
    banner("doxyparse program not found, bailing out.\nYou have to install doxyparse to run analizo tests", :red)
    fail
  end
  failed_test_suites = $TEST_TASKS.map { |t| Rake::Task[t] }.map do |task|
    begin
      puts_with_color(task.comment)
      task.invoke
      banner("#{task.comment} passed \\o/", :green)
      nil
    rescue => e
      task.comment
    end
  end.compact
  if !failed_test_suites.empty?
    banner("Failed test suites: #{failed_test_suites.join(', ')}", :red)
    fail
  end
end

desc 'updates MANIFEST from contents of git repository'
task 'manifest' do
  sh('git ls-tree -r --name-only HEAD > MANIFEST')
end

version = File.readlines('analizo').find { |item| item =~ /VERSION =/ }.strip.gsub(/.*VERSION = '(.*)'.*/, '\1')

desc 'prepares a release tarball and a debian package'
task :release => [:authors, :manifest, :check_repo, :check_tag, :check_debian_version, :default] do
  sh "perl Makefile.PL"
  sh "make"
  sh "make test"
  sh "make dist"
  sh "mv analizo-#{version}.tar.gz ../analizo_#{version}.tar.gz"
  sh 'git buildpackage'
  sh "git tag #{version}"
end

NON_GIT_AUTHORS = [
  'Andreas Gustafsson <gson@gson.org>',
  'Luiz Romário Santana Rios <luizromario@gmail.com>',
]

desc 'updates the AUTHORS file'
task :authors do
  File.open("AUTHORS", 'w') do |f|
    f.puts "# This file is autogenerated. Please do NOT send patches that change it."
    f.puts "# See `Rakefile` instead."
    f.puts
  end

  command = NON_GIT_AUTHORS.map { |author| "echo '%s'" % author }.join(' ; ')
  sh "(#{command} ; git log --pretty=format:'%aN <%aE>') | sort | uniq >> AUTHORS"
end

desc 'checks if there are uncommitted changes in the repo'
task :check_repo do
  sh "git status | grep 'nothing to commit'" do |ok, res|
    if !ok
      raise "******** There are uncommited changes in the repository, cannot continue"
    end
  end
end

desc 'checks if there is already a tag for the curren version'
task :check_tag do
  sh "git tag | grep '^#{version}$' >/dev/null" do |ok, res|
    if ok
      raise "******** There is already a tag for version #{version}, cannot continue"
    end
  end
  puts "Not found tag for version #{version}, we can go on."
end

desc 'checks if debian version is in sync with "upstream" version'
task :check_debian_version do
  debian_version = `dpkg-parsechangelog | grep Version | awk '{print $2}'`.strip
  if debian_version != version
    raise "******** Upstream version is #{version}, but Debian version is #{debian_version}."
  end
end
