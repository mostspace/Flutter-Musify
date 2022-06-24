import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:musify/helper/formatter.dart';
import 'package:musify/helper/mediaitem.dart';
import 'package:musify/services/audio_handler.dart';
import 'package:musify/services/audio_manager.dart';
import 'package:musify/services/data_manager.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

final yt = YoutubeExplode();
final OnAudioQuery _audioQuery = OnAudioQuery();

List ytplaylists = [];

List searchedList = [];
List playlists = [];
List userPlaylists = [];
List userLikedSongsList = [];
List suggestedPlaylists = [];
List<SongModel> localSongs = [];

final lyrics = ValueNotifier<String>("null");
String _lastLyricsUrl = "";

dynamic activeSong;

int? id = 0;

List activePlaylist = [];

Future<List> fetchSongsList(String searchQuery) async {
  final List list = await yt.search.search(searchQuery);
  searchedList = [];
  for (var s in list) {
    searchedList.add(
      returnSongLayout(
        0,
        s.id.toString(),
        formatSongTitle(s.title.split('-')[s.title.split('-').length - 1]),
        s.thumbnails.standardResUrl,
        s.thumbnails.lowResUrl,
        s.thumbnails.maxResUrl,
        s.title.split('-')[0],
      ),
    );
  }
  return searchedList;
}

Future get10Music(playlistId) async {
  var newSongs = [];
  var index = 0;
  await for (var song in yt.playlists.getVideos(playlistId).take(10)) {
    newSongs.add(
      returnSongLayout(
        index,
        song.id.toString(),
        formatSongTitle(
          song.title.split('-')[song.title.split('-').length - 1],
        ),
        song.thumbnails.standardResUrl,
        song.thumbnails.lowResUrl,
        song.thumbnails.maxResUrl,
        song.title.split('-')[0],
      ),
    );
    index += 1;
  }

  return newSongs;
}

Future<List<dynamic>> getUserPlaylists() async {
  var playlistsByUser = [];
  for (final playlistID in userPlaylists) {
    final plist = await yt.playlists.get(playlistID);
    playlistsByUser.add({
      "ytid": plist.id,
      "title": plist.title,
      "subtitle": "Just Updated",
      "header_desc": plist.description.length < 120
          ? plist.description
          : plist.description.substring(0, 120),
      "type": "playlist",
      "image": "",
      "list": []
    });
  }
  return playlistsByUser;
}

addUserPlaylist(String playlistId) {
  userPlaylists.add(playlistId);
  addOrUpdateData("user", "playlists", userPlaylists);
}

removeUserPlaylist(String playlistId) {
  userPlaylists.remove(playlistId.toString());
  addOrUpdateData("user", "playlists", userPlaylists);
}

addUserLikedSong(songId) async {
  userLikedSongsList
      .add(await getSongDetails(userLikedSongsList.length, songId));
  addOrUpdateData("user", "likedSongs", userLikedSongsList);
}

removeUserLikedSong(songId) {
  userLikedSongsList.removeWhere((song) => song["ytid"] == songId);
  addOrUpdateData("user", "likedSongs", userLikedSongsList);
}

bool isSongAlreadyLiked(songId) {
  return userLikedSongsList.where((song) => song["ytid"] == songId).isNotEmpty;
}

Future<List> getPlaylists([int? playlistsNum]) async {
  if (playlists.isEmpty) {
    final localplaylists =
        json.decode(await rootBundle.loadString('assets/db/playlists.db.json'));
    playlists = localplaylists;
  }

  if (playlistsNum != null) {
    if (suggestedPlaylists.isEmpty) {
      suggestedPlaylists =
          (playlists.toList()..shuffle()).take(playlistsNum).toList();
    }
    return suggestedPlaylists;
  } else {
    return playlists;
  }
}

Future getSongsFromPlaylist(playlistid) async {
  var playlistSongs = [];
  var index = 0;
  await for (final song in yt.playlists.getVideos(playlistid)) {
    playlistSongs.add(
      returnSongLayout(
        index,
        song.id.toString(),
        formatSongTitle(
          song.title.split('-')[song.title.split('-').length - 1],
        ),
        song.thumbnails.standardResUrl,
        song.thumbnails.lowResUrl,
        song.thumbnails.maxResUrl,
        song.title.split('-')[0],
      ),
    );
    index += 1;
  }

  return playlistSongs;
}

setActivePlaylist(List plist) async {
  List<MediaItem> activePlaylist = [];

  if (plist is List<SongModel>) {
    for (var song in plist) {
      activePlaylist.add(songModelToMediaItem(song, song.data.toString()));
    }
  } else {
    for (var i = 0; i < plist.length && i < 20; i++) {
      final songUrl = await getSongUrl(plist[i]["ytid"]);
      activePlaylist.add(mapToMediaItem(plist[i], songUrl));
    }
  }

  MyAudioHandler().addQueueItems(activePlaylist);

  play();
}

Future getPlaylistInfoForWidget(dynamic id) async {
  var searchPlaylist = playlists.where((list) => list["ytid"] == id).toList();

  if (searchPlaylist.isEmpty) {
    final usPlaylists = await getUserPlaylists();
    searchPlaylist = usPlaylists.where((list) => list["ytid"] == id).toList();
  }

  var playlist = searchPlaylist[0];

  if (playlist["list"].length == 0) {
    searchPlaylist[searchPlaylist.indexOf(playlist)]["list"] =
        await getSongsFromPlaylist(playlist["ytid"]);
  }

  return playlist;
}

Future getSongUrl(dynamic songId) async {
  final manifest = await yt.videos.streamsClient.getManifest(songId);
  return manifest.audioOnly.withHighestBitrate().url.toString();
}

Future getSongStream(dynamic songId) async {
  final manifest = await yt.videos.streamsClient.getManifest(songId);
  return manifest.audioOnly.withHighestBitrate();
}

Future getSongDetails(dynamic songIndex, dynamic songId) async {
  final song = await yt.videos.get(songId);
  return returnSongLayout(
    songIndex,
    song.id.toString(),
    formatSongTitle(song.title.split('-')[song.title.split('-').length - 1]),
    song.thumbnails.standardResUrl,
    song.thumbnails.lowResUrl,
    song.thumbnails.maxResUrl,
    song.title.split('-')[0],
  );
}

getLocalSongs() async {
  // DEFAULT:
  // SongSortType.TITLE,
  // OrderType.ASC_OR_SMALLER,
  // UriType.EXTERNAL,
  if (await Permission.storage.request().isGranted) {
    localSongs = await _audioQuery.querySongs();
  }
  return localSongs;
}

Future getSongLyrics(String artist, String title) async {
  if (_lastLyricsUrl !=
      'https://api.lyrics.ovh/v1/$artist/${title.split(" (")[0].split("|")[0].trim()}') {
    lyrics.value = "null";
    _lastLyricsUrl =
        'https://api.lyrics.ovh/v1/$artist/${title.split(" (")[0].split("|")[0].trim()}';
    try {
      final lyricsApiRes = await DefaultCacheManager().getSingleFile(
        _lastLyricsUrl,
        headers: {"Accept": "application/json"},
      );
      final lyricsResponse =
          await json.decode(await lyricsApiRes.readAsString());
      lyrics.value = lyricsResponse['lyrics'].toString();
    } catch (e) {
      lyrics.value = "not found";
      debugPrint(e.toString());
    }
  }
}
