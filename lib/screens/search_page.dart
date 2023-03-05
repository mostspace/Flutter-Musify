import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musify/API/musify.dart';
import 'package:musify/services/data_manager.dart';
import 'package:musify/style/app_themes.dart';
import 'package:musify/widgets/song_bar.dart';
import 'package:musify/widgets/spinner.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

List searchHistory = Hive.box('user').get('searchHistory', defaultValue: []);

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchBar = TextEditingController();
  final ValueNotifier<bool> _fetchingSongs = ValueNotifier(false);
  final FocusNode _inputNode = FocusNode();
  List _searchResult = [];
  List _suggestionsList = [];

  Future<void> search() async {
    final query = _searchBar.text;

    if (query.isEmpty) {
      _searchResult = [];
      _suggestionsList = [];
      setState(() {});
      return;
    }

    if (!_fetchingSongs.value) {
      _fetchingSongs.value = true;
    }

    if (!searchHistory.contains(query)) {
      searchHistory.insert(0, query);
      addOrUpdateData('user', 'searchHistory', searchHistory);
    }

    try {
      _searchResult = await fetchSongsList(query);
    } catch (e) {
      debugPrint('Error while searching online songs: $e');
    }

    if (_fetchingSongs.value) {
      _fetchingSongs.value = false;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.search,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                top: 12,
                bottom: 20,
                left: 12,
                right: 12,
              ),
              child: TextField(
                onSubmitted: (String value) {
                  search();
                  _suggestionsList = [];
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                onChanged: (value) {
                  setState(() {
                    if (value != '') {
                      getSearchSuggestions(value)
                          .then((value) => _suggestionsList = value);
                    } else {
                      _suggestionsList = [];
                    }
                  });
                },
                textInputAction: TextInputAction.search,
                controller: _searchBar,
                focusNode: _inputNode,
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.primary,
                ),
                cursorColor: Colors.green[50],
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(15),
                    ),
                    borderSide: BorderSide(color: colorScheme.primary),
                  ),
                  suffixIcon: ValueListenableBuilder<bool>(
                    valueListenable: _fetchingSongs,
                    builder: (_, value, __) {
                      if (value == true) {
                        return IconButton(
                          icon: const SizedBox(
                            height: 18,
                            width: 18,
                            child: Spinner(),
                          ),
                          color: colorScheme.primary,
                          onPressed: () {
                            search();
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                        );
                      } else {
                        return IconButton(
                          icon: Icon(
                            FluentIcons.search_20_regular,
                            color: colorScheme.primary,
                          ),
                          color: colorScheme.primary,
                          onPressed: () {
                            search();
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                        );
                      }
                    },
                  ),
                  hintText: '${AppLocalizations.of(context)!.search}...',
                  hintStyle: TextStyle(
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
            if (_searchResult.isEmpty)
              ListView.builder(
                shrinkWrap: true,
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: false,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _suggestionsList.isEmpty
                    ? searchHistory.length
                    : _suggestionsList.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  final suggestionsNotAvailable = _suggestionsList.isEmpty;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 6),
                    child: Card(
                      child: ListTile(
                        leading: Icon(
                          FluentIcons.search_24_regular,
                          color: colorScheme.primary,
                        ),
                        title: Text(
                          suggestionsNotAvailable
                              ? searchHistory[index]
                              : _suggestionsList[index],
                        ),
                        onTap: () async {
                          _searchBar.text = suggestionsNotAvailable
                              ? searchHistory[index]
                              : _suggestionsList[index];
                          await search();
                        },
                      ),
                    ),
                  );
                },
              )
            else
              ListView.builder(
                shrinkWrap: true,
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: false,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _searchResult.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: SongBar(
                      _searchResult[index],
                      true,
                    ),
                  );
                },
              )
          ],
        ),
      ),
    );
  }
}
