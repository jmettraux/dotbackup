#!/usr/bin/env ruby

BD = File.join(Dir.home, '.backup')
HNAME = `hostname -s`.strip
KVER = 'darwin-' + `uname -r`.strip

def bpath(pa); File.join(BD, pa); end

KEY = bpath("#{HNAME}_tarsnap.key")
CACHE = bpath('cache')
TFILE = bpath('targets.txt')


def last
  `tarsnap --keyfile #{KEY} --list-archives | sort | tail -1`.strip
end


if (ARGV & %w[ -h --help ]).any?

  puts
  puts "[0:0mdotbackup -b / --backup"
  puts "[90m  backs up the files and directories listed in #{TFILE}"
  puts "[0:0mdotbackup -l / --list"
  puts "[90m  lists the backup files, latest last"
  puts "[0:0mdotbackup --delete {fname}"
  puts "[90m  deletes a backup file"
  puts "[0:0mdotbackup -t {fname}|last"
  puts "[90m  lists the content of a backup file (or of the latest if 'last')"
  puts "[0:0mdotbackup --last"
  puts "[90m  outputs the name of the latest backup file"
  puts "[0:0mdotbackup --extract [fname]|last|"
  puts "[90m  extracts a given backup file or the latest if 'last' or none"
  puts ""

elsif ARGV.empty? || (ARGV & %w[ -b --backup ]).any?

  unless File.exists?(TFILE)
    puts "#{TFILE} not present, nothing to backup"
    exit 1
  end

  targets = File.readlines(TFILE)
    .map(&:strip)
    .select { |l| l.size > 0 && l[0, 1] != '#' }
    .join(' ')

  system(
    "tarsnap -c --keyfile #{KEY} --cachedir #{CACHE} " +
      "-f #{HNAME}-#{KVER}-#{Time.now.strftime('%Y%m%d_%H%M%S')} " +
      targets,
    chdir: Dir.home)

elsif (ARGV & %w[ -l --list ]).any?

  system(
    "tarsnap --keyfile #{KEY} --list-archives" +
    " | sort")

elsif (ARGV & %w[ --delete ]).any?

  f = ARGV.find { |a| a[0, 1] != '-' }

  system(
    "tarsnap -d --keyfile #{KEY} --cachedir #{CACHE} -f #{f}")

elsif (ARGV & %w[ -t ]).any?

  f = ARGV.find { |a| a[0, 1] != '-' }
  f = last if f == 'last'
  puts "f: #{f}"

  system(
    "tarsnap -tv --keyfile #{KEY} --cachedir #{CACHE} -f #{f}")

elsif (ARGV & %w[ --last ]).any?

  puts(last)

elsif (ARGV & %w[ --extract ]).any?

  f = ARGV.find { |a| a[0, 1] != '-' }
  f = last if f == nil || f == 'last'
  puts "f: #{f}"

  system(
    "tarsnap -xv --keyfile #{KEY} --cachedir #{CACHE} -f #{f}")
end

