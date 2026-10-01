import 'package:flutter/material.dart';

// ---------------------------------------------------------------
// Entry point: Flutter starts running your app from main().
// ---------------------------------------------------------------
void main() => runApp(const CurrencyConverterApp());

// ---------------------------------------------------------------
// Sample data: how many units of each currency equal 1 USD.
// These are PLACEHOLDER rates. Replace with a live API later.
// ---------------------------------------------------------------
const Map<String, double> ratesPerUsd = {
  'USD': 1.0,
  'EUR': 0.92,
  'GBP': 0.79,
  'INR': 83.2,
  'JPY': 149.5,
  'AUD': 1.52,
  'CAD': 1.36,
};

// ===============================================================
// STATELESS WIDGET #1: the app root.
// It never changes after being built, so it needs no state.
// ===============================================================
class CurrencyConverterApp extends StatelessWidget {
  const CurrencyConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: const ConverterScreen(),
    );
  }
}

// ===============================================================
// STATEFUL WIDGET: the screen whose data changes (amount,
// selected currencies). A StatefulWidget is split in two parts:
//   1) the widget class (immutable configuration)
//   2) the State class (holds the changing data)
// ===============================================================
class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  // --- State variables: when these change, the UI should update ---
  double _amount = 0;
  String _fromCurrency = 'USD';
  String _toCurrency = 'INR';

  // Pre-filled so the text box is not empty on start.
  final TextEditingController _controller = TextEditingController();

  // Clean up the controller when the screen is removed (avoids leaks).
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- Conversion logic ---
  // Step 1: convert the amount to USD (the common base).
  // Step 2: convert from USD to the target currency.
  double get _convertedAmount {
    final inUsd = _amount / ratesPerUsd[_fromCurrency]!;
    return inUsd * ratesPerUsd[_toCurrency]!;
  }

  // Swap the two selected currencies.
  void _swapCurrencies() {
    // setState tells Flutter: "data changed, rebuild the UI".
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Currency Converter')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- Amount input ---
            TextField(
              controller: _controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
              // Runs every time the user types a character.
              onChanged: (text) {
                setState(() {
                  // tryParse returns null if the text isn't a number.
                  _amount = double.tryParse(text) ?? 0;
                });
              },
            ),
            const SizedBox(height: 20),

            // --- Two dropdowns + swap button in one row ---
            Row(
              children: [
                Expanded(
                  child: CurrencyDropdown(
                    label: 'From',
                    value: _fromCurrency,
                    // Callback: the child tells us what the user picked.
                    onChanged: (newValue) =>
                        setState(() => _fromCurrency = newValue),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  onPressed: _swapCurrencies,
                ),
                Expanded(
                  child: CurrencyDropdown(
                    label: 'To',
                    value: _toCurrency,
                    onChanged: (newValue) =>
                        setState(() => _toCurrency = newValue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // --- Result display (stateless widget) ---
            ResultCard(
              amount: _amount,
              from: _fromCurrency,
              converted: _convertedAmount,
              to: _toCurrency,
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// STATELESS WIDGET #2: a reusable dropdown.
// It owns no data. The parent passes in the current value and a
// function to call when the user picks something new.
// ===============================================================
class CurrencyDropdown extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  const CurrencyDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // InputDecorator gives the dropdown the same outlined look as the TextField.
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          // Build one menu item for each currency code in our map.
          items: ratesPerUsd.keys
              .map((code) => DropdownMenuItem(value: code, child: Text(code)))
              .toList(),
          onChanged: (newValue) {
            if (newValue != null) onChanged(newValue);
          },
        ),
      ),
    );
  }
}

// ===============================================================
// STATELESS WIDGET #3: shows the result.
// Pure display: same inputs always give the same output.
// ===============================================================
class ResultCard extends StatelessWidget {
  final double amount;
  final String from;
  final double converted;
  final String to;

  const ResultCard({
    super.key,
    required this.amount,
    required this.from,
    required this.converted,
    required this.to,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              '${amount.toStringAsFixed(2)} $from =',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              // toStringAsFixed(2) keeps two decimal places.
              '${converted.toStringAsFixed(2)} $to',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
