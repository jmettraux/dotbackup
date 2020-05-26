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


if ARGV.empty? || (ARGV & %w[ -b --backup ]).any?

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

elsif (ARGV & %w[ -h --help ]).any?

  p :help

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
  f = last if f == 'last'
  puts "f: #{f}"

  system(
    "tarsnap -xv --keyfile #{KEY} --cachedir #{CACHE} -f #{f}")
end

