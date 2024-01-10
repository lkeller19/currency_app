import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:intl/intl.dart';
import 'package:forex_conversion/forex_conversion.dart';
import 'package:provider/provider.dart';
import 'package:currency_app/constants.dart';

import 'widgets/currency_search.dart';
import 'widgets/item.dart';

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
          primarySwatch: Colors.blue,
        ),
        home: const _CurrencyConverterBase(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  double conversionRate = 0;
  int factor = 1;
  List<Item> data = [];

  MyAppState() {
    data = generateItems(10);
    fetchExchangeRate();
  }

  String lastUpdated = '';
  var formatter = DateFormat('E, MMM d, h:mm a');

  String currency1 = 'USD';
  String currency2 = 'EUR';

  void swap() {
    var temp = currency1;
    currency1 = currency2;
    currency2 = temp;
    conversionRate = double.parse((1 / conversionRate).toStringAsFixed(6));
    notifyListeners();
  }

  void setCurrency1(String currency) {
    currency1 = currency;
    fetchExchangeRate();
    notifyListeners();
  }

  void setCurrency2(String currency) {
    currency2 = currency;
    fetchExchangeRate();
    notifyListeners();
  }

  List<Item> generateItems(int numberOfItems) {
    return List<Item>.generate(numberOfItems, (int index) {
      return Item(
        headerValue: (index + 1) * factor,
        expandedValue: (index + 1) * factor,
      );
    });
  }

  void increaseFactor() {
    factor *= 10;
    data = generateItems(10);
    notifyListeners();
  }

  void decreaseFactor() {
    if (factor > 1) {
      // Prevent factor from going below 1
      factor ~/= 10;
      developer.log(factor.toString());
      data = generateItems(10);
    }
    notifyListeners();
  }

  Future<void> fetchExchangeRate() async {
    final fx = Forex();
    var rate = await fx.getCurrencyConverted(
        sourceCurrency: currency1,
        destinationCurrency: currency2,
        numberOfDecimals: 6);

    conversionRate = rate;
    lastUpdated = formatter.format(DateTime.now());
    notifyListeners();

    // final response = await http.get(Uri.parse(
    //     'https://v6.exchangerate-api.com/v6/*****/latest/USD'));

    // if (response.statusCode == 200) {
    //   setState(() {
    //     // conversionRate = jsonDecode(response.body)['conversion_rates']['EUR'];
    //     lastUpdated = formatter.format(DateTime.now());
    //   });
    // } else {
    //   throw Exception('Failed to load exchange rate');
    // }
  }
}

class _CurrencyConverterBase extends StatefulWidget {
  const _CurrencyConverterBase();

  @override
  _CurrencyConverterBaseState createState() => _CurrencyConverterBaseState();
}

class _CurrencyConverterBaseState extends State<_CurrencyConverterBase> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    Future<void> displaySearch(int currency) async {
      final selected = await showSearch<String>(
        context: context,
        delegate: CurrencySearch(),
      );
      if (selected != null && selected.isNotEmpty) {
        currency == 1
            ? appState.setCurrency1(selected)
            : appState.setCurrency2(selected);
      }
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (appState.conversionRate == 0)
                const CircularProgressIndicator()
              else
                SizedBox(
                  height: MediaQuery.of(context).size.height / 11,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextButton(
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
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          appState.currency2,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ]),
                ),
              ExpansionPanelList.radio(
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    appState.data[index].isExpanded = !isExpanded;
                  });
                },
                children: appState.data.map<ExpansionPanelRadio>((Item item) {
                  return ExpansionPanelRadio(
                    value: item,
                    canTapOnHeader: true,
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height /
                            11, // Set the height of each ListTile
                        child: ListTile(
                          title: Text(
                            '${item.headerValue} ${appState.currency1} = ${(item.headerValue * appState.conversionRate).toStringAsFixed(2)} ${appState.currency2}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      );
                    },
                    body: Column(
                        children: List.generate(9, (i) {
                      return ListTile(
                        title: Text(
                          '${(item.headerValue + ((i + 1) * appState.factor) / 10).toStringAsFixed(appState.factor > 1 ? 0 : 2)} USD = ${((item.headerValue + ((i + 1) * appState.factor) / 10) * appState.conversionRate).toStringAsFixed(2)} EUR',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    })),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        // Wrap the FloatingActionButtons in a Row
        mainAxisAlignment:
            MainAxisAlignment.end, // Align the buttons to the end
        children: <Widget>[
          FloatingActionButton(
            onPressed: appState.decreaseFactor,
            heroTag: 'decrease',
            tooltip: 'Decrease',
            child: const Icon(Icons.remove),
          ),
          const SizedBox(width: 10), // Add some space between the buttons
          FloatingActionButton(
            onPressed: appState.increaseFactor, // Update the onPressed handler
            heroTag: 'increase',
            tooltip: 'Increase',
            child: const Icon(Icons.add),
          ),
        ],
      ),
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
