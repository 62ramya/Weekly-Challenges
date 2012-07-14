require 'rubygems'
require 'flexmock/test_unit'
require 'ITunesLibraryWriter'
require 'test/unit'

class ITunesLibraryWriterTest < Test::Unit::TestCase

  def setup
    @filehandle = flexmock( "filehandle" )
  end

  def test_library_start
    @filehandle.should_receive( "<<" ).with( '<plist version="1.0">' )
    @iTLWInstance = ITunesLibraryWriter.new( @filehandle )
    @iTLWInstance.library_start
  end

  def test_library_end
    @filehandle.should_receive( "<<" ).with( "\n</plist>")
    @iTLWInstance = ITunesLibraryWriter.new( @filehandle )
    @iTLWInstance.library_end
  end

  def test_playlist_end
    playlist = {:dict=>[
        {:type=>"string", :value=>"John", :key=>"Name"},
        {:type=>"integer", :value=>2, :key=>"Eyes"}
      ]}
    @filehandle.should_receive( "<<" ).with( "\n    <dict>" )
    @filehandle.should_receive( "<<" ).with( "\n\t\t\t<key>Name</key><string>John</string>" )
    @filehandle.should_receive( "<<" ).with( "\n\t\t\t<key>Eyes</key><integer>2</integer>" )
    @filehandle.should_receive( "<<" ).with( "\n    </dict>" )
    @iTLWInstance = ITunesLibraryWriter.new( @filehandle )
    @iTLWInstance.playlist_end playlist
  end

  def test_track_end
    track = { :dict => [
        {:type=>"integer", :value=>2, :key=>"Track ID"},
        {:type=>"string", :value=>"John", :key=>"Name"},
        {:type=>"string", :value=>"Ski", :key=>"Artist"},
        {:type=>"string", :value=>"Jazzanova: The Remixes, 1997-2000", :key=>"Album"}
      ],
      :key => 2
    }
    @filehandle.should_receive( "<<" ).with( "\n    <key>2</key>" )
    @filehandle.should_receive( "<<" ).with( "\n    <dict>" )
    @filehandle.should_receive( "<<" ).with( "\n\t\t\t<key>Track ID</key><integer>2</integer>" )
    @filehandle.should_receive( "<<" ).with( "\n\t\t\t<key>Name</key><string>John</string>" )
    @filehandle.should_receive( "<<" ).with( "\n\t\t\t<key>Artist</key><string>Ski</string>" )
    @filehandle.should_receive( "<<" ).with( "\n\t\t\t<key>Album</key><string>Jazzanova: The Remixes, 1997-2000</string>" )
    @filehandle.should_receive( "<<" ).with( "\n    </dict>" )
    @iTLWInstance = ITunesLibraryWriter.new( @filehandle )
    @iTLWInstance.track_end track
  end

  def test_top_level_start
    @filehandle.should_receive( "<<" ).with( "\n<dict>" )
    @iTLWInstance = ITunesLibraryWriter.new( @filehandle )
    @iTLWInstance.top_level_start
  end

  def test_top_level_end
    @filehandle.should_receive( "<<" ).with( "\n</dict>" )
    @iTLWInstance = ITunesLibraryWriter.new( @filehandle )
    @iTLWInstance.top_level_end
  end

  def test_tracks_collection_start
    @filehandle.should_receive( "<<" ).with( "\n\t<key>Tracks</key>\n\t<dict>" )
    @iTLWInstance = ITunesLibraryWriter.new( @filehandle )
    @iTLWInstance.tracks_collection_start
  end

  def test_tracks_collection_end
    @filehandle.should_receive( "<<" ).with( "\n\t</dict>" )
    @iTLWInstance = ITunesLibraryWriter.new( @filehandle )
    @iTLWInstance.tracks_collection_end
  end

  def test_playlists_collection_start
    @filehandle.should_receive( "<<" ).with( "\n\t<key>Playlists</key>\n\t<array>" )
    @iTLWInstance = ITunesLibraryWriter.new( @filehandle )
    @iTLWInstance.playlists_collection_start
  end

  def test_playlists_collection_end
    @filehandle.should_receive( "<<" ).with( "\n\t</array>" )
    @iTLWInstance = ITunesLibraryWriter.new( @filehandle )
    @iTLWInstance.playlists_collection_end
  end

  def test_top_level_row
    row = {:type=>"string", :value=>"10.6.3", :key=>"Application Version"}
    @filehandle.should_receive( "<<" ).with( "\n\t<key>Application Version</key><string>10.6.3</string>" )
    @iTLWInstance = ITunesLibraryWriter.new( @filehandle )
    @iTLWInstance.top_level_row row
  end

  def test_meta
    folder_key = "Music Folder"
    folder_value = "file://localhost/Volumes/HD1T/Music/"
    row = { :type=>"string", :value=>folder_value, :key=>folder_key }
    @filehandle.should_receive( "<<" )
    @iTLWInstance = ITunesLibraryWriter.new( @filehandle )
    @iTLWInstance.top_level_row row
    assert_equal( folder_value, @iTLWInstance.meta( folder_key ) )
  end


end