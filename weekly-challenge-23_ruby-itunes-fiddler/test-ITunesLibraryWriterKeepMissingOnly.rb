require 'rubygems'
require 'flexmock/test_unit'
require 'ITunesLibraryWriterKeepMissingOnly'
require 'test/unit'

class ITunesLibraryWriterKeepMissingOnlyTest < Test::Unit::TestCase

  def setup
    @filehandle = flexmock( "filehandle" )
    @folder = "Music/"
  end

  def test_instantiation
    assert_raise(ArgumentError) { @iTLWInstance = ITunesLibraryWriterKeepMissingOnly.new( @filehandle ) }
  end

  def test_playlist_end
    playlist = {:dict=>[
        {:type=>"string", :value=>"John", :key=>"Name"},
        {:type=>"integer", :value=>2, :key=>"Eyes"}
      ]}
    @filehandle.should_receive( "<<" ).never
    @iTLWInstance = ITunesLibraryWriterKeepMissingOnly.new( @filehandle, @folder )
    @iTLWInstance.playlist_end playlist
  end

  def test_track_exists
    folder_key = "Music Folder"
    folder_value = "file://localhost/Volumes/HD1T/Music/"
    row = { :type=>"string", :value=>folder_value, :key=>folder_key }
    track = { :dict => [
        {:type=>"integer", :value=>2, :key=>"Track ID"},
        {:type=>"string", :value=>"Tonton Du Bled", :key=>"Name"},
        {:type=>"string", :value=> folder_value + "113/Tonton%20Du%20Bled/Tonton%20Du%20Bled.mp3", :key=>"Location"},
      ],
      :key => 2
    }
    @filehandle.should_receive( "<<" ).with( "\n\t<key>Music Folder</key><string>file://localhost/Volumes/HD1T/Music/</string>" ).once
    @iTLWInstance = ITunesLibraryWriterKeepMissingOnly.new( @filehandle, @folder )
    @iTLWInstance.top_level_row row
    @iTLWInstance.track_end track
  end

  def test_track_doesnt_exist
    folder_key = "Music Folder"
    folder_value = "file://localhost/Volumes/HD1T/Music/"
    row = { :type=>"string", :value=>folder_value, :key=>folder_key }
    track = { :dict => [
        {:type=>"integer", :value=>3, :key=>"Track ID"},
        {:type=>"string", :value=>"Tonton Du Bled", :key=>"Name"},
        {:type=>"string", :value=> folder_value + "113/ThisDoesNotExist.mp3", :key=>"Location"},
      ],
      :key => 3
    }
    @filehandle.should_receive( "<<" ).with( "\n\t<key>Music Folder</key><string>file://localhost/Volumes/HD1T/Music/</string>" ).once
    @filehandle.should_receive( "<<" ).with( "\n    <key>3</key>" ).once
    @filehandle.should_receive( "<<" ).with( "\n    <dict>" ).once
    @filehandle.should_receive( "<<" ).with( "\n\t\t\t<key>Track ID</key><integer>3</integer>" ).once
    @filehandle.should_receive( "<<" ).with( "\n\t\t\t<key>Name</key><string>Tonton Du Bled</string>" ).once
    @filehandle.should_receive( "<<" ).with( "\n\t\t\t<key>Location</key><string>file://localhost/Volumes/HD1T/Music/113/ThisDoesNotExist.mp3</string>" ).once
    @filehandle.should_receive( "<<" ).with( "\n    </dict>" ).once
    @iTLWInstance = ITunesLibraryWriterKeepMissingOnly.new( @filehandle, @folder )
    @iTLWInstance.top_level_row row
    @iTLWInstance.track_end track
  end


end