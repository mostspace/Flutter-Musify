echo 'import "dart:convert";
import "dart:io";

import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:flutter_downloader/flutter_downloader.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:http/http.dart" as http;
import "package:musify/API/version.dart";
import "package:musify/utilities/flutter_toast.dart";

late String dlUrl;
const apiUrl =
    "https://raw.githubusercontent.com/gokadzev/Musify/update/check.json";


bool isUpdaterEnabled = true;

Future<void> checkAppUpdates(BuildContext context) async {
  final response = await http.get(Uri.parse(apiUrl));
  if (response.statusCode != 200) {
    throw Exception("Failed to fetch app updates");
  }
  final map = json.decode(response.body) as Map<String, dynamic>;
  if (map["version"].toString() != appVersion) {
    await downloadAppUpdates();
    showToast(
      "${AppLocalizations.of(context)!.appUpdateAvailableAndDownloading}!",
    );
  }
}

Future<void> downloadAppUpdates() async {
  final response = await http.get(Uri.parse(apiUrl));
  if (response.statusCode != 200) {
    throw Exception("Failed to fetch app updates");
  }
  final map = json.decode(response.body) as Map<String, dynamic>;
  final dlUrl = await getCPUArchitecture() == "aarch64"
      ? map["arm64url"].toString()
      : map["url"].toString();
  final dlPath = await FilePicker.platform.getDirectoryPath();
  final file = File("$dlPath/Musify.apk");
  if (await file.exists()) {
    await file.delete();
  }
  await FlutterDownloader.enqueue(
    url: dlUrl,
    savedDir: dlPath!,
    fileName: "Musify.apk",
    showNotification: true,
  );
}

Future<String> getCPUArchitecture() async {
  final info = await Process.run("uname", ["-m"]);
  final cpu = info.stdout.toString().replaceAll("\n", "");
  return cpu;
}
' > lib/services/update_manager.dart