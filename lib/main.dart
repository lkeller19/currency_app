import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:intl/intl.dart';
import 'package:forex_conversion/forex_conversion.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CurrencyConverterBase(),
    );
  }
}

class CurrencyConverterBase extends StatefulWidget {
  @override
  _CurrencyConverterBaseState createState() => _CurrencyConverterBaseState();
}

class _CurrencyConverterBaseState extends State<CurrencyConverterBase> {
  double _conversionRate = 0;
  int _factor = 1;
  List<Item> _data = [];
  String lastUpdated = '';
  var formatter = DateFormat('E, MMM d, h:mm a');

  String currency1 = 'USD';
  String currency2 = 'EUR';

  void swap() {
    setState(() {
      var temp = currency1;
      currency1 = currency2;
      currency2 = temp;
      _conversionRate = double.parse((1 / _conversionRate).toStringAsFixed(6));
    });
  }

  void setCurrency1(String currency) {
    currency1 = currency;
  }

  void setCurrency2(String currency) {
    currency2 = currency;
  }

  @override
  void initState() {
    super.initState();
    _data = generateItems(10);
    _fetchExchangeRate();
  }

  Future<void> _fetchExchangeRate() async {
    final fx = Forex();
    var rate = await fx.getCurrencyConverted(
        sourceCurrency: "USD", destinationCurrency: "EUR", numberOfDecimals: 6);

    setState(() {
      _conversionRate = rate;
      lastUpdated = formatter.format(DateTime.now());
    });

    // final response = await http.get(Uri.parse(
    //     'https://v6.exchangerate-api.com/v6/f709645f805473f614961768/latest/USD'));

    // if (response.statusCode == 200) {
    //   setState(() {
    //     // _conversionRate = jsonDecode(response.body)['conversion_rates']['EUR'];
    //     lastUpdated = formatter.format(DateTime.now());
    //   });
    // } else {
    //   throw Exception('Failed to load exchange rate');
    // }
  }

  List<Item> generateItems(int numberOfItems) {
    return List<Item>.generate(numberOfItems, (int index) {
      return Item(
        headerValue: (index + 1) * _factor,
        expandedValue: (index + 1) * _factor,
      );
    });
  }

  void _increaseFactor() {
    setState(() {
      _factor *= 10;
      _data = generateItems(10);
    });
  }

  void _decreaseFactor() {
    setState(() {
      if (_factor > 1) {
        // Prevent _factor from going below 1
        _factor ~/= 10;
        developer.log(_factor.toString());
        _data = generateItems(10);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_conversionRate == 0)
                const CircularProgressIndicator()
              else
                SizedBox(
                  height: MediaQuery.of(context).size.height / 11,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextButton(
                          onPressed: () {
                            bottomModal(context, _conversionRate, lastUpdated,
                                currency1, currency2);
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
                    _data[index].isExpanded = !isExpanded;
                  });
                },
                children: _data.map<ExpansionPanelRadio>((Item item) {
                  return ExpansionPanelRadio(
                    value: item,
                    canTapOnHeader: true,
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height /
                            11, // Set the height of each ListTile
                        child: ListTile(
                          title: Text(
                            '${item.headerValue} USD = ${(item.headerValue * _conversionRate).toStringAsFixed(2)} EUR',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      );
                    },
                    body: Column(
                        children: List.generate(9, (i) {
                      return ListTile(
                        title: Text(
                          '${(item.headerValue + ((i + 1) * _factor) / 10).toStringAsFixed(_factor > 1 ? 0 : 2)} USD = ${((item.headerValue + ((i + 1) * _factor) / 10) * _conversionRate).toStringAsFixed(2)} EUR',
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
            onPressed: _decreaseFactor, // Add this
            tooltip: 'Decrease',
            child: const Icon(Icons.remove),
          ),
          const SizedBox(width: 10), // Add some space between the buttons
          FloatingActionButton(
            onPressed: _increaseFactor, // Update the onPressed handler
            tooltip: 'Increase',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Future<void> bottomModal(BuildContext context) {
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
                    '$_conversionRate $currency1',
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

