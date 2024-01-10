import 'package:currency_app/constants.dart';
import 'package:flutter/gestures.dart';
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

    ScrollController scrollController = ScrollController();
    List<GlobalKey> sectionKeys = List.generate(27, (index) => GlobalKey());

    return Row(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: <Widget>[
                for (var i = 0; i < matchQuery.length; i++) ...[
                  buildCurrencyTile(
                    context,
                    matchQuery[i],
                    worldCurrencies[matchQuery[i]]['name'],
                    worldCurrencies[matchQuery[i]]['symbol'],
                  ),
                  if (i == 0)
                    Column(
                      children: <Widget>[
                        const Divider(color: Colors.lightBlue),
                        const SizedBox(height: 4),
                        const Divider(color: Colors.black),
                        Row(
                            key: sectionKeys[mapSectionToKey['*']!],
                            children: const [
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
                  if (i != 0 &&
                      !(i < matchQuery.length - 1 &&
                          matchQuery[i][0].toUpperCase() !=
                              matchQuery[i + 1][0].toUpperCase()))
                    const Divider(color: Colors.lightBlue)
                ],
              ],
            ),
          ),
        ),
        Column(
          children: <Widget>[
            Expanded(
              child: _MyWidget(sectionKeys: sectionKeys),
            ),
            Expanded(
              child: Container(), // This is your spacer
            ),
          ],
        )
      ],
    );
  }

  Column createCategoryDivider(List<String> matchQuery, int index,
      BuildContext context, GlobalKey sectionKey) {
    return Column(
      children: <Widget>[
        const Divider(color: Colors.lightBlue),
        const SizedBox(height: 4),
        const Divider(color: Colors.black),
        Row(key: sectionKey, children: [
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
          Expanded(
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

class _MyWidget extends StatefulWidget {
  final List<GlobalKey> sectionKeys;

  const _MyWidget({required this.sectionKeys});

  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<_MyWidget> {
  Color _backgroundColor = const Color.fromARGB(255, 124, 124, 124);
  int _selectedIndex = -1;

  void _onPointerDown(PointerDownEvent details) {
    setState(() {
      _backgroundColor = Colors.lightBlue;
    });
  }

  void _onPointerUp(PointerUpEvent details) {
    setState(() {
      _backgroundColor = const Color.fromARGB(255, 124, 124, 124);
    });
  }

  int calculateIndex(Offset globalPosition) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset localPosition = box.globalToLocal(globalPosition);
    double itemHeight = box.size.height / widget.sectionKeys.length;
    return (localPosition.dy ~/ itemHeight)
        .clamp(0, widget.sectionKeys.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      child: SizedBox(
        width: 20,
        child: Container(
          child: GestureDetector(
            onVerticalDragUpdate: (DragUpdateDetails details) async {
              int index = calculateIndex(details.globalPosition);
              await Scrollable.ensureVisible(
                widget.sectionKeys[index].currentContext!,
              );
              setState(() {
                _selectedIndex = index;
              });
            },
            onVerticalDragEnd: (DragEndDetails details) {
              setState(() {
                _selectedIndex = -1;
              });
            },
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.sectionKeys.length,
              itemBuilder: (context, index) {
                return LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return Container(
                      color: index == _selectedIndex
                          ? Colors.red
                          : _backgroundColor,
                      child: Center(
                        child: Container(
                          child: Text(
                            mapSectionToKey.keys.elementAt(index),
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
