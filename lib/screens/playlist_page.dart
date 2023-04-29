import 'dart:math';

import 'package:flutter/material.dart';
import 'package:musify/API/musify.dart';
import 'package:musify/extensions/l10n.dart';
import 'package:musify/style/app_themes.dart';
import 'package:musify/utilities/flutter_toast.dart';
import 'package:musify/widgets/playlist_cube.dart';
import 'package:musify/widgets/song_bar.dart';
import 'package:musify/widgets/spinner.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key, required this.playlistId});
  final dynamic playlistId;

  @override
  _PlaylistPageState createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  final _songsList = [];
  dynamic _playlist;

  bool _isLoading = true;
  bool _hasMore = true;
  final _itemsPerPage = 35;
  var _currentPage = 0;
  var _currentLastLoadedId = 0;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    getPlaylistInfoForWidget(widget.playlistId).then(
      (value) => {
        _playlist = value,
        _hasMore = true,
        _loadMore(),
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadMore() {
    _isLoading = true;
    fetch().then((List fetchedList) {
      if (!mounted) return;
      if (fetchedList.isEmpty) {
        setState(() {
          _isLoading = false;
          _hasMore = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _songsList.addAll(fetchedList);
        });
      }
    });
  }

  Future<List> fetch() async {
    final list = [];
    final _count = _playlist['list'].length as int;
    final n = min(_itemsPerPage, _count - _currentPage * _itemsPerPage);
    await Future.delayed(const Duration(seconds: 1), () {
      for (var i = 0; i < n; i++) {
        list.add(_playlist['list'][_currentLastLoadedId]);
        _currentLastLoadedId++;
      }
    });
    _currentPage++;
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n()!.playlist,
        ),
      ),
      body: SingleChildScrollView(
        child: _playlist != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildPlaylistImage(),
                  _buildPlaylistTitle(),
                  _buildPlaylistDescription(),
                  const SizedBox(height: 10),
                  _buildPlayAllButton(),
                  const SizedBox(height: 30),
                  if (_songsList.isNotEmpty)
                    _buildSongList()
                  else
                    const Spinner()
                ],
              )
            : SizedBox(
                height: MediaQuery.of(context).size.height - 100,
                child: const Spinner(),
              ),
      ),
    );
  }

  Widget _buildPlaylistImage() {
    return Card(
      color: Colors.transparent,
      child: PlaylistCube(
        id: _playlist['ytid'],
        image: _playlist['image'],
        title: _playlist['title'],
        onClickOpen: false,
      ),
    );
  }

  Widget _buildPlaylistTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        _playlist['title'].toString(),
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .bodyLarge!
            .copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPlaylistDescription() {
    return Text(
      _playlist['header_desc'].toString(),
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }

  Widget _buildPlayAllButton() {
    return ElevatedButton(
      onPressed: () {
        setActivePlaylist(_playlist);
        showToast(
          context.l10n()!.queueInitText,
        );
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
          colorScheme.primary,
        ),
      ),
      child: Text(
        context.l10n()!.playAll.toUpperCase(),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildSongList() {
    if (_songsList.isNotEmpty)
      return Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: 7),
            itemCount: _hasMore ? _songsList.length + 1 : _songsList.length,
            itemBuilder: (BuildContext context, int index) {
              if (index >= _songsList.length) {
                if (!_isLoading) {
                  _loadMore();
                }
                return const Spinner();
              }
              return SongBar(
                _songsList[index],
                true,
              );
            },
          ),
        ],
      );
    else
      return SizedBox(
        height: MediaQuery.of(context).size.height - 100,
        child: const Spinner(),
      );
  }
}
