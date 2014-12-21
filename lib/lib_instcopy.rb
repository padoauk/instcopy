# encoding: utf-8

=begin
 Copyright 2014 padoauk@gmail.com All Rights Reserved
=end

require 'config_top'
require 'config_sub'
require 'file_copy'

class Instcopy
  attr_reader :top_dir, :target_app, :dir_invoked

  def initialize
    @@suffix = 'inst'
    @dir_invoked = Dir.pwd
  end

  def conf_file
    "#{target_app}.#{@@suffix}"
  end

  def set_top( args )
    if args.has_key?(:target_app) then
      @target_app = args[:target_app]
    else
      raise ArgumentError, "target-app not defined"
    end

    unless args.has_key?(:top_dir) then
      search_top
      Dir.chdir(@dir_invoked)
    else
      @top_dir = Dir.pwd
    end
  end

  # search top_dir from current directory
  def search_top
    Dir.chdir(".")
    while File.exist?("#{Dir.pwd}/#{@target_app}.#{@@suffix}")
      @top_dir = Dir.pwd.to_s
      Dir.chdir('..')
    end
  end

end