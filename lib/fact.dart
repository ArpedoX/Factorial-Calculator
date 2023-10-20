import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  final TextEditingController numberController = TextEditingController();
  List<String> factorialResult = [];

  bool showHeart = false;
  bool calculating = false;

  void calculateFactorial(BuildContext context) {
    String input = numberController.text;
    if (input.isNotEmpty) {
      int? n = int.tryParse(input);
      if (n != null) {
        setState(() {
          factorialResult.clear();
          factorialResult.add("Calculating...");
          calculating = true;
        });

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async {
                return !calculating;
              },
              child: const Dialog(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10.0),
                      Text("Calculating..."),
                      SizedBox(height: 10.0),
                    ],
                  ),
                ),
              ),
            );
          },
        );

        Future.delayed(
          Duration(
            seconds: n < 1000
                ? 1
                : (n >= 1000 && n <= 5000
                        ? 2
                        : (n > 5000 && n <= 10000 ? 3.8 : 6))
                    .toInt(),
          ),
          () {
            if (calculating) {
              BigInt factorial = BigInt.one;
              for (BigInt i = BigInt.one;
                  i <= BigInt.from(n);
                  i += BigInt.one) {
                factorial *= i;
              }
              int zeroCount = countTrailingZeros(factorial);
              int digitCount = countDigits(factorial);
              setState(() {
                factorialResult.clear();
                factorialResult.add(
                    "Trailing zeros: $zeroCount \nDigit count $digitCount");
                factorialResult.add("$factorial");
                calculating = false;
              });
              Navigator.of(context).pop();
            }
          },
        );
      } else {
        showValidationDialog(context, 'Please enter a valid number!');
      }
    } else {
      showValidationDialog(context, 'Please enter a number!');
    }
  }

  int countTrailingZeros(BigInt number) {
    int zeroCount = 0;

    while (number % BigInt.from(10) == BigInt.zero) {
      zeroCount++;
      number ~/= BigInt.from(10);
    }

    return zeroCount;
  }

  int countDigits(BigInt number) {
    return number.toString().length;
  }

  Future<void> showValidationDialog(BuildContext context, String message) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Validation Error'),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Copied to clipboard!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black),
        ),
        duration: Duration(milliseconds: 1500),
        backgroundColor: Colors.white70,
      ),
    );
  }

  void restart(BuildContext context) {
    setState(() {
      numberController.clear();
      factorialResult.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Big Factors'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  showHeart = true;
                  Future.delayed(const Duration(seconds: 2), () {
                    setState(() {
                      showHeart = false;
                    });
                  });
                });
              },
              child: const FlutterLogo(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Enter a number to calculate factorial:',
                  style: TextStyle(fontSize: 18.0),
                ),
                const SizedBox(height: 10.0),
                TextField(
                  controller: numberController,
                  keyboardType: TextInputType.number,
                  onSubmitted: (value) {
                    calculateFactorial(context);
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Number',
                  ),
                ),
                const SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: () {
                    calculateFactorial(context);
                  },
                  child: const Text('Calculate'),
                ),
                const SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: () {
                    restart(context);
                  },
                  child: const Icon(Icons.rotate_left),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: factorialResult.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(factorialResult[index]),
                  onTap: () {
                    copyToClipboard(factorialResult[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Visibility(
        visible: showHeart,
        child: FloatingActionButton(
          child: const Icon(
            Icons.favorite,
            color: Colors.red,
          ),
          onPressed: () {},
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
