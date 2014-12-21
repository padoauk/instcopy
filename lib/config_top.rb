# encoding: utf-8

=begin
 Copyright 2014 padoauk@gmail.com All Rights Reserved
=end

#
# instcopy configuration of the topdir
#
class ConfigTop
  attr_reader :vars, :path, :sub_configs

  def initialize( fname )
    # path to the top configuration file
    @path = nil
    # global var names and their values
    @vars = Hash.new
    # paths of configuration files of subordinate directories
    @sub_configs = []

    if fname
      read_file( fname.to_s )
    end
  end

  def topdir
    File.dirname(@path)
  end

  # read top level configuration file
  def read_file( fname )

    unless File.exists?(fname) then
      raise IOError, "file #{fname} does not exist"
    end
    unless File.readable?(fname) then
      raise IOError, "cannot read #{fname}"
    end

    @path = File.absolute_path(fname)
    $INSTCOPY_TOP_DIR = File.dirname(@path)

    File.open(fname, "r") do |file|
      while line = file.gets
        parse_a_line(line)
      end
    end

  end

  # find configuration files of subordinate directories
  def find_configs( conf_name )
    do_find_configs( File.dirname(@path), conf_name )
  end

  ################################################
  private
  ################################################

  # parse a line of top level configuration file
  def parse_a_line( line )
    # skip comment or null lines
    return if line.match('^#')  || line.match(/^(\s*)$/)

    # scalar
    if /(\s*)(\S+)(\s+)=(\s*)(\S+)(\s*)$/=~ line
      vname = $2
      value = $5
      @vars[vname] = value
      return
    end

    # array
    if /(\s*)(\S+)(\s+)=(\s*)"(.+)"(\s*)$/=~ line || /(\s*)(\S+)(\s+)=(\s*)'(.+)'(\s*)$/=~ line
      vname = $2
      value = $5
      @vars[vname] = value.split(/\s+/)
      return
    end
  end

  # find `appname` configuration files in `dir` and its sub-directories
  def do_find_configs( dir, appname )
    dir = dir.to_s
    appname = appname.to_s
    abs_path = File.absolute_path(dir)

    Dir.entries(abs_path).each do |e|
      next if e == '.' || e == '..'
      tpath = "#{abs_path}/#{e}"
      ttype = File.ftype(tpath)
      if e == appname.to_s &&  ttype == 'file'
        @sub_configs.push("#{abs_path}/#{appname}")
      elsif ttype == 'directory'
        do_find_configs( tpath, appname )
      end
    end
  end

end