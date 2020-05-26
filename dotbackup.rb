#!/usr/bin/env ruby

BD = File.join(Dir.home, '.backup')
HNAME = `hostname -s`.strip
KVER = 'darwin-' + `uname -r`.strip

def bpath(pa); File.join(BD, pa); end

KEY = bpath("#{HNAME}_tarsnap.key")
CACHE = bpath('cache')
TFILE = bpath('targets.txt')

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

