# =ITunesM4ASpotter
# responds to event raised by ITunesLibraryCallbacks
require 'CGI'
require 'FileUtils'

class ITunesM4ASpotter

  #takes a filehandler as argument
  def initialize( *args )
  end

  def to_s
    return ">>>> InunesM4ASpotter"
  end

  #called by ITunesLibraryEvent
  #prints a complete playlist
  def playlist_end playlist
  end

  #called by ITunesLibraryEvent
  #prints a complete track
  def track_end track

    track[:dict].each { |row|
      # puts row
      # FileUtils.cp 'eval.c', 'eval.c.org'
      if (row[:key] == "Location")
        source = CGI.unescape( row[:value] ).gsub( /file:\/\/localhost/, "" )
        if (/m4a$/.match(source))
          puts "M4A: #{source}"
        end
      end
    }
  end

  #called by ITunesLibraryEvent
  #prints the opening plist tag
  def library_start
  end

  #called by ITunesLibraryEvent
  #prints the opening plist tag
  def library_end
  end

  #called by ITunesLibraryEvent
  #prints the opening dict tag
  def top_level_start
  end

  #called by ITunesLibraryEvent
  #prints the closing dict tag
  def top_level_end
  end

  #called by ITunesLibraryEvent
  #prints the opening dict tag for tracks
  def tracks_collection_start
  end

  #called by ITunesLibraryEvent
  #prints the opening dict tag for tracks
  def playlists_collection_start
  end

  #called by ITunesLibraryEvent
  #prints the closing dict tag for tracks
  def tracks_collection_end
  end

  #called by ITunesLibraryEvent
  #prints the closing dict tag for playlists
  def playlists_collection_end
  end

  #called by ITunesLibraryEvent
  #prints the opening dict tag
  def top_level_row row
  end

  #top level keys are saved in a global object. this method returns it
  def meta the_key
    return @top_level[the_key]
  end
end