# encoding: utf-8

=begin
 Copyright (c) 2014 padoauk@gmail.com All Rights Reserved
=end

require 'yaml'
require 'pp'

#
# instcopy configuration of the subordinate directories
#
class ConfigSub
  attr_reader :data

  def initialize( fname )
    @data = nil
    @path = nil
    if fname
      read_file( fname.to_s )
    end
  end

  def read_file( fname )
    @path = File.absolute_path(fname)
    y = YAML.load_file(fname)
    @data = trace_hash( y, nil )
  end

  def eval_vars( varval )
    return if @data == nil
    unless varval.instance_of?(Hash)
      return # nothing to do
    end

    varval.each do |var, val|
      replaced = []
      @data.each do |o|
        o.each do |src, dst|
          srcstr = src.to_s
          dststr = dst.to_s

          # no replacement (just push the original)
          unless ( srcstr.match(var) || dststr.match(var) )
            replaced.push( {srcstr => dststr} )
            next
          end

          # for the case val is Array
          v = val.instance_of?(Array) ? val : [val]

          # replace var with val
          v.each do |str|
            d = dststr.gsub(var, str)
            s = srcstr.gsub(var, str)
            replaced.push( {s => d} )
          end
        end
        @data = replaced
      end
    end

  end

  def dir
    return File.dirname(@path)
  end

  def print
    puts @path
    @data.each do |o|
      puts "  #{o.to_s}"
    end
  end

  ################################################
  private
  ################################################

  #
  # trace hash and get the path, of keys, to non-hash object
  #
  # examples
  #     { "opt": {"bin": ["ruby", "gem"]}} => [ {"ruby" : "opt/bin"}, {"gem": "opt/bin"} ]
  #     [ {"k1":"v1"}, { "l1": { "l2": { "l3": "w1" }}}
  #                                => [ {"v1": "k1"}, {"w1": "l1/l2/l3"} ]
  #   a singular specification: nil for node is recognized as "."
  #     { "k1": {"k2" : {"k3" => nil}}} => {".": "k1/k2/k3"}
  #
  def trace_hash( obj, path )
    r = []
    if obj == nil
      r.push({"." => path})
    elsif obj.instance_of?(Array)
      obj.each do |o|
        if o.instance_of?(String)
          r.push({o => path})
        else
          r.push( trace_hash(o, path) )
        end
      end
    elsif obj.instance_of?(Hash)
      obj.each do |k,v|
        if path == nil || path.length == 0
          r.push( trace_hash(v, k) )
        else
          r.push( trace_hash(v, "#{path}/#{k}") )
        end
      end
    end

    return r.flatten
  end


end