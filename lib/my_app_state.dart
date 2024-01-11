import 'package:currency_app/widgets/item.dart';
import 'package:flutter/material.dart';
import 'package:forex_conversion/forex_conversion.dart';
import 'package:intl/intl.dart';

class MyAppState extends ChangeNotifier {
  double conversionRate = 0;
  int factor = 1;
  List<Item> data = [];

  MyAppState() {
    data = generateItems(11);
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
      // generate first of the next list in case last item is expanded
      if (index == 10) {
        return Item(
          headerValue: (index * 2) * factor,
          expandedValue: (index * 2) * factor,
        );
      }
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
