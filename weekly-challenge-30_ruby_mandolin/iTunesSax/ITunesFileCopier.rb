# =ITunesFileCopier
# responds to event raised by ITunesLibraryCallbacks
require 'CGI'
require 'FileUtils'

class ITunesFileCopier

  #takes a filehandler as argument
  def initialize( *args )

    case args.size
    when 1
      @target = args[0]
      @target += "/" unless /\/$/.match( @target )
    else
      raise ArgumentError, "This class takes 1 argument."
    end
  end

  def to_s
    return ">>>> ITunesFileCopier"
  end

  #called by ITunesLibraryEvent
  #prints a complete playlist
  def playlist_end playlist
  end

  #called by ITunesLibraryEvent
  #prints a complete track
  def track_end track
    # CGI unescape removes + in between %20 at least
    # possibly elsewhere
    plus = "_____"
    track[:dict].each { |row|
      if (row[:key] == "Location")
        source = row[:value].gsub( /\+/, plus)
        source = CGI.unescape( source )
                    .gsub( /file:\/\//, "" )
                    .gsub( /localhost\//, "" )
                    .gsub( plus, "+" )
        target = @target + File.basename( source ).gsub( /^\d+ +/, "" )
        puts "::::: COPYING #{source}"
        begin
          FileUtils.cp( source, target )
        rescue Exception
          puts "Couldn't copy to #{target}"
          puts "Error #{$!}"
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