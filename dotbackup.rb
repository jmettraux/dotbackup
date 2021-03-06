#!/usr/bin/env ruby

BD = File.join(Dir.home, '.backup')
HNAME = `hostname -s`.strip
KVER = 'darwin-' + `uname -r`.strip

def bpath(pa); File.join(BD, pa); end

KEY = bpath("#{HNAME}_tarsnap.key")
CACHE = bpath('cache')
TFILE = bpath('targets.txt')


def first
  `tarsnap --keyfile #{KEY} --list-archives | sort | head -1`.strip
end
def last
  `tarsnap --keyfile #{KEY} --list-archives | sort | tail -1`.strip
end

def determine_backup_file

  case fa = ARGV.find { |a| a[0, 1] != '-' }
  when nil, 'last' then last
  when 'first' then first
  else fa
  end
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
  puts "[0:0mdotbackup --first"
  puts "[90m  outputs the name of the first backup file (oldest)"
  puts "[0:0mdotbackup --last"
  puts "[90m  outputs the name of the latest backup file (most recent)"
  puts "[0:0mdotbackup --extract [fname]|last|"
  puts "[90m  extracts a given backup file or the latest if 'last' or none"
  puts "[0:0mdotbackup -p / --print-stats"
  puts "[90m  outputs the total vs compressed size stats"
  puts "[0:0m"

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

  f = determine_backup_file

  system(
    "tarsnap -dv --keyfile #{KEY} --cachedir #{CACHE} -f #{f}")

elsif (ARGV & %w[ -t ]).any?

  f = determine_backup_file
  puts "f: #{f}"

  system(
    "tarsnap -tv --keyfile #{KEY} --cachedir #{CACHE} -f #{f}")

elsif (ARGV & %w[ --first ]).any?

  puts(first)

elsif (ARGV & %w[ --last ]).any?

  puts(last)

elsif (ARGV & %w[ --extract ]).any?

  f = determine_backup_file
  puts "f: #{f}"

  system(
    "tarsnap -xv --keyfile #{KEY} --cachedir #{CACHE} -f #{f}")

elsif (ARGV & %w[ -p --print-stats ]).any?

  f = determine_backup_file

  system(
    "tarsnap --keyfile #{KEY} --cachedir #{CACHE} --print-stats -f #{f}")

elsif (ARGV & %w[ --read ]).any?

  f = determine_backup_file
  puts "writing #{f}.tar"

  system(
    "tarsnap -r --keyfile #{KEY} --cachedir #{CACHE} -f #{f} > #{f}.tar")
end

