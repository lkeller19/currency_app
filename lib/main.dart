import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:intl/intl.dart';
import 'package:forex_conversion/forex_conversion.dart';
import 'package:provider/provider.dart';

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
        home: CurrencyConverterBase(),
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
  }

  void setCurrency2(String currency) {
    currency2 = currency;
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
        sourceCurrency: "USD", destinationCurrency: "EUR", numberOfDecimals: 6);

    conversionRate = rate;
    lastUpdated = formatter.format(DateTime.now());
    notifyListeners();

    // final response = await http.get(Uri.parse(
    //     'https://v6.exchangerate-api.com/v6/f709645f805473f614961768/latest/USD'));

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

class CurrencyConverterBase extends StatefulWidget {
  @override
  _CurrencyConverterBaseState createState() => _CurrencyConverterBaseState();
}

class _CurrencyConverterBaseState extends State<CurrencyConverterBase> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

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
                                appState.swap);
                          },
                          child: const Text(
                            'USD',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        const Text(
                          'EUR',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ]),
                ),
              ExpansionPanelList.radio(
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    developer.log("here");
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
                            '${item.headerValue} USD = ${(item.headerValue * appState.conversionRate).toStringAsFixed(2)} EUR',
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
            onPressed: appState.decreaseFactor, // Add this
            tooltip: 'Decrease',
            child: const Icon(Icons.remove),
          ),
          const SizedBox(width: 10), // Add some space between the buttons
          FloatingActionButton(
            onPressed: appState.increaseFactor, // Update the onPressed handler
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
      Function swap) async {
    return showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Column(
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
                    '$conversionRate $currency1',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
              Text(
                'UPDATED: $lastUpdated',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TextButton(
                onPressed: () {
                  swap();
                  Navigator.pop(context);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.swap_horiz), // Swap icon
                    Text('Swap'),
                  ],
                ),
              ),
            ]);
      },
      isScrollControlled: true, // This allows the modal to be full screen
    );
  }
}

class Item {
  Item({
    this.expandedValue = 0,
    this.headerValue = 0,
    this.isExpanded = false,
  });

  int expandedValue;
  int headerValue;
  bool isExpanded;
}
