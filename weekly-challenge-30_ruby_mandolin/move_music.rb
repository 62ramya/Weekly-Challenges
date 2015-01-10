#!/usr/bin/env ruby


# A script that will pretend to resize a number of images
require 'optparse'
require 'iTunesSaxDocument'

# This hash will hold all of the options
# parsed from the command-line by
# OptionParser.
options = {}

optparse = OptionParser.new do|opts|
  opts.banner = "Usage: move_music.rb.rb [options] -s FILE -t DIR"

  # Define the options, and what they do
  options[:verbose] = false
  opts.on( '-v', '--verbose', 'Output more information' ) do
    options[:verbose] = true
  end

  options[:quiet] = false
  opts.on( '-q', '--quiet', 'Output no information' ) do
    options[:quiet] = true
  end

  options[:source] = nil
  opts.on( '-s', '--source FILE', 'Loads iTunes playlist from FILE' ) do |file|
    options[:source] = file
  end

  options[:target] = nil
  opts.on( '-t', '--target DIR', 'Copies files to DIR' ) do |dir|
    options[:target] = dir
  end

  # This displays the help screen, all programs are
  # assumed to have this option.
  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end

# Parse the command-line. Remember there are two forms
# of the parse method. The 'parse' method simply parses
# ARGV, while the 'parse!' method parses ARGV and removes
# any options found there, as well as any parameters for
# the options. What's left is the list of files to resize.
optparse.parse!

if options[:source].nil?
  abort 'No source iTunes playlist file defined - it should be passed as -s FILE'
end

if options[:target].nil?
  abort 'No target directory defined - it should be passed as -t DIR'
end



unless options[:quiet]; puts "Done" end