# =ITunesLibraryWriterKeepMissingOnly
# keeps only the files which are not found in @folder

require 'ITunesLibraryWriter'
require 'uri'

class ITunesLibraryWriterKeepMissingOnly < ITunesLibraryWriter

  #takes a filehandler as argument
  def initialize( *args )
    case args.size
    when 2
      @filehandle = args[0]
      @folder     = args[1]
    else
      raise ArgumentError, "This class takes 2 argument."
    end
    @node_separator = "\n       "
    @track_separator = "\n    "
    @top_level = Hash.new
  end

  #called by ITunesLibraryEvent
  #doesn't write playlists
  def playlist_end playlist
  end

  #called by ITunesLibraryEvent
  #prints a complete track
  def track_end track
    unless File.file?( extract_pth( track[:dict], "Location" ) )
      super track
    end
  end

  def extract_pth the_array, the_key
    the_array.each { |tuple|
      if the_key == tuple[:key]
        str =  URI.unescape( tuple[:value] )
        return @folder + str[meta( "Music Folder" ).size .. str.size]
      end
    }
    return nil
  end

end
