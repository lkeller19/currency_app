import 'package:flutter/material.dart';
import 'package:forex_conversion/forex_conversion.dart';
import 'package:intl/intl.dart';

class MyAppState extends ChangeNotifier {
  double conversionRate = 0;
  double factor = 1.00;
  List<double> current = [];
  List<double> prev = [];
  List<double> next = [];
  bool maxValueReached = false;

  MyAppState() {
    current = generateItems(factor);
    prev = generateItems(factor);
    next = generateItems(factor * 10.00);
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

  // create generate next and generate previous

  List<double> generateItems(double factorValue, {int numValues = 11}) {
    return List<double>.generate(numValues, (int index) {
      // generate first of the next list in case last item is expanded
      if (index == 10) {
        return (index * 2) * factorValue;
      }
      return (index + 1) * factorValue;
    });
  }

  void increaseFactor() {
    if (maxValueReached) {
      return;
    }
    if (factor * 10 >= 100000000000 &&
        factor * 10 * conversionRate >= 100000000000) {
      factor *= 10.00;
      prev = current;
      current = generateItems(factor);
      next = current;
      maxValueReached = true;
      return;
    }
    factor *= 10.00;
    prev = current;
    current = generateItems(factor);
    next = generateItems(factor * 10.00);
    notifyListeners();
  }

  void decreaseFactor() {
    if (factor / 10.00 <= 100000000000 &&
        factor / 10.00 * conversionRate <= 100000000000) {
      maxValueReached = false;
    }
    if (factor > 10.00) {
      // Prevent factor from going below 1
      factor /= 10.00;
      prev = generateItems(factor / 10.00);
      next = current;
      current = generateItems(factor);
    } else if (factor > 1.00) {
      factor /= 10.00;
      next = current;
      current = generateItems(factor);
      prev = current;
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
