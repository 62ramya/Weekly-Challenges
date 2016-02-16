There are two scripts here, all to do with copying mp3 files around from iTunes playlists.

* itunes_playlist_copy_songs reads an itunes XML playlist, and copies all the files listed from it into a folder
* split_files_into_folders takes a folders full of mp3 (or any files) in subfolders, flattens the directory tree, and copies the files into newly created folders of roughly the same size. For example if you have
```
Music
	Country
		blue eyed girl
	HipHop
		another hit
	Blues
		Acoustic
			down and out
		Electric
			can't take it no more
```
and you call it with
split_files_into_folders -i Music -n 2 -o Some_folder, you'will get

```
Some_folder
	ano blu
		another hit
		blue eyed girl
	can dow
		can't take it no more
		down and out
```

I use this to fill up flashcards with music. It was originally a Weekly Challenge for my blog, but it didn't pan out so there isn't a writeup. The scripts do work and I still use them though.