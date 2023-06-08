import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musify/extensions/l10n.dart';
import 'package:musify/extensions/screen_size.dart';
import 'package:musify/main.dart';
import 'package:musify/screens/now_playing_page.dart';
import 'package:musify/services/audio_manager.dart';
import 'package:musify/services/download_manager.dart';
import 'package:musify/services/router_service.dart';
import 'package:musify/services/update_manager.dart';
import 'package:musify/style/app_themes.dart';
import 'package:musify/widgets/custom_animated_bottom_bar.dart';
import 'package:on_audio_query/on_audio_query.dart' hide context;

class Musify extends StatefulWidget {
  @override
  _MusifyState createState() => _MusifyState();
}

ValueNotifier<int> activeTabIndex = ValueNotifier<int>(0);
ValueNotifier<String> activeTab = ValueNotifier<String>(RoutePaths.home);
final _navigatorKey = GlobalKey<NavigatorState>();

class _MusifyState extends State<Musify> {
  @override
  void initState() {
    super.initState();
    if (!isFdroidBuild) {
      unawaited(checkAppUpdates(context));
    }

    unawaited(checkNecessaryPermissions(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          if (_navigatorKey.currentState?.canPop() == true) {
            _navigatorKey.currentState?.pop();
            return false;
          }
          return true;
        },
        child: Navigator(
          key: _navigatorKey,
          initialRoute: RoutePaths.home,
          onGenerateRoute: RouterService.generateRoute,
        ),
      ),
      bottomNavigationBar: getFooter(),
    );
  }

  Widget getFooter() {
    final items = List.generate(
      4,
      (index) {
        final iconData = [
          FluentIcons.home_24_regular,
          FluentIcons.search_24_regular,
          FluentIcons.book_24_regular,
          FluentIcons.more_horizontal_24_regular,
        ][index];

        final title = [
          context.l10n()!.home,
          context.l10n()!.search,
          context.l10n()!.userPlaylists,
          context.l10n()!.more,
        ][index];

        final routeName = [
          RoutePaths.home,
          RoutePaths.search,
          RoutePaths.userPlaylists,
          RoutePaths.more,
        ][index];

        return BottomNavBarItem(
          icon: Icon(iconData),
          title: Text(
            title,
            maxLines: 1,
          ),
          routeName: routeName,
          activeColor: colorScheme.primary,
          inactiveColor: Theme.of(context).hintColor,
        );
      },
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder<SequenceState?>(
          stream: audioPlayer.sequenceStateStream,
          builder: (context, snapshot) {
            final state = snapshot.data;
            if (state?.sequence.isEmpty ?? true) {
              return const SizedBox();
            }
            final metadata = state!.currentSource!.tag;
            return Container(
              height: 75,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 2),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NowPlayingPage(),
                      ),
                    );
                  },
                  child: Row(
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.only(left: 15, right: 15),
                        child: Icon(
                          FluentIcons.arrow_up_24_filled,
                          size: 22,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 7,
                          bottom: 7,
                          right: 15,
                        ),
                        child: metadata.extras['localSongId'] is int
                            ? QueryArtworkWidget(
                                id: metadata.extras['localSongId'] as int,
                                type: ArtworkType.AUDIO,
                                artworkBorder: BorderRadius.circular(8),
                                artworkWidth: 55,
                                artworkHeight: 55,
                                artworkFit: BoxFit.cover,
                                keepOldArtwork: true,
                                nullArtworkWidget: _buildNullArtworkWidget(),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: metadata!.artUri.toString(),
                                  fit: BoxFit.cover,
                                  width: 55,
                                  height: 55,
                                  errorWidget: (context, url, error) =>
                                      _buildNullArtworkWidget(),
                                ),
                              ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            metadata!.title.toString().length > 15
                                ? '${metadata!.title.toString().substring(0, 15)}...'
                                : metadata!.title.toString(),
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            metadata!.artist.toString().length > 15
                                ? '${metadata!.artist.toString().substring(0, 15)}...'
                                : metadata!.artist.toString(),
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 15,
                            ),
                          )
                        ],
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: StreamBuilder<PlayerState>(
                          stream: audioPlayer.playerStateStream,
                          builder: (context, snapshot) {
                            final playerState = snapshot.data;
                            final processingState =
                                playerState?.processingState;
                            final playing = playerState?.playing;
                            if (processingState == ProcessingState.loading ||
                                processingState == ProcessingState.buffering) {
                              return Container(
                                margin: const EdgeInsets.all(8),
                                width: context.screenSize.width * 0.08,
                                height: context.screenSize.width * 0.08,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    colorScheme.primary,
                                  ),
                                ),
                              );
                            } else if (playing != true) {
                              return IconButton(
                                icon: Icon(
                                  FluentIcons.play_12_filled,
                                  color: colorScheme.primary,
                                ),
                                iconSize: 45,
                                onPressed: audioPlayer.play,
                                splashColor: Colors.transparent,
                              );
                            } else if (processingState !=
                                ProcessingState.completed) {
                              return IconButton(
                                icon: Icon(
                                  FluentIcons.pause_12_filled,
                                  color: colorScheme.primary,
                                ),
                                iconSize: 45,
                                onPressed: audioPlayer.pause,
                                splashColor: Colors.transparent,
                              );
                            } else {
                              return IconButton(
                                icon: Icon(
                                  FluentIcons.replay_20_filled,
                                  color: colorScheme.primary,
                                ),
                                iconSize: 45,
                                onPressed: () => audioPlayer.seek(
                                  Duration.zero,
                                  index: audioPlayer.effectiveIndices!.first,
                                ),
                                splashColor: Colors.transparent,
                              );
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        _buildBottomBar(context, items),
      ],
    );
  }

  Widget _buildNullArtworkWidget() => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: colorScheme.secondary,
          ),
          child: const Center(
            child: Icon(
              FluentIcons.music_note_1_24_regular,
              size: 30,
              color: Colors.white,
            ),
          ),
        ),
      );

  Widget _buildBottomBar(BuildContext context, List<BottomNavBarItem> items) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      height: 65,
      child: CustomAnimatedBottomBar(
        backgroundColor: Theme.of(context).bottomAppBarTheme.color,
        selectedIndex: activeTabIndex.value,
        onItemSelected: (index) => setState(() {
          activeTabIndex.value = index;
          _navigatorKey.currentState!.pushNamedAndRemoveUntil(
            activeTab.value,
            ModalRoute.withName(activeTab.value),
          );
        }),
        items: items,
      ),
    );
  }
}
