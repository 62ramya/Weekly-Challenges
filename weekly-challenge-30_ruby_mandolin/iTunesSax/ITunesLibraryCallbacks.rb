# =ITunesLibraryCallbacks
# SAX callbacks for iTunes library parsing

require 'rubygems'
require 'nokogiri'

class ITunesLibraryCallbacks < Nokogiri::XML::SAX::Document
  attr_accessor :breadcrumb, :track_count

  #takes a filehandler as argument
  #optionally an instance of a subclass of ITunesLibraryWriter
  def initialize( *args )
    @library_callbacks = args[0]

    @track_count  = 0
    @playlist = Hash.new
    @separator    = "/"
    @breadcrumb   = ""
    @top_level_key    = ""
    @last_key    = ""
    @track = Hash.new
    @element_name = ""
    @property_row
    @node_separator = "\n       "
    @track_separator = "\n    "
  end

  #standard callback
  def characters str
    if is_top_level_key
      @top_level_key = str.clone.downcase
      @property_row[:key] = str
    elsif is_track_value
      unless @property_row[:value]
        @property_row[:value] = ""
      end
      @property_row[:value] += str
    elsif is_track_key
      @property_row[:key] = str
    elsif is_playlist_items_value
      @playlist[:items].push( { :key => "Track ID", :type => "integer", :value => str } )
    elsif is_playlist_value
      unless @property_row[:value]
        @property_row[:value] = ""
      end
      @property_row[:value] += str
    elsif is_playlist_key
      @property_row[:key] = str
    elsif is_top_level_value
      unless @property_row[:value]
        @property_row[:value] = ""
      end
      @property_row[:value] += str
    elsif is_track_start
      @track[:key] = str
      @track[:dict] = Array.new
    end
    if ( "key" == @element_name ) &&
      ( 5 == depth )
      @last_key = str.clone.downcase!
    end
  end

  #standard callback
  def start_element element_name, attributes = []
    breadcrumb_add( element_name )
    @element_name = element_name

    if is_track_start
      @track = Hash.new
      @track_count += 1
    elsif is_track_key
      @property_row = Hash.new
    elsif is_track_value
      @property_row[:type] = @element_name
    elsif is_playlist_items_key
    elsif is_playlist_key
      @property_row = Hash.new
    elsif is_playlist_value
      @property_row[:type] = @element_name
    elsif is_playlist_start
      @playlist[:dict] = Array.new
    elsif is_top_level_value
      @property_row[:type] = @element_name
    elsif is_tracks_collection_start
      @property_row = nil
      @library_callbacks.tracks_collection_start
    elsif is_playlists_collection_start
      @property_row = nil
      @library_callbacks.playlists_collection_start
    elsif is_top_level_key
      @property_row = Hash.new
    elsif is_top_level
      @library_callbacks.top_level_start
    elsif element_name == "plist"
      @library_callbacks.library_start
    end
  end

  #standard callback
  def end_element element_name
    if is_track_end
      $stdout.print " ."
      @library_callbacks.track_end @track
    elsif is_track_key
      @track[:dict].push( @property_row )
    elsif is_playlist_items_start
      @playlist[:items] = Array.new
    elsif is_playlist_key
      @playlist[:dict].push( @property_row )
    elsif is_playlist_end
      @library_callbacks.playlist_end @playlist
    elsif is_top_level_value
      unless [ "tracks", "playlists" ].any? { |tlk|
          @top_level_key == tlk
        }
        @library_callbacks.top_level_row @property_row
      end
    elsif is_top_level_key
    elsif is_tracks_collection_end
     @library_callbacks.tracks_collection_end
    elsif is_playlists_collection_end
     @library_callbacks.playlists_collection_end
    elsif is_top_level
      @library_callbacks.top_level_end
    elsif element_name == "plist"
      @library_callbacks.library_end
    end
    breadcrumb_remove
  end

  #breadcrumbs are stores xpath style, i.e. /path/to/node
  def breadcrumb_add element_name
    @breadcrumb = @breadcrumb + @separator + element_name
  end

  #breadcrumbs are stores xpath style, i.e. /path/to/node
  def breadcrumb_remove
    temp = @breadcrumb.split( @separator )
    temp.pop()
    @element_name = temp[-1]
    @breadcrumb = temp.join( @separator )
  end

  #matches the very first dict after plist
  def is_top_level
    return "/plist/dict" == @breadcrumb
  end

  #the key a top level plist property
  def is_top_level_key
    return [
      '/plist/dict/key'
      ].any? { |bc|
        @breadcrumb === bc
      }
  end

  #the value a top level plist property
  def is_top_level_value
    return [
      '/plist/dict/integer',
      '/plist/dict/string',
      '/plist/dict/true',
      '/plist/dict/false',
      '/plist/dict/date'
      ].any? { |bc|
        @breadcrumb === bc
      }
  end

  #main container for tracks
  def is_tracks_collection_start
    return ( 'tracks' == @top_level_key ) &&
      ( "/plist/dict/dict" == @breadcrumb )
  end

  #main container for tracks
  def is_tracks_collection_end
    return ( is_tracks_collection_start ) &&
      ( "dict" == @element_name )
  end

  #the start of a track
  def is_track_start
    return ( 'tracks' == @top_level_key ) &&
      "/plist/dict/dict/key" == @breadcrumb
  end

  #the key for one of the tracks' attributes
  def is_track_key
    return ( 'tracks' == @top_level_key ) &&
      "/plist/dict/dict/dict/key" == @breadcrumb
  end

  #the value for one of the tracks' attributes
  def is_track_value
    return ( 'tracks' == @top_level_key ) && [
      '/plist/dict/dict/dict/integer',
      '/plist/dict/dict/dict/string',
      '/plist/dict/dict/dict/true',
      '/plist/dict/dict/dict/false',
      '/plist/dict/dict/dict/date'
      ].any? { |bc|
        @breadcrumb === bc
      }
  end

  #the key for one of the tracks' attributes
  def is_playlist_key
    return ( 'playlists' == @top_level_key ) &&
      "/plist/dict/array/dict/key" == @breadcrumb
  end

  #the value for one of the tracks' attributes
  def is_playlist_value
    return ( 'playlists' == @top_level_key ) && [
      '/plist/dict/array/dict/integer',
      '/plist/dict/array/dict/string',
      '/plist/dict/array/dict/true',
      '/plist/dict/array/dict/false',
      '/plist/dict/array/dict/date',
      '/plist/dict/array/dict/data'
      ].any? { |bc|
        @breadcrumb === bc
      }
  end

  #a single track with all its attributes
  def is_track_end
    return ( 'tracks' == @top_level_key ) &&
      "/plist/dict/dict/dict" == @breadcrumb
  end

  #main container for playlists
  def is_playlists_collection_start
    return ( 'playlists' == @top_level_key ) &&
      ( "/plist/dict/array" == @breadcrumb )
  end

  #main container for playlists
  def is_playlists_collection_end
    return ( is_playlists_collection_start ) &&
      ( "array" == @element_name )
  end

  #the start of a playlist
  def is_playlist_start
    return ( 'playlists' == @top_level_key ) &&
      "/plist/dict/array/dict" == @breadcrumb
  end

  #the end of a playlist
  def is_playlist_end
    return ( is_playlist_start ) &&
      "dict" == @element_name
  end

  #the start of a playlist
  def is_playlist_items_start
    return ( 'playlist items' == @last_key ) &&
      "/plist/dict/array/dict/key" == @breadcrumb
  end

  #non-important
  def is_playlist_items_key
    return ( 'playlist items' == @last_key ) && [
      '/plist/dict/array/dict/array/dict',
      '/plist/dict/array/dict/array/dict/key'
      ].any? { |bc|
        @breadcrumb === bc
      }
  end

  #non-important
  def is_playlist_items_value
    return ( 'playlist items' == @last_key ) && [
      '/plist/dict/array/dict/array/dict/integer'
      ].any? { |bc|
        @breadcrumb === bc
      }
  end

  #breadcrumbs are stores xpath style, i.e. /path/to/node
  #this methods counts the slashes to determine the dept
  def depth
    @breadcrumb.scan( "/" ).size
  end

  def error error_message
    abort "ERROR: #{error_message}"
  end

  def warning error_message
    puts "WARNING: #{error_message}"
  end
end