import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:musify/API/musify.dart';
import 'package:musify/customWidgets/spinner.dart';
import 'package:musify/services/audio_manager.dart';
import 'package:musify/style/appColors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

String status = 'hidden';

typedef OnError = void Function(Exception exception);

StreamSubscription? positionSubscription;
StreamSubscription? audioPlayerStateSubscription;

Duration? duration;
Duration? position;

bool get isPlaying => buttonNotifier.value == MPlayerState.playing;

bool get isPaused => buttonNotifier.value == MPlayerState.paused;

enum MPlayerState { stopped, playing, paused, loading }

class AudioApp extends StatefulWidget {
  @override
  AudioAppState createState() => AudioAppState();
}

@override
class AudioAppState extends State<AudioApp> {
  @override
  void initState() {
    super.initState();

    positionSubscription = audioPlayer?.positionStream
        .listen((p) => {if (mounted) setState(() => position = p)});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        systemOverlayStyle:
            const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.nowPlaying,
          style: TextStyle(
            color: accent,
            fontSize: 25,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 14.0),
          child: IconButton(
            icon: Icon(
              Icons.keyboard_arrow_down,
              size: 32,
              color: accent,
            ),
            onPressed: () => Navigator.pop(context, false),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: size.height * 0.012),
          child: StreamBuilder<SequenceState?>(
            stream: audioPlayer!.sequenceStateStream,
            builder: (context, snapshot) {
              final state = snapshot.data;
              if (state?.sequence.isEmpty ?? true) {
                return const SizedBox();
              }
              final metadata = state!.currentSource!.tag;
              final songLikeStatus = ValueNotifier<bool>(
                isSongAlreadyLiked(metadata.extras["ytid"]),
              );
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: size.width / 1.2,
                    height: size.width / 1.2,
                    child: CachedNetworkImage(
                      imageUrl: metadata.artUri.toString(),
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          shape: BoxShape.rectangle,
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => Spinner(),
                      errorWidget: (context, url, error) => Container(
                        width: size.width / 1.2,
                        height: size.width / 1.2,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          gradient: LinearGradient(
                            colors: [
                              accent.withAlpha(30),
                              Colors.white.withAlpha(30)
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              MdiIcons.musicNoteOutline,
                              size: size.width / 8,
                              color: accent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 35.0, bottom: 35),
                    child: Column(
                      children: <Widget>[
                        Text(
                          metadata!.title
                              .toString()
                              .split(' (')[0]
                              .split('|')[0]
                              .trim(),
                          textScaleFactor: 2.5,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: accent,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "${metadata!.artist}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: accentLight,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Material(
                    child: _buildPlayer(
                      size,
                      songLikeStatus,
                      metadata.extras["ytid"],
                      metadata,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPlayer(
    size,
    songLikeStatus,
    ytid,
    metadata,
  ) =>
      Container(
        padding: EdgeInsets.only(
          top: size.height * 0.01,
          left: 16,
          right: 16,
          bottom: size.height * 0.03,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (duration != null)
              Slider(
                activeColor: accent,
                inactiveColor: Colors.green[50],
                value: position?.inMilliseconds.toDouble() ?? 0.0,
                onChanged: (double? value) {
                  setState(() {
                    audioPlayer!.seek(
                      Duration(
                        seconds: (value! / 1000).round(),
                      ),
                    );
                    value = value;
                  });
                },
                max: duration!.inMilliseconds.toDouble(),
              ),
            if (position != null) _buildProgressView(),
            Padding(
              padding: EdgeInsets.only(top: size.height * 0.03),
              child: Column(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        if (metadata.extras["ytid"].toString().length != 0)
                          IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              MdiIcons.download,
                              color: Colors.white,
                            ),
                            iconSize: size.width * 0.056,
                            onPressed: () {
                              downloadSong(activeSong);
                            },
                          ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            MdiIcons.shuffle,
                            color:
                                shuffleNotifier.value ? accent : Colors.white,
                          ),
                          iconSize: size.width * 0.056,
                          onPressed: () {
                            changeShuffleStatus();
                          },
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.skip_previous,
                            color: audioPlayer!.hasPrevious
                                ? Colors.white
                                : Colors.grey,
                            size: size.width * 0.1,
                          ),
                          iconSize: size.width * 0.056,
                          onPressed: () {
                            playPrevious();
                          },
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: ValueListenableBuilder<MPlayerState>(
                            valueListenable: buttonNotifier,
                            builder: (_, value, __) {
                              switch (value) {
                                case MPlayerState.loading:
                                  return Container(
                                    margin: const EdgeInsets.all(8.0),
                                    width: size.width * 0.08,
                                    height: size.width * 0.08,
                                    child: Spinner(),
                                  );
                                case MPlayerState.paused:
                                  return IconButton(
                                    icon: const Icon(MdiIcons.play),
                                    iconSize: size.width * 0.1,
                                    onPressed: () {
                                      play();
                                    },
                                  );
                                case MPlayerState.playing:
                                  return IconButton(
                                    icon: const Icon(MdiIcons.pause),
                                    iconSize: size.width * 0.1,
                                    onPressed: () {
                                      pause();
                                    },
                                  );
                                case MPlayerState.stopped:
                                  return IconButton(
                                    icon: const Icon(MdiIcons.play),
                                    iconSize: size.width * 0.08,
                                    onPressed: () {
                                      play();
                                    },
                                  );
                              }
                            },
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.skip_next,
                            color: audioPlayer!.hasNext
                                ? Colors.white
                                : Colors.grey,
                            size: size.width * 0.1,
                          ),
                          iconSize: size.width * 0.08,
                          onPressed: () {
                            playNext();
                          },
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            MdiIcons.repeat,
                            color: repeatNotifier.value ? accent : Colors.white,
                          ),
                          iconSize: size.width * 0.056,
                          onPressed: () {
                            changeLoopStatus();
                          },
                        ),
                        if (metadata.extras["ytid"].toString().length != 0)
                          ValueListenableBuilder<bool>(
                            valueListenable: songLikeStatus,
                            builder: (_, value, __) {
                              if (value == true) {
                                return IconButton(
                                  color: accent,
                                  icon: const Icon(MdiIcons.star),
                                  iconSize: size.width * 0.056,
                                  onPressed: () => {
                                    removeUserLikedSong(ytid),
                                    songLikeStatus.value = false
                                  },
                                );
                              } else {
                                return IconButton(
                                  color: accent,
                                  icon: const Icon(MdiIcons.starOutline),
                                  iconSize: size.width * 0.056,
                                  onPressed: () => {
                                    addUserLikedSong(ytid),
                                    songLikeStatus.value = true
                                  },
                                );
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                  if (metadata.extras["ytid"].toString().length != 0)
                    Padding(
                      padding: EdgeInsets.only(top: size.height * 0.047),
                      child: Builder(
                        builder: (context) {
                          return TextButton(
                            onPressed: () {
                              getSongLyrics(
                                metadata.artist.toString(),
                                metadata.title.toString(),
                              );

                              showBottomSheet(
                                context: context,
                                builder: (context) => Container(
                                  decoration: const BoxDecoration(
                                    color: Color(0xff212c31),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(18.0),
                                      topRight: Radius.circular(18.0),
                                    ),
                                  ),
                                  height: size.height / 2.14,
                                  child: Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: size.height * 0.012,
                                        ),
                                        child: Row(
                                          children: <Widget>[
                                            IconButton(
                                              icon: Icon(
                                                Icons.arrow_back_ios,
                                                color: accent,
                                                size: 20,
                                              ),
                                              onPressed: () =>
                                                  {Navigator.pop(context)},
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 42.0,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .lyrics,
                                                    style: TextStyle(
                                                      color: accent,
                                                      fontSize: 30,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ValueListenableBuilder<String>(
                                          valueListenable: lyrics,
                                          builder: (_, value, __) {
                                            if (value != "null" &&
                                                value != "not found")
                                              return Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(6.0),
                                                  child: Center(
                                                    child:
                                                        SingleChildScrollView(
                                                      child: Text(
                                                        value,
                                                        style: TextStyle(
                                                          fontSize: 16.0,
                                                          color: accentLight,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            else if (value == "null")
                                              return SizedBox(child: Spinner());
                                            else
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 120.0,
                                                ),
                                                child: Center(
                                                  child: Container(
                                                    child: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .lyricsNotAvailable,
                                                      style: TextStyle(
                                                        color: accentLight,
                                                        fontSize: 25,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                          })
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              AppLocalizations.of(context)!.lyrics,
                              style: TextStyle(color: accent),
                            ),
                          );
                        },
                      ),
                    )
                ],
              ),
            ),
          ],
        ),
      );

  Row _buildProgressView() => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            position != null
                ? "$positionText ".replaceFirst("0:0", "0")
                : duration != null
                    ? durationText
                    : '',
            style: const TextStyle(fontSize: 18.0, color: Colors.white),
          ),
          const Spacer(),
          Text(
            position != null
                ? "$durationText".replaceAll("0:", "")
                : duration != null
                    ? durationText
                    : '',
            style: const TextStyle(fontSize: 18.0, color: Colors.white),
          )
        ],
      );
}
