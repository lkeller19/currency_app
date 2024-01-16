import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'constants.dart';

import 'my_app_state.dart';
import 'widgets/currency_search.dart';
import 'widgets/custom_expansion_panel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Currency Converter',
        theme: ThemeData(
          fontFamily: 'TilliumWeb',
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white, fontSize: 25.0),
            bodyMedium: TextStyle(color: Colors.white, fontSize: 25.0),
            bodySmall: TextStyle(color: Colors.white, fontSize: 20.0),
            // Add other text styles if needed
          ),
          primarySwatch: Colors.blueGrey,
        ),
        home: const _CurrencyConverterBase(),
      ),
    );
  }
}

class _CurrencyConverterBase extends StatefulWidget {
  const _CurrencyConverterBase();

  @override
  _CurrencyConverterBaseState createState() => _CurrencyConverterBaseState();
}

class _CurrencyConverterBaseState extends State<_CurrencyConverterBase>
    with SingleTickerProviderStateMixin {
  bool _swipeActionPerformed = false;
  int? selected;
  List<int> activeRows = defaultActiveRows;
  final ScrollController _scrollController = ScrollController();
  double _dragDistance = 0;
  late AnimationController _dragController;
  late Animation _animation;
  bool isDragging = false;

  @override
  void initState() {
    super.initState();

    _dragController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _animation = Tween(begin: 0.0, end: 0.0).animate(
        CurvedAnimation(parent: _dragController, curve: Curves.bounceOut));

    _dragController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _dragDistance = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _dragController.dispose();
    super.dispose();
  }

  Future<void> _handleExpansionPanelChanged(int? value) async {
    if (value == 9) {
      var newActiveRows = List<int>.from(defaultActiveRows);
      newActiveRows.add(10);
      setState(() {
        activeRows = newActiveRows;
      });
    }
    var prevSelected = selected;
    setState(() {
      selected = value;
    });
    if (value != null) {
      final panelHeight = MediaQuery.of(context).size.height / 10.99;
      final offset = panelHeight * value + 3;
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 1500),
        curve: Curves.elasticOut,
      );
      await Future.delayed(const Duration(milliseconds: 1700));
    }

    setState(() {
      if (value != null) {
        activeRows = [value, value + 1];
      } else {
        activeRows = defaultActiveRows;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (value == null) {
        final panelHeight = MediaQuery.of(context).size.height / 10.99;
        final offset = panelHeight * prevSelected! + 3;
        _scrollController.jumpTo(
          offset,
        );

        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 1500),
          curve: Curves.elasticOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    Future<void> displaySearch(int currency) async {
      final selected = await showSearch<String>(
        context: context,
        delegate: CurrencySearch(
            hintText:
                'Search (${(currency == 1) ? '? --> ${appState.currency2}' : '${appState.currency1} --> ?'})'),
      );
      if (selected != null && selected.isNotEmpty) {
        currency == 1
            ? appState.setCurrency1(selected)
            : appState.setCurrency2(selected);
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: MediaQuery.of(context).size.width / 2,
              color: colorTableLeft, // First color
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              width: MediaQuery.of(context).size.width / 2,
              color: colorTableRight, // Second color
            ),
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (appState.conversionRate == 0)
                  Row(
                    children: <Widget>[
                      Container(
                        color: colorHeaderLeft,
                        width: MediaQuery.of(context).size.width / 2,
                        height: MediaQuery.of(context).size.height / 11,
                      ),
                      Container(
                        color: colorHeaderRight,
                        width: MediaQuery.of(context).size.width / 2,
                        height: MediaQuery.of(context).size.height / 11,
                      ),
                    ],
                  )
                else ...[
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 11,
                    child: GestureDetector(
                      onHorizontalDragUpdate: (DragUpdateDetails details) {
                        if (!_swipeActionPerformed &&
                            (details.delta.dx > 3 || details.delta.dx < -3)) {
                          appState.swap();
                          _swipeActionPerformed = true;
                        }
                      },
                      onHorizontalDragEnd: (DragEndDetails details) {
                        _swipeActionPerformed = false;
                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              color: colorHeaderLeft,
                              alignment: Alignment.centerRight,
                              width: MediaQuery.of(context).size.width / 2 - 40,
                              child: TextButton(
                                onPressed: () {
                                  bottomModal(
                                      context,
                                      appState.currency1,
                                      appState.currency2,
                                      appState.conversionRate,
                                      appState.lastUpdated,
                                      appState.swap,
                                      appState.setCurrency1,
                                      appState.setCurrency2,
                                      displaySearch,
                                      1);
                                },
                                child: Text(
                                  appState.currency1,
                                  style: const TextStyle(
                                      color: colorHeaderTextLeft,
                                      fontSize: 25.0),
                                ),
                              ),
                            ),
                            Container(
                              color: colorHeaderLeft,
                              width: 40,
                            ),
                            Container(
                              color: colorHeaderRight,
                              width: 40,
                            ),
                            Container(
                              color: colorHeaderRight,
                              alignment: Alignment.centerLeft,
                              width: MediaQuery.of(context).size.width / 2 - 40,
                              child: TextButton(
                                onPressed: () {
                                  bottomModal(
                                      context,
                                      appState.currency1,
                                      appState.currency2,
                                      appState.conversionRate,
                                      appState.lastUpdated,
                                      appState.swap,
                                      appState.setCurrency1,
                                      appState.setCurrency2,
                                      displaySearch,
                                      2);
                                },
                                child: Text(
                                  appState.currency2,
                                  style: const TextStyle(
                                      color: colorHeaderTextRight,
                                      fontSize: 25.0),
                                ),
                              ),
                            ),
                          ]),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      child: GestureDetector(
                        onHorizontalDragStart: (DragStartDetails details) {
                          setState(() {
                            isDragging = true;
                          });
                        },
                        onHorizontalDragUpdate: (DragUpdateDetails details) {
                          setState(() {
                            _dragDistance += details.delta.dx;
                            _dragDistance = _dragDistance.clamp(-40.0, 40.0);
                          });
                        },
                        onHorizontalDragEnd: (DragEndDetails details) async {
                          var dragDistance = _dragDistance;
                          if (_dragDistance < -35) {
                            appState.increaseFactor();
                          } else if (_dragDistance > 35) {
                            appState.decreaseFactor();
                          }

                          _dragController.reset();
                          _animation = Tween(begin: dragDistance, end: 0.0)
                              .animate(CurvedAnimation(
                                  parent: _dragController,
                                  curve: Curves.bounceOut))
                            ..addListener(() {
                              setState(() {
                                _dragDistance = _animation.value;
                              });
                            });
                          _dragController.forward();
                          setState(() {
                            isDragging = false;
                          });
                        },
                        child: AnimatedBuilder(
                          animation: _dragController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(_dragDistance, 0),
                              child: Column(
                                children: [
                                  ...appState.current
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    int index = entry.key;
                                    double currentValue =
                                        appState.current[index];

                                    return CustomExpansionPanel(
                                      isVisible: activeRows.contains(index),
                                      value: index,
                                      selected: selected,
                                      onChanged: _handleExpansionPanelChanged,
                                      header: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            color: Colors.transparent,
                                            alignment: Alignment.centerRight,
                                            width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2 -
                                                40,
                                            child: Stack(
                                              alignment: Alignment.centerRight,
                                              children: [
                                                // Current number
                                                Opacity(
                                                  opacity: isDragging
                                                      ? 1 -
                                                          (_dragDistance.abs() /
                                                                  40)
                                                              .clamp(0.0, 1.0)
                                                      : 1.0,
                                                  child: Text(
                                                    formatAbbreviated(
                                                        currentValue,
                                                        (appState.factor == 1.00
                                                            ? 2
                                                            : 0),
                                                        true),
                                                    style: const TextStyle(
                                                        color:
                                                            colorTableTextLeft),
                                                  ),
                                                ),
                                                // Next number
                                                if (isDragging)
                                                  Opacity(
                                                    opacity:
                                                        (_dragDistance.abs() /
                                                                40)
                                                            .clamp(0.0, 1.0),
                                                    child: Text(
                                                      formatAbbreviated(
                                                          _dragDistance < 0
                                                              ? appState
                                                                  .next[index]
                                                              : appState
                                                                  .prev[index],
                                                          (appState.factor <=
                                                                  10.00
                                                              ? _dragDistance >
                                                                      0
                                                                  ? 2
                                                                  : 0
                                                              : 0),
                                                          true),
                                                      style: const TextStyle(
                                                          color:
                                                              colorTableTextLeft),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                              color: Colors.transparent,
                                              width: 40),
                                          Container(
                                              color: Colors.transparent,
                                              width: 40),
                                          Container(
                                            color: Colors.transparent,
                                            alignment: Alignment.centerLeft,
                                            width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2 -
                                                40,
                                            child: Stack(
                                              alignment: Alignment.centerRight,
                                              children: [
                                                // Current number
                                                Opacity(
                                                  opacity: isDragging
                                                      ? 1 -
                                                          (_dragDistance.abs() /
                                                                  40)
                                                              .clamp(0.0, 1.0)
                                                      : 1.0,
                                                  child: Text(
                                                    formatAbbreviated(
                                                        (currentValue *
                                                            appState
                                                                .conversionRate),
                                                        (appState.factor *
                                                                    1 *
                                                                    appState
                                                                        .conversionRate <
                                                                100)
                                                            ? 2
                                                            : 0,
                                                        false),
                                                    style: const TextStyle(
                                                        color:
                                                            colorTableTextRight),
                                                  ),
                                                ),
                                                if (isDragging)
                                                  Opacity(
                                                    opacity:
                                                        (_dragDistance.abs() /
                                                                40)
                                                            .clamp(0.0, 1.0),
                                                    child: Text(
                                                      formatAbbreviated(
                                                          _dragDistance < 0
                                                              ? appState.next[
                                                                      index] *
                                                                  appState
                                                                      .conversionRate
                                                              : appState.prev[
                                                                      index] *
                                                                  appState
                                                                      .conversionRate,
                                                          (appState.factor *
                                                                      1 *
                                                                      appState
                                                                          .conversionRate <
                                                                  100)
                                                              ? 2
                                                              : 0,
                                                          false),
                                                      style: const TextStyle(
                                                          color:
                                                              colorTableTextLeft),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      body: Column(
                                        children: List.generate(9, (i) {
                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                color: colorChildLeft,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    12.3,
                                                alignment:
                                                    Alignment.centerRight,
                                                width: MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        2 -
                                                    40,
                                                child: Text(
                                                  formatAbbreviated(
                                                      (currentValue +
                                                          ((i + 1) *
                                                                  appState
                                                                      .factor) /
                                                              10),
                                                      (appState.factor == 1.00
                                                          ? 2
                                                          : 0),
                                                      true),
                                                  style: const TextStyle(
                                                      color:
                                                          colorTableTextLeft),
                                                ),
                                              ),
                                              Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      12.3,
                                                  color: colorChildLeft,
                                                  width: 40),
                                              Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      12.3,
                                                  color: colorChildRight,
                                                  width: 40),
                                              Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    12.3,
                                                color: colorChildRight,
                                                alignment: Alignment.centerLeft,
                                                width: MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        2 -
                                                    40,
                                                child: Text(
                                                  formatAbbreviated(
                                                      ((currentValue +
                                                              ((i + 1) *
                                                                      appState
                                                                          .factor) /
                                                                  10) *
                                                          appState
                                                              .conversionRate),
                                                      (appState.factor *
                                                                  1 *
                                                                  appState
                                                                      .conversionRate <
                                                              100)
                                                          ? 2
                                                          : 0,
                                                      false),
                                                  style: const TextStyle(
                                                      color:
                                                          colorTableTextRight),
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                      ),
                                    );
                                  }).toList(),
                                  // if (selected == null)
                                  //   Container(
                                  //     height: MediaQuery.of(context).size.height,
                                  //   ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String formatAbbreviated(double num, int numDecimals, bool leftSide) {
    if (leftSide) {
      if (num >= 1000000000000 && num < 10000000000000) {
        return '${(num / 1000000000000).toStringAsFixed(1)}T';
      } else if (num >= 1000000000 && num < 10000000000) {
        return '${(num / 1000000000).toStringAsFixed(1)}B';
      } else if (num >= 1000000 && num < 10000000) {
        return '${(num / 1000000).toStringAsFixed(1)}M';
      }
    }
    if (num >= 1000000000000) {
      return '${(num / 1000000000000).toStringAsFixed(leftSide ? 0 : 2)}T';
    } else if (num >= 1000000000) {
      return '${(num / 1000000000).toStringAsFixed(leftSide ? 0 : 2)}B';
    } else if (num >= 1000000) {
      return '${(num / 1000000).toStringAsFixed(leftSide ? 0 : 2)}M';
    } else if (num >= 100000) {
      return '${(num / 1000).toStringAsFixed(0)}K';
    } else {
      if (numDecimals == 2) {
        return NumberFormat("#,##0.00", "en_US").format(num);
      } else {
        return NumberFormat("#,##0", "en_US").format(num);
      }
    }
  }

  Future<void> bottomModal(
      BuildContext context,
      String currency1,
      String currency2,
      double conversionRate,
      String lastUpdated,
      Function swap,
      Function setCurrency1,
      Function setCurrency2,
      Function displaySearch,
      int currency) async {
    return showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '1 $currency1',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const Icon(Icons.arrow_right_alt_sharp),
                      Text(
                        '$conversionRate $currency2',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  Text(
                    'UPDATED: $lastUpdated',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await Future.delayed(const Duration(milliseconds: 200));
                      swap();
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.swap_horiz), // Swap icon
                        Text('Swap'),
                      ],
                    ),
                  ),
                  currency1 != 'USD' && currency2 != 'USD'
                      ? TextButton(
                          onPressed: () {
                            currency == 1
                                ? setCurrency1('USD')
                                : setCurrency2('USD');
                            Navigator.pop(context);
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.attach_money),
                              SizedBox(
                                width: 8,
                              ),
                              Text('Set to United States Dollar'),
                            ],
                          ),
                        )
                      : Container(),
                  Builder(
                    builder: (newContext) => TextButton(
                      onPressed: () async {
                        Navigator.pop(newContext);
                        await Future.delayed(const Duration(milliseconds: 200));
                        displaySearch(currency);
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.menu),
                          SizedBox(
                            width: 8,
                          ),
                          Text('Choose Currency...'),
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Cancel'),
                      ],
                    ),
                  ),
                ]),
          ],
        );
      },
    );
  }
}
