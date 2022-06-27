import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:musify/helper/version.dart';
import 'package:musify/main.dart';
import 'package:musify/services/audio_manager.dart';
import 'package:musify/services/data_manager.dart';
import 'package:musify/style/appColors.dart';
import 'package:musify/ui/aboutPage.dart';
import 'package:musify/ui/userLikedSongsPage.dart';
import 'package:musify/ui/userPlaylistsPage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        systemOverlayStyle:
            const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.settings,
          style: TextStyle(
            color: accent,
            fontSize: 25,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(child: SettingsCards()),
    );
  }
}

class SettingsCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 6),
          child: Card(
            color: bgLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 2.3,
            child: ListTile(
              leading: Icon(MdiIcons.shapeOutline, color: accent),
              title: Text(
                AppLocalizations.of(context)!.accentColor,
                style: TextStyle(color: accent),
              ),
              onTap: () {
                showModalBottomSheet(
                  isDismissible: true,
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (BuildContext context) {
                    final List<int> colors = [
                      0xFFFFCDD2,
                      0xFFF8BBD0,
                      0xFFE1BEE7,
                      0xFFD1C4E9,
                      0xFFC5CAE9,
                      0xFF8C9EFF,
                      0xFFBBDEFB,
                      0xFF82B1FF,
                      0xFFB3E5FC,
                      0xFF80D8FF,
                      0xFFB2EBF2,
                      0xFF84FFFF,
                      0xFFB2DFDB,
                      0xFFA7FFEB,
                      0xFFC8E6C9,
                      0xFFACE1AF,
                      0xFFB9F6CA,
                      0xFFDCEDC8,
                      0xFFCCFF90,
                      0xFFF0F4C3,
                      0xFFF4FF81,
                      0xFFFFF9C4,
                      0xFFFFFF8D,
                      0xFFFFECB3,
                      0xFFFFE57F,
                      0xFFFFE0B2,
                      0xFFFFD180,
                      0xFFFFCCBC,
                      0xFFFF9E80,
                      0xFFFD5C63,
                      0xFFFFFFFF
                    ];
                    return Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: bgColor,
                          border: Border.all(
                            color: accent,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        width:
                            MediaQuery.of(context).copyWith().size.width * 0.90,
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                          ),
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: colors.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                top: 15.0,
                                bottom: 15.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  if (colors.length - 1 > index)
                                    GestureDetector(
                                      onTap: () {
                                        addOrUpdateData(
                                          "settings",
                                          "accentColor",
                                          colors[index],
                                        );
                                        accent = Color(colors[index]);
                                        Fluttertoast.showToast(
                                          backgroundColor: accent,
                                          textColor: Colors.white,
                                          msg: AppLocalizations.of(context)!
                                              .accentChangeMsg,
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          fontSize: 14.0,
                                        );
                                        Navigator.pop(context);
                                      },
                                      child: Material(
                                        elevation: 4.0,
                                        shape: const CircleBorder(),
                                        child: CircleAvatar(
                                          radius: 25,
                                          backgroundColor: Color(
                                            colors[index],
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    const SizedBox.shrink()
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 6),
          child: Card(
            color: bgLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 2.3,
            child: ListTile(
              leading: Icon(MdiIcons.translate, color: accent),
              title: Text(
                AppLocalizations.of(context)!.language,
                style: TextStyle(color: accent),
              ),
              onTap: () {
                showModalBottomSheet(
                  isDismissible: true,
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (BuildContext context) {
                    final Map<String, String> codes = {
                      'English': 'en',
                      'Georgian': 'ka',
                      'Chinese': 'zh',
                      'Dutch': 'nl',
                      'German': 'de',
                      'Indonesian': 'id',
                      'Italian': 'it',
                      'Polish': 'pl',
                      'Portuguese': 'pt',
                      'Spanish': 'es',
                      'Turkish': 'tr',
                      'Ukrainian': 'uk',
                    };

                    final List availableLanguages = [
                      "English",
                      "Georgian",
                      "Chinese",
                      "Dutch",
                      "German",
                      "Indonesian",
                      "Italian",
                      "Polish",
                      "Portuguese",
                      "Spanish",
                      "Turkish",
                      "Ukrainian",
                    ];
                    return Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: bgColor,
                          border: Border.all(
                            color: accent,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        width:
                            MediaQuery.of(context).copyWith().size.width * 0.90,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: availableLanguages.length,
                          itemBuilder: (context, index) {
                            return Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Card(
                                    color: bgLight,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    elevation: 2.3,
                                    child: ListTile(
                                      title: Text(
                                        availableLanguages[index],
                                        style: TextStyle(color: accent),
                                      ),
                                      onTap: () {
                                        addOrUpdateData("settings", "language",
                                            availableLanguages[index]);
                                        MyApp.setLocale(
                                            context,
                                            Locale(codes[
                                                availableLanguages[index]]!));

                                        Fluttertoast.showToast(
                                          backgroundColor: accent,
                                          textColor: Colors.white,
                                          msg: AppLocalizations.of(context)!
                                              .languageMsg,
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          fontSize: 14.0,
                                        );
                                        Navigator.pop(context);
                                      },
                                    )));
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 6),
          child: Card(
            color: bgLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 2.3,
            child: ListTile(
              leading: Icon(MdiIcons.broom, color: accent),
              title: Text(
                AppLocalizations.of(context)!.clearCache,
                style: TextStyle(color: accent),
              ),
              onTap: () {
                clearCache();
                Fluttertoast.showToast(
                  backgroundColor: accent,
                  textColor: Colors.white,
                  msg: "${AppLocalizations.of(context)!.cacheMsg}!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  fontSize: 14.0,
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 6),
          child: Card(
            color: bgLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 2.3,
            child: ListTile(
              leading: Icon(MdiIcons.account, color: accent),
              title: Text(
                AppLocalizations.of(context)!.userPlaylists,
                style: TextStyle(color: accent),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserPlaylistsPage(),
                  ),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 6),
          child: Card(
            color: bgLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 2.3,
            child: ListTile(
              leading: Icon(MdiIcons.star, color: accent),
              title: Text(
                AppLocalizations.of(context)!.userLikedSongs,
                style: TextStyle(color: accent),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserLikedSongs()),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 6),
          child: Card(
            color: bgLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 2.3,
            child: ListTile(
              leading: Icon(MdiIcons.cloudUpload, color: accent),
              title: Text(
                AppLocalizations.of(context)!.backupUserData,
                style: TextStyle(color: accent),
              ),
              onTap: () {
                backupData().then(
                  (value) => Fluttertoast.showToast(
                    backgroundColor: accent,
                    textColor: Colors.white,
                    msg: value,
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    fontSize: 14.0,
                  ),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 6),
          child: Card(
            color: bgLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 2.3,
            child: ListTile(
              leading: Icon(MdiIcons.cloudDownload, color: accent),
              title: Text(
                AppLocalizations.of(context)!.restoreUserData,
                style: TextStyle(color: accent),
              ),
              onTap: () {
                restoreData().then((value) => Fluttertoast.showToast(
                      backgroundColor: accent,
                      textColor: Colors.white,
                      msg: value,
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      fontSize: 14.0,
                    ));
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 6),
          child: Card(
            color: bgLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 2.3,
            child: ListTile(
              leading: Icon(MdiIcons.download, color: accent),
              title: Text(
                AppLocalizations.of(context)!.downloadAppUpdate,
                style: TextStyle(color: accent),
              ),
              onTap: () {
                checkAppUpdates().then(
                  (available) => {
                    if (available == true)
                      {
                        Fluttertoast.showToast(
                          msg:
                              "${AppLocalizations.of(context)!.appUpdateAvailableAndDownloading}!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: accent,
                          textColor: Colors.white,
                          fontSize: 14.0,
                        ),
                        downloadAppUpdates()
                      }
                    else
                      {
                        Fluttertoast.showToast(
                          msg:
                              "${AppLocalizations.of(context)!.appUpdateIsNotAvailable}!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: accent,
                          textColor: Colors.white,
                          fontSize: 14.0,
                        )
                      }
                  },
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 6),
          child: Card(
            color: bgLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 2.3,
            child: ListTile(
              leading: Icon(MdiIcons.file, color: accent),
              title: Text(
                AppLocalizations.of(context)!.audioFileType,
                style: TextStyle(color: accent),
              ),
              onTap: () {
                showModalBottomSheet(
                  isDismissible: true,
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (BuildContext context) {
                    final availableFileTypes = ["mp3", "flac"];
                    return Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: bgColor,
                          border: Border.all(
                            color: accent,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        width:
                            MediaQuery.of(context).copyWith().size.width * 0.90,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: availableFileTypes.length,
                          itemBuilder: (context, index) {
                            return Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Card(
                                    color: bgLight,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    elevation: 2.3,
                                    child: ListTile(
                                      title: Text(
                                        availableFileTypes[index],
                                        style: TextStyle(color: accent),
                                      ),
                                      onTap: () {
                                        addOrUpdateData(
                                            "settings",
                                            "audioFileType",
                                            availableFileTypes[index]);
                                        prefferedFileExtension.value =
                                            availableFileTypes[index];

                                        Fluttertoast.showToast(
                                          backgroundColor: accent,
                                          textColor: Colors.white,
                                          msg: AppLocalizations.of(context)!
                                              .audioFileTypeMsg,
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          fontSize: 14.0,
                                        );
                                        Navigator.pop(context);
                                      },
                                    )));
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 6),
          child: Card(
            color: bgLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 2.3,
            child: ListTile(
              leading: Icon(MdiIcons.information, color: accent),
              title: Text(
                AppLocalizations.of(context)!.about,
                style: TextStyle(color: accent),
              ),
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => AboutPage()));
              },
            ),
          ),
        ),
        const SizedBox(
          height: 20.0,
        )
      ],
    );
  }
}
