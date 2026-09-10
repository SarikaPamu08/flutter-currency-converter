```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const CurrencyConverterApp());
}

class CurrencyConverterApp extends StatelessWidget {
  const CurrencyConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Currency Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const CurrencyConverterPage(),
    );
  }
}

class CurrencyConverterPage extends StatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  State<CurrencyConverterPage> createState() =>
      _CurrencyConverterPageState();
}

class _CurrencyConverterPageState
    extends State<CurrencyConverterPage> {

  final TextEditingController amountController =
      TextEditingController();

  String fromCurrency = 'USD';
  String toCurrency = 'INR';

  double result = 0.0;
  bool isLoading = false;

  final List<String> currencies = [
    'USD',
    'INR',
    'EUR',
    'GBP',
    'JPY',
    'AUD',
    'CAD',
  ];

  Future<void> convertCurrency() async {
    if (amountController.text.isEmpty) {
      return;
    }

    double amount =
        double.tryParse(amountController.text) ?? 0;

    if (amount <= 0) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse(
        'https://api.frankfurter.app/latest'
        '?amount=$amount'
        '&from=$fromCurrency'
        '&to=$toCurrency',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          result =
              (data['rates'][toCurrency] as num).toDouble();
        });
      } else {
        showError('Failed to fetch exchange rate.');
      }
    } catch (e) {
      showError('Something went wrong. Check your internet connection.');
    }

    setState(() {
      isLoading = false;
    });
  }

  void swapCurrencies() {
    setState(() {
      String temp = fromCurrency;
      fromCurrency = toCurrency;
      toCurrency = temp;
      result = 0;
    });
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Currency Converter',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            const SizedBox(height: 30),

            const Icon(
              Icons.currency_exchange,
              size: 80,
              color: Colors.blue,
            ),

            const SizedBox(height: 30),

            // Amount
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Amount',
                hintText: 'Enter amount',
                prefixIcon: const Icon(Icons.money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // From currency
            DropdownButtonFormField<String>(
              value: fromCurrency,
              decoration: InputDecoration(
                labelText: 'From',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: currencies.map((currency) {
                return DropdownMenuItem(
                  value: currency,
                  child: Text(currency),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  fromCurrency = value!;
                });
              },
            ),

            const SizedBox(height: 15),

            // Swap button
            Center(
              child: IconButton(
                onPressed: swapCurrencies,
                icon: const Icon(
                  Icons.swap_vert,
                  size: 35,
                ),
              ),
            ),

            // To currency
            DropdownButtonFormField<String>(
              value: toCurrency,
              decoration: InputDecoration(
                labelText: 'To',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: currencies.map((currency) {
                return DropdownMenuItem(
                  value: currency,
                  child: Text(currency),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  toCurrency = value!;
                });
              },
            ),

            const SizedBox(height: 25),

            // Convert button
            ElevatedButton(
              onPressed: isLoading ? null : convertCurrency,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text(
                      'Convert',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
            ),

            const SizedBox(height: 30),

            // Result
            if (result > 0)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Text(
                      '$fromCurrency ${amountController.text}',
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Icon(
                      Icons.arrow_downward,
                      color: Colors.blue,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      '$toCurrency ${result.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }
}
```
