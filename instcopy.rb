#!/usr/bin/env ruby
# encoding: utf-8

=begin
 Copyright 2014 padoauk@gmail.com All Rights Reserved
=end

#
# instcopy main
#

require 'optparse'

require 'lib_instcopy'

def print_help
  puts "usage: instcopy [-v || --verbose] [-t || --top top_dir] [-s || --start startdir] [-n || --dry-run] [-c || --current-only ] target-app"
end

def cmdline
  args = {}
  OptionParser.new do |parser|
    parser.on('-h', '--help') { args[:help] = true }
    parser.on('-v', '--verbose') { $EXEC_VERBOSE = true }
    parser.on('-n', '--dry-run') { $DRY_RUN = true }
    parser.on('-c', '--current-only') { args[:current_only] = true }
    parser.on('-t VALUE', '--top VALUE', 'top_directory') { |v| args[:top_dir] = v }
    parser.on('-s VALUE', '--start VALUE', 'top_directory') { |v| args[:start_dir] = v }
    parser.on('VALUE') { |v|  }
    parser.permute!(ARGV)
  end

  args[:target_app] = ARGV[0]
  args
end

current_dir = Dir.pwd

instcopy = Instcopy.new

begin
  args = cmdline
rescue => ex
  puts ex.to_s
  print_help
  exit 0
end

if args.has_key?(:help) && args[:help] == true then
  print_help
  exit 1
end

instcopy.set_top(args)

conf_top = ConfigTop.new("#{instcopy.top_dir}/#{instcopy.conf_file}")
conf_top.find_configs(instcopy.conf_file)
conf_top.sub_configs.each do |path|
  if (! args[:current_only]) || File.dirname(path).eql?(current_dir)
    conf_sub = ConfigSub.new(path)
    conf_sub.eval_vars(conf_top.vars)
    FileCopy.copy(conf_sub.data, conf_sub.dir)
  end
end


