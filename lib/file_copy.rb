# encoding: utf-8

=begin
 Copyright 2014 padoauk@gmail.com All Rights Reserved
=end

require 'FileUtils'

#
# FileCopy gets definition of {src_file: dest_directory} pairs as list and do copy as defined.
#
class FileCopy
  @@prev_dir = String.new

  def self.copy( list, dir )

    unless @@prev_dir.eql?(dir)
      @@prev_dir = dir

      if $DRY_RUN || $EXEC_VERBOSE
        puts "#{@@prev_dir}"
      end
    end

    if list.instance_of?(Hash)
      self.parse_and_copy(list, dir)
    elsif list.instance_of?(Array)
      list.each do |e|
        self.copy(e, dir)
      end
    end
  end


  #############################################
  private
  #############################################

  #
  # parse the KVs as src and dst and do copy
  #
  def self.parse_and_copy( obj, dir )
    Dir.chdir(dir) if dir


    obj.each do |k,v|
      self.parse(k,v).each do |a|
        r = self.do_copy(a[0],a[1])
        unless r == nil
          STDERR.puts r
        end
      end
    end

  end

  #
  # parse the KVs and returns the result as array of [src,dst]
  #
  def self.parse( k, v )
    if k == nil || v == nil
      return false
    end

    src = k.to_s
    dst = v.to_s

    # dst must be the file name in order to check the existance of directory

    if src.match(/(\s*)(\S+)(\s*)->(\s*)(\S+)(\s*)/)
      src = $2
      (dst.length == 0) ? dst = $5 : dst = "#{dst}/#{$5}"
    else
      dst = "#{dst}/#{src}"
    end

    if src.length == 0 || dst.length == 0
      return false
    end

    r = []
    Dir.glob(src).each do |f|
      r.push([f,dst])
    end
    if r.length == 0
      STDERR.puts "error no such file or directory called #{src}"
    end

    return r
  end


  #
  # do copy
  #
  def self.do_copy( src, dst )

    begin
      unless dst.match(/^\//)
        dst = "#{$INSTCOPY_TOP_DIR}/#{dst}"
      end

      if $DRY_RUN || $EXEC_VERBOSE
        puts "\tcopy #{src} #{dst}"
      end

      unless $DRY_RUN
        dirname = File.dirname(dst)
        FileUtils.mkdir_p(dirname)
        FileUtils.cp(src, dst, :preserve => true )
      end

    rescue => e
      return "error cp #{src} #{dst}"
    end
    return nil
  end

end