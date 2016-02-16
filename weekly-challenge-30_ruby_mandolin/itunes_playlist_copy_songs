#!/usr/bin/env ruby

require "rubygems"
require "optparse"
require "nokogiri"
require_relative "iTunesSax/ITunesLibraryCallbacks"

options = { :cmd => "copy" }
commands = [ "copy", "m4a" ]

script_options = OptionParser.new do |opt|

  #help screen
  opt.banner = "Usage: itunes_copy --input=/path/to/file [OPTIONS]"

  #individual options
  opt.on( "-i", "--input /pth/to/file", "the XML library file (you get it by selecting a playlist, then FILE > Library > Export Playlist)" ) do |o|
    options[:src] = o
  end

  opt.on( "-o", "--output /pth/to/target", "if command needsa target directory or file (for example 'copy'), this will be it") do |o|
    options[:target] = o
  end

  opt.on( "-c", "--command command", "what to do. One of #{commands}. Default #{options[:cmd]}" ) do |o|
    options[:cmd] = o
  end

  opt.on( "-h", "--help", "help" ) do
    puts script_options
    exit(0)
  end

end

#collects args and quits if something wrong
script_options.parse!

if options[:src].nil?
  abort "Missing -i or --input param"
end

if ("copy" === options[:cmd] && options[:target].nil?)
  abort "Missing -o or --output param for copy"
end

if ( !commands.include?( options[:cmd] ) )
  abort "Unknwon command #{options[:cmd]}"
end

case options[:cmd].downcase
when "copy"
  require_relative "iTunesSax/ITunesFileCopier"
  callback = ITunesFileCopier.new( options[:target] )
when "m4a"
  require_relative "iTunesSax/ITunesM4ASpotter"
  callback = ITunesM4ASpotter.new
end

parser = Nokogiri::XML::SAX::Parser.new( ITunesLibraryCallbacks.new( callback ) )
parser.parse_file( options[:src] )