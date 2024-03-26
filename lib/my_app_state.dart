import 'package:flutter/material.dart';
import 'package:forex_conversion/forex_conversion.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class MyAppState extends ChangeNotifier {
  double conversionRate = 0;
  double factor = 1.00;
  List<double> current = [];
  List<double> prev = [];
  List<double> next = [];
  bool maxValueReached = false;
  String currency1 = 'USD';
  String currency2 = 'EUR';
  String lastUpdated = '';
  var formatter = DateFormat('E, MMM d, h:mm a');

  MyAppState() {
    loadPersistentState();
    current = generateItems(factor);
    prev = generateItems(factor);
    next = generateItems(factor * 10.00);
  }

  Future<void> loadPersistentState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('isfirstRun') ?? true) {
      fetchExchangeRate();
    } else {
      currency1 = prefs.getString('currency1') ?? 'USD';
      currency2 = prefs.getString('currency2') ?? 'EUR';
      conversionRate = prefs.getDouble('conversionRate') ?? 0;
      lastUpdated = prefs.getString('lastUpdated') ?? '';
      String lastUpdatedDate =
          prefs.getString('lastUpdatedDate') ?? "2022-03-14 16:26:57.102";
      final List<ConnectivityResult> connectivityResult =
          await (Connectivity().checkConnectivity());
      if (conversionRate == 0 ||
          (!connectivityResult.contains(ConnectivityResult.none) &&
              DateTime.now()
                      .difference(DateTime.parse(lastUpdatedDate))
                      .inDays >
                  2)) {
        fetchExchangeRate();
      } else {
        notifyListeners();
      }
    }
  }

  void swap() {
    var temp = currency1;
    currency1 = currency2;
    currency2 = temp;
    conversionRate = double.parse((1 / conversionRate).toStringAsFixed(6));
    notifyListeners();
  }

  void setCurrency1(String currency) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency1', currency);

    currency1 = currency;
    fetchExchangeRate();
    notifyListeners();
  }

  void setCurrency2(String currency) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency2', currency);
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
    conversionRate = 0;
    notifyListeners();

    final fx = Forex();
    var rate;

    bool success = false;

    while (!success) {
      rate = await fx.getCurrencyConverted(
          sourceCurrency: currency1,
          destinationCurrency: currency2,
          numberOfDecimals: 6);
      if (rate > 0) {
        success = true;
      } else {
        await Future.delayed(
            const Duration(seconds: 1)); // Wait before trying again
      }
    }

    conversionRate = rate;
    DateTime time = DateTime.now();
    lastUpdated = formatter.format(time);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('conversionRate', rate);
    await prefs.setString('lastUpdated', lastUpdated);
    await prefs.setString('lastUpdatedDate', time.toString());

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
