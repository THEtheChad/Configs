#!/usr/bin/env ruby

# USAGE:
#   cat FILES | gref pattern
#   gref path pattern

flags,   argv = ARGV.partition{|arg| arg[0] == ?- and arg[1] != ?- }
options, argv = argv.partition{|arg| arg[0] == ?- and arg[1] == ?- }

case argv.size
when 1
  path    = "."
  pattern = argv.shift
when 2
  path    = argv.shift
  pattern = argv.shift
else
  abort "No!"
end

unless STDIN.tty?
  # read paths from STDIN
  #   find ... | gref pattern
  path        = STDIN.readlines.map{|line| line.split }
  name_filter = []
  prune_dirs  = []
else
  # search all files recursively from 'path'
  #   gref path pattern
  name_filter = %w(*.log .*.swp *.rxml *.xrb *.css *.jpg *.jar *.class)
  prune_dirs  = %w(.svn .hg .git target)
end

args = [path]
args << prune_dirs.map{|dir| ['-name', dir, '-prune', '-o'] }
args << name_filter.map{|name| ['!', '-name', name]}
args << ['-type', 'f',
         '-exec', 'egrep', '-nh', '--color=always',
         flags, pattern, '{}', ';']
args << ['-exec', 'echo', '-e', "=> {}\n", ';'] unless flags.include?('-h')

exec("find", *args.flatten)
