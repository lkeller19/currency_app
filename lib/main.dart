import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';
import 'my_app_state.dart';
import 'widgets/currency_search.dart';
import 'widgets/custom_expansion_panel.dart';

enum TutorialState { initial, afterSwipeLeft, afterSwipeRight, afterTap }

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
            bodyLarge: TextStyle(color: Colors.white, fontSize: 30.0),
            bodyMedium: TextStyle(color: Colors.white, fontSize: 30.0),
            bodySmall: TextStyle(color: Colors.white, fontSize: 25.0),
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
  bool isAnimating = false;
  CustomExpansionPanel? selectedPanel;
  GlobalKey<CustomExpansionPanelState>? selectedKey;
  List<GlobalKey<CustomExpansionPanelState>> panelKeys =
      List<GlobalKey<CustomExpansionPanelState>>.generate(
    11,
    (index) => GlobalKey<CustomExpansionPanelState>(),
  );
  bool showingTutorial = false;

  @override
  void initState() {
    super.initState();

    _checkFirstRun();

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
  void didChangeDependencies() {
    super.didChangeDependencies();

    precacheImage(const AssetImage('lib/assets/swipeleft.png'), context);
    precacheImage(const AssetImage('lib/assets/swiperight.png'), context);
    precacheImage(const AssetImage('lib/assets/press.png'), context);
  }

  void _checkFirstRun() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstRun = prefs.getBool('firstRun') ?? true;
    if (isFirstRun) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showTutorialOverlay(context, trackTutorialStage);
      });
      await prefs.setBool('firstRun', false);
    }
  }

  @override
  void dispose() {
    _dragController.dispose();
    super.dispose();
  }

  Future<void> _handleExpansionPanelChanged(int? value) async {
    if (showingTutorial && tutorialStage < 2) {
      return;
    }
    double bezelHeight = MediaQuery.of(context).padding.top +
        MediaQuery.of(context).padding.bottom;
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
      final panelHeight =
          (MediaQuery.of(context).size.height - bezelHeight) / 10.99;
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
        final panelHeight =
            (MediaQuery.of(context).size.height - bezelHeight) / 10.99;
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

  OverlayEntry? tutorialOverlay;
  int tutorialStage = 0;

  void trackTutorialStage({bool clear = false}) {
    if (clear) {
      setState(() {
        tutorialStage = 0;
      });
      return;
    }
    setState(() {
      tutorialStage += 1;
    });
  }

  void showTutorialOverlay(BuildContext context, Function trackTutorialStage) {
    double bezelHeight = MediaQuery.of(context).padding.top +
        MediaQuery.of(context).padding.bottom;
    TutorialState tutorialState = TutorialState.initial;
    tutorialOverlay = OverlayEntry(
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (PointerDownEvent event) {},
            onPointerMove: (PointerMoveEvent event) {},
            onPointerUp: (PointerUpEvent event) {
              if (tutorialState == TutorialState.initial) {
                if (_dragDistance < -21) {
                  setState(() {
                    tutorialState = TutorialState.afterSwipeLeft;
                  });
                  trackTutorialStage();
                  return;
                }
              }
              if (tutorialState == TutorialState.afterSwipeLeft) {
                if (_dragDistance > 21) {
                  setState(() {
                    tutorialState = TutorialState.afterSwipeRight;
                  });
                  trackTutorialStage();
                  return;
                }
              }
              if (tutorialState == TutorialState.afterSwipeRight) {
                if (_dragDistance < 1 &&
                    _dragDistance > -1 &&
                    (MediaQuery.of(context).size.height - bezelHeight) / 11 +
                            bezelHeight <
                        event.position.dy) {
                  setState(() {
                    tutorialState = TutorialState.afterTap;
                  });
                  trackTutorialStage();
                  return;
                }
              }
              if (tutorialState == TutorialState.afterTap) {
                removeTutorialOverlay();
              }
            },
            child: IgnorePointer(
              child: Container(
                color: Colors.black.withOpacity(0.7), // Semi-transparent black
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _getTutorialContent(tutorialState),
                ),
              ),
            ),
          );
        },
      ),
    );

    Overlay.of(context).insert(tutorialOverlay!);
  }

  List<Widget> _getTutorialContent(TutorialState tutorialState) {
    switch (tutorialState) {
      case TutorialState.initial:
        return [
          Image.asset('lib/assets/swipeleft.png'), // The new image
          const Text(
            'Swipe left to increase\nthe values 10x',
            style: TextStyle(
              color: Colors.white,
              decoration: TextDecoration.none,
              fontSize: 24,
            ),
          ),
        ];
      case TutorialState.afterSwipeLeft:
        return [
          Image.asset('lib/assets/swiperight.png'), // The new image
          const Text(
            'Swipe right to decrease\nthe values 10x',
            style: TextStyle(
              color: Colors.white,
              decoration: TextDecoration.none,
              fontSize: 24,
            ),
          ),
        ];
      case TutorialState.afterSwipeRight:
        return [
          Image.asset('lib/assets/press.png'), // The new image
          const Text(
            'Tap to show values\nin between',
            style: TextStyle(
              color: Colors.white,
              decoration: TextDecoration.none,
              fontSize: 24,
            ),
          ),
        ];
      case TutorialState.afterTap:
        return [
          const Text(
            'That\'s it!',
            style: TextStyle(
              color: Colors.white,
              decoration: TextDecoration.none,
              fontSize: 24,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: TextButton(
              onPressed: removeTutorialOverlay,
              style: ButtonStyle(
                side: MaterialStateProperty.all(
                    const BorderSide(color: Colors.white, width: 2)),
              ),
              child: const Center(
                child: Text(
                  'Done',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
          ),
        ];
      default:
        return [
          TextButton(
            onPressed: removeTutorialOverlay,
            style: ButtonStyle(
              side: MaterialStateProperty.all(
                  const BorderSide(color: Colors.white, width: 2)),
            ),
            child: const Text(
              'Exit Tutorial',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ];
    }
  }

  void displayTutorial() {
    setState(() {
      showingTutorial = true;
      showTutorialOverlay(context, trackTutorialStage);
    });
  }

  void removeTutorialOverlay() {
    setState(() {
      showingTutorial = false;
    });
    trackTutorialStage(clear: true);
    tutorialOverlay?.remove();
  }

  @override
  Widget build(BuildContext context) {
    double bezelHeight = MediaQuery.of(context).padding.top +
        MediaQuery.of(context).padding.bottom;
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

    Future<void> refreshExchangeRate() async {
      appState.fetchExchangeRate();
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
                        height:
                            (MediaQuery.of(context).size.height - bezelHeight) /
                                11,
                      ),
                      Container(
                        color: colorHeaderRight,
                        width: MediaQuery.of(context).size.width / 2,
                        height:
                            (MediaQuery.of(context).size.height - bezelHeight) /
                                11,
                      ),
                    ],
                  )
                else ...[
                  SizedBox(
                    height:
                        (MediaQuery.of(context).size.height - bezelHeight) / 11,
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
                            selected != null
                                ? Container(
                                    alignment: Alignment.centerLeft,
                                    width: 40,
                                    color: colorHeaderLeft,
                                    child: IconButton(
                                        icon: const Icon(Icons.arrow_back,
                                            color: colorTableRight),
                                        onPressed: () {
                                          panelKeys[selected!]
                                              .currentState
                                              ?.handleTap();
                                        }),
                                  )
                                : Container(
                                    alignment: Alignment.centerLeft,
                                    width: 40,
                                    color: colorHeaderLeft,
                                    child: IconButton(
                                      icon: const Icon(Icons.settings,
                                          color: colorTableRight),
                                      onPressed: (showingTutorial)
                                          ? () {}
                                          : () {
                                              showOptions(displayTutorial);
                                            },
                                    ),
                                  ),
                            Container(
                              color: colorHeaderLeft,
                              alignment: Alignment.centerRight,
                              width: MediaQuery.of(context).size.width / 2 - 80,
                              child: TextButton(
                                onPressed: selected != null || showingTutorial
                                    ? null
                                    : () {
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
                                            refreshExchangeRate,
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
                                onPressed: selected != null || showingTutorial
                                    ? null
                                    : () {
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
                                            refreshExchangeRate,
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
                          if (isAnimating) return;
                          setState(() {
                            isDragging = true;
                          });
                        },
                        onHorizontalDragUpdate: (DragUpdateDetails details) {
                          if (isAnimating) return;
                          setState(() {
                            _dragDistance += details.delta.dx;
                            _dragDistance = _dragDistance.clamp(-40.0, 40.0);
                          });
                        },
                        onHorizontalDragEnd: (DragEndDetails details) {
                          if (isAnimating) return;
                          var dragDistance = _dragDistance;
                          if (_dragDistance < -21) {
                            appState.increaseFactor();
                          } else if (_dragDistance > 21) {
                            appState.decreaseFactor();
                          }

                          _dragController.reset();
                          _animation = Tween(begin: dragDistance, end: 0.0)
                              .animate(CurvedAnimation(
                                  parent: _dragController,
                                  curve: (appState.prev == appState.current ||
                                          appState.current == appState.next)
                                      ? Curves.bounceOut
                                      : Curves.easeOut))
                            ..addListener(() {
                              setState(() {
                                _dragDistance = _animation.value;
                              });
                            })
                            ..addStatusListener((status) {
                              if (status == AnimationStatus.forward) {
                                isAnimating = true;
                              } else if (status == AnimationStatus.completed) {
                                setState(() {
                                  isAnimating = false;
                                  isDragging = false;
                                });
                              }
                            });

                          _dragController.forward();
                          setState(() {
                            isDragging = false;
                          });
                        },
                        child: AnimatedBuilder(
                          animation: _dragController,
                          builder: (context, child) {
                            return Column(
                              children: [
                                ...appState.current
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  int index = entry.key;
                                  double currentValue = appState.current[index];

                                  return CustomExpansionPanel(
                                    panelKey: panelKeys[index],
                                    bezelHeight: bezelHeight,
                                    isVisible: activeRows.contains(index),
                                    value: index,
                                    selected: selected,
                                    onChanged: _handleExpansionPanelChanged,
                                    header: Transform.translate(
                                      offset: Offset(_dragDistance, 0),
                                      child: Row(
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
                                    ),
                                    body: Column(
                                      children: List.generate(9, (i) {
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              color: colorChildLeft,
                                              height: (MediaQuery.of(context)
                                                          .size
                                                          .height -
                                                      bezelHeight) /
                                                  12.31,
                                              alignment: Alignment.centerRight,
                                              width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2 -
                                                  40,
                                              child: Text(
                                                formatAbbreviated(
                                                    (selected != 9)
                                                        ? (currentValue +
                                                            ((i + 1) *
                                                                    appState
                                                                        .factor) /
                                                                10)
                                                        : (currentValue +
                                                            ((i + 1) *
                                                                    appState
                                                                        .factor *
                                                                    10) /
                                                                10),
                                                    (appState.factor == 1.00
                                                        ? 2
                                                        : 0),
                                                    true),
                                                style: const TextStyle(
                                                    color: colorTableTextLeft),
                                              ),
                                            ),
                                            Container(
                                                height: (MediaQuery.of(context)
                                                            .size
                                                            .height -
                                                        bezelHeight) /
                                                    12.31,
                                                color: colorChildLeft,
                                                width: 40),
                                            Container(
                                                height: (MediaQuery.of(context)
                                                            .size
                                                            .height -
                                                        bezelHeight) /
                                                    12.31,
                                                color: colorChildRight,
                                                width: 40),
                                            Container(
                                              height: (MediaQuery.of(context)
                                                          .size
                                                          .height -
                                                      bezelHeight) /
                                                  12.31,
                                              color: colorChildRight,
                                              alignment: Alignment.centerLeft,
                                              width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2 -
                                                  40,
                                              child: Text(
                                                formatAbbreviated(
                                                    (selected != 9)
                                                        ? ((currentValue +
                                                                ((i + 1) *
                                                                        appState
                                                                            .factor) /
                                                                    10) *
                                                            appState
                                                                .conversionRate)
                                                        : ((currentValue +
                                                                ((i + 1) *
                                                                        appState
                                                                            .factor *
                                                                        10) /
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
                                                    color: colorTableTextRight),
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
                                //     height: (MediaQuery.of(context).size.height - bezelHeight),
                                //   ),
                              ],
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

  void showOptions(Function showTutorial) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colorHeaderLeft,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await Future.delayed(const Duration(milliseconds: 200));
                    showTutorial();
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.app_shortcut, color: colorTableRight),
                      SizedBox(
                        width: 8,
                      ),
                      Text('Show Tutorial',
                          style: TextStyle(color: colorTableTextRight)),
                    ],
                  ),
                ),
                Container(
                  color: Colors.black,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Cancel',
                            style: TextStyle(color: colorTableTextRight)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
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
      Function refreshExchangeRate,
      int currency) async {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: colorHeaderLeft,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '1 $currency1',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: colorTableRight, fontSize: 20),
                        ),
                        const Icon(Icons.arrow_right_alt_sharp,
                            color: colorTableRight),
                        Text(
                          '$conversionRate $currency2',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: colorTableRight, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'UPDATED: $lastUpdated',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontSize: 12, color: colorTableRight),
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
                        Icon(Icons.swap_horiz,
                            color: colorTableRight), // Swap icon
                        SizedBox(
                          width: 8,
                        ),
                        Text('Swap',
                            style: TextStyle(
                                color: colorTableTextRight, fontSize: 20)),
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
                              Icon(Icons.attach_money, color: colorTableRight),
                              SizedBox(
                                width: 8,
                              ),
                              Text('Set to United States Dollar',
                                  style: TextStyle(
                                      color: colorTableTextRight,
                                      fontSize: 20)),
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
                          Icon(Icons.menu, color: colorTableRight),
                          SizedBox(
                            width: 8,
                          ),
                          Text('Choose Currency...',
                              style: TextStyle(
                                  color: colorTableTextRight, fontSize: 20)),
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      refreshExchangeRate();
                      Navigator.pop(context);
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh, color: colorTableRight),
                        SizedBox(
                          width: 8,
                        ),
                        Text('Refresh Exchange Rate',
                            style: TextStyle(
                                color: colorTableTextRight, fontSize: 20)),
                      ],
                    ),
                  ),
                  Container(
                    color: colorChildLeft,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Cancel',
                              style: TextStyle(
                                  color: colorHeaderTextLeft, fontSize: 20)),
                        ],
                      ),
                    ),
                  ),
                ]),
          ],
        );
      },
    );
  }
}
