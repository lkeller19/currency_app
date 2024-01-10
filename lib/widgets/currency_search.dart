import 'package:currency_app/constants.dart';
import 'package:flutter/material.dart';

class CurrencySearch extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      TextButton(
        child: const Text('Cancel'),
        onPressed: () {
          close(context, '');
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return Container();
  }

  Widget buildListDuringQuery(BuildContext context, List<String> matchQuery) {
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

  Widget buildListStart(BuildContext context, List<String> matchQuery) {
    matchQuery.insert(0, 'USD');

    ScrollController _scrollController = ScrollController();
    List<GlobalKey> sectionKeys = List.generate(27, (index) => GlobalKey());
    int key = 1;

    return Row(
      children: <Widget>[
        Expanded(
          child: ListView.separated(
            controller: _scrollController,
            itemCount: matchQuery.length,
            itemBuilder: (context, index) {
              return buildCurrencyTile(
                  context,
                  matchQuery[index],
                  worldCurrencies[matchQuery[index]]['name'],
                  worldCurrencies[matchQuery[index]]['symbol']);
            },
            separatorBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  children: <Widget>[
                    const Divider(color: Colors.lightBlue),
                    const SizedBox(height: 4),
                    const Divider(color: Colors.black),
                    Row(key: sectionKeys[mapSectionToKey['*']!], children: [
                      const SizedBox(width: 8),
                      const Icon(Icons.star),
                      Text(
                        'POPULAR',
                        style: DefaultTextStyle.of(context)
                            .style
                            .copyWith(fontWeight: FontWeight.bold),
                      )
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
                        index,
                        context,
                        sectionKeys[mapSectionToKey[
                            matchQuery[index + 1][0].toUpperCase()]!]),
                  ],
                );
              } else if (index < matchQuery.length - 1 &&
                  matchQuery[index][0].toUpperCase() !=
                      matchQuery[index + 1][0].toUpperCase()) {
                return createCategoryDivider(
                    matchQuery,
                    index,
                    context,
                    sectionKeys[mapSectionToKey[
                        matchQuery[index + 1][0].toUpperCase()]!]);
              } else {
                return const Divider(color: Colors.lightBlue);
              }
            },
          ),
        ),
        SizedBox(
  width: 30,
  child: ListView(
    children: sectionKeys.map((key) {
      return GestureDetector(
        onTap: () {
          print('Key: $key');
          _scrollController.animateTo(
            key.currentContext!.findRenderObject()!.semanticBounds.top,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
        child: Text(
          '${mapSectionToKey.keys.elementAt(sectionKeys.indexOf(key))}',
          style: const TextStyle(fontSize: 10),
        ),
      );
    }).toList(),
  ),
),
      ],
    );
  }

  Column createCategoryDivider(List<String> matchQuery, int index,
      BuildContext context, GlobalKey sectionKey) {
    print(sectionKey);
    return Column(
      children: <Widget>[
        const Divider(color: Colors.lightBlue),
        const SizedBox(height: 4),
        const Divider(color: Colors.black),
        Row(key: sectionKey, children: [
          const SizedBox(width: 8),
          Text(
            matchQuery[index + 1][0].toUpperCase(),
            style: DefaultTextStyle.of(context)
                .style
                .copyWith(fontWeight: FontWeight.bold),
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
          Text(
            '$currencyCode: ',
            style: DefaultTextStyle.of(context)
                .style
                .copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            '$currencyName ',
          ),
          Text(
            '($currencySymbol)',
          ),
        ],
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = worldCurrencies.entries
        .where((entry) =>
            entry.key.toLowerCase().contains(query.toLowerCase()) ||
            entry.value['name'].toLowerCase().contains(query.toLowerCase()))
        .map((entry) => entry.key)
        .toList();

    return buildListDuringQuery(context, matchQuery);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return buildListStart(context, worldCurrencies.keys.toList());
    } else {
      return buildListDuringQuery(
          context,
          worldCurrencies.entries
              .where((entry) =>
                  entry.key.toLowerCase().contains(query.toLowerCase()) ||
                  entry.value['name']
                      .toLowerCase()
                      .contains(query.toLowerCase()))
              .map((entry) => entry.key)
              .toList());
    }
  }
}
