require "bldemon/version"
require "rake"
require "ult"

module Bldemon
  extend self
  
  def task( action, caption = "", &block )
    Rake.application.last_description = caption.empty? ? action.to_s : caption
    Rake::Task.define_task action do
      Ult.safety{
        block.call
      }
    end
  end
  
  def cmake( action, *args )
    case action
    when :build
      args = [ "." ] if args.empty?
      Ult.shell( "cmake #{args.join( ' ' )}" )
    when :clean
      Ult.find( [ "CMakeCache.txt", "CMakeFiles", "CMakeScripts", "cmake_install.cmake", "Makefile" ] ).each{|path|
        Ult.remove( path )
      }
    when :rebuild
      cmake( :clean )
      cmake( :build, *args )
    end
  end
  
  def make( action, *args )
    case action
    when :build
      Ult.shell( "make #{args.join( ' ' )}" )
    when :clean
      Ult.shell( "make clean #{args.join( ' ' )}" )
    when :rebuild
      make( :clean )
      make( :build, *args )
    end
  end
  
  def dir( *args, &block )
    Ult.dir( *args ){
      puts "[#{Ult.pwd}]"
      block.call
    }
  end
end
