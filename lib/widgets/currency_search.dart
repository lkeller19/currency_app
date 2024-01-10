import 'package:currency_app/constants.dart';
import 'package:flutter/material.dart';

import 'scroll_bar.dart';

class CurrencySearch extends SearchDelegate<String> {
  Widget? listStartWidget;

  CurrencySearch({String hintText = "Search"})
      : super(
          searchFieldLabel: hintText,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          searchFieldDecorationTheme: InputDecorationTheme(
            fillColor: Colors.grey[200], // Background color
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50), // Rounded edges
              borderSide: BorderSide.none,
            ),
          ),
        );

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Opacity(
            opacity: query.isEmpty ? 0.0 : 1.0,
            child: CircleAvatar(
              backgroundColor: Colors.grey[200], // Same color as the search bar
              child: IconButton(
                icon: const Icon(Icons.clear),
                padding: EdgeInsets.zero,
                onPressed: () {
                  if (query.isEmpty) {
                    return;
                  }
                  query = '';
                },
              ),
            )),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: IconButton(
        icon: const Icon(Icons.arrow_back), // Back icon
        onPressed: () {
          close(context, ''); // Close the search delegate
        },
      ),
    );
  }

  Widget buildListDuringQuery(BuildContext context, List<String> matchQuery) {
    // return const Placeholder();
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        return buildCurrencyTile(
            context,
            matchQuery[index],
            worldCurrencies[matchQuery[index]]['name'],
            worldCurrencies[matchQuery[index]]['symbol']);
      },
    );
  }

  Widget buildListStart(BuildContext context) {
    ScrollController scrollController = ScrollController();
    List<String> matchQuery = worldCurrencies.keys.toList();
    List<GlobalKey> sectionKeys =
        List.generate(mapSectionToKey.length, (index) => GlobalKey());

    return Stack(
      children: <Widget>[
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: <Widget>[
                for (var i = 0; i < matchQuery.length; i++) ...[
                  if (i == 0)
                    Column(
                      children: <Widget>[
                        Container(key: sectionKeys[mapSectionToKey['-']!]),
                        buildCurrencyTile(
                            context, 'USD', 'United States Dollar', '\$'),
                        const Divider(color: Colors.lightBlue),
                        const SizedBox(height: 4),
                        Divider(
                            key: sectionKeys[mapSectionToKey['*']!],
                            color: Colors.black),
                        const Row(children: [
                          SizedBox(width: 8),
                          Icon(Icons.star),
                          Text('POPULAR',
                              style: TextStyle(fontWeight: FontWeight.bold))
                        ]),
                        const Divider(color: Colors.black),
                        for (var i = 0; i < popularCurrencies.length; i++) ...[
                          buildCurrencyTile(
                            context,
                            popularCurrencies[i],
                            worldCurrencies[popularCurrencies[i]]['name'],
                            worldCurrencies[popularCurrencies[i]]['symbol'],
                          ),
                          (i == popularCurrencies.length - 1)
                              ? Container()
                              : const Divider(color: Colors.lightBlue),
                        ],
                        createCategoryDivider(
                            matchQuery,
                            i,
                            context,
                            sectionKeys[mapSectionToKey[
                                matchQuery[i + 1][0].toUpperCase()]!]),
                      ],
                    ),
                  buildCurrencyTile(
                    context,
                    matchQuery[i],
                    worldCurrencies[matchQuery[i]]['name'],
                    worldCurrencies[matchQuery[i]]['symbol'],
                  ),
                  if ((i != 0) &&
                      (i < matchQuery.length - 1 &&
                          matchQuery[i][0].toUpperCase() !=
                              matchQuery[i + 1][0].toUpperCase()))
                    createCategoryDivider(
                        matchQuery,
                        i,
                        context,
                        sectionKeys[mapSectionToKey[
                            matchQuery[i + 1][0].toUpperCase()]!]),
                  if (!(i < matchQuery.length - 1 &&
                      matchQuery[i][0].toUpperCase() !=
                          matchQuery[i + 1][0].toUpperCase()))
                    const Divider(color: Colors.lightBlue)
                ],
              ],
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ScrollBar(sectionKeys: sectionKeys),
              Flexible(
                fit: FlexFit.loose,
                child: Container(), // This is your spacer
              ),
            ],
          ),
        ),
      ],
    );
  }

  Column createCategoryDivider(List<String> matchQuery, int index,
      BuildContext context, GlobalKey sectionKey) {
    return Column(
      children: <Widget>[
        const Divider(color: Colors.lightBlue),
        const SizedBox(height: 4),
        Divider(key: sectionKey, color: Colors.black),
        Row(children: [
          const SizedBox(width: 8),
          Text(
            matchQuery[index + 1][0].toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          )
        ]),
        const Divider(color: Colors.black),
      ],
    );
  }

  Widget buildCurrencyTile(BuildContext context, String currencyCode,
      String currencyName, String currencySymbol) {
    return ListTile(
      onTap: () {
        close(context, currencyCode);
      },
      title: Row(
        children: <Widget>[
          Flexible(
            fit: FlexFit.loose,
            child: Text.rich(
              TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: '$currencyCode: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: '$currencyName '),
                  TextSpan(text: '($currencySymbol)'),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void showResults(BuildContext context) {
    if (query.isNotEmpty) {
      super.showResults(context);
    }
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = worldCurrencies.entries
        .where((entry) =>
            entry.key.toLowerCase().startsWith(query.toLowerCase()) ||
            entry.value['name']
                .toLowerCase()
                .split(' ')
                .any((String word) => word.startsWith(query.toLowerCase())))
        .map((entry) => entry.key)
        .toList();

    return buildListDuringQuery(context, matchQuery);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      if (listStartWidget == null) {
        listStartWidget = buildListStart(context);
      }
      return listStartWidget!;
    } else {
      return buildListDuringQuery(
          context,
          worldCurrencies.entries
              .where((entry) =>
                  entry.key.toLowerCase().contains(query.toLowerCase()) ||
                  entry.value['name'].toLowerCase().split(' ').any(
                      (String word) => word.startsWith(query.toLowerCase())))
              .map((entry) => entry.key)
              .toList());
    }
  }
}
