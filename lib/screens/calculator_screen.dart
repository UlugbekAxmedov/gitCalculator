import 'package:calculator/models/calc_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  bool isView = false;
  String equation = "0";
  String result = "0";
  String expression = "";
  double equationFontSize = 38.0;
  double resultFontSize = 48.0;
  List<CalcModel> data = [];
  int index = -1;
  double response = 0;

  buttonPressed(String buttonText) {
    setState(() {
      if (RegExp(r'^[0-9]+$').hasMatch(equation) && equation.length > 14) {
       // equation = equation.substring(0, 15);
        Fluttertoast.showToast(
            msg: "You can't enter more than 15 digits!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
      if (buttonText == "C") {
        equation = "0";
        result = "0";
        response = 0;
        equationFontSize = 38.0;
        resultFontSize = 48.0;
      } else if (buttonText == "⌫") {
        equationFontSize = 48.0;
        resultFontSize = 38.0;
        equation = equation.substring(0, equation.length - 1);
        if (equation == "") {
          equation = "0";
        }
      } else if (buttonText == '%') {
        double a = double.parse(equation) / 100;
        equation = a.toString();
      } else if (buttonText == "=") {
        equationFontSize = 38.0;
        resultFontSize = 48.0;
        expression = equation;
        expression = expression.replaceAll('×', '*');
        expression = expression.replaceAll('÷', '/');
        expression = expression.replaceAll('√', 'sqrt');
        expression = expression.replaceAll('e', '2.718281828459045');

        try {
          Parser p = Parser();
          Expression exp = p.parse(expression);

          ContextModel cm = ContextModel();
          result = '${exp.evaluate(EvaluationType.REAL, cm)}';
          response = double.parse(result);
          if (equation != '0') {
            data.add(
                CalcModel(history: equation, result: double.parse(result)));
            index++;
          }
        } catch (e) {
          result = "Error";
        }
        if (index > 6) {
          data.removeAt(0);
          index--;
        }
      } else {
        equationFontSize = 48.0;
        resultFontSize = 38.0;
        if (equation == "0") {
          equation = buttonText;
        } else {
          equation = equation + buttonText;
        }
      }
    });
  }

  Widget buildButton(String buttonText, double buttonHeight, Color buttonColor,
      {required Color textColor}) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1 * buttonHeight,
      color: buttonColor,
      child: FlatButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0),
              side: const BorderSide(
                  color: Colors.white, width: 1, style: BorderStyle.solid)),
          padding: const EdgeInsets.all(16.0),
          onPressed: () => buttonPressed(buttonText),
          child: Text(
            buttonText,
            style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.normal,
                color: textColor),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Simple Calculator'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * .15,
                  margin: const EdgeInsets.only(top: 0),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: ListView(
                    children: [
                      Padding(
                        padding: equation == "0"
                            ? EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * .05,
                              )
                            : const EdgeInsets.only(top: 0),
                        child: Text(
                          equation,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: equationFontSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * .15,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: ListView(children: [
                    Text(
                      result == "Error"
                          ? result
                          : response == response.toInt()
                              ? response.toInt().toString()
                              : response.toStringAsFixed(2),
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          color: Colors.white, fontSize: resultFontSize),
                    ),
                  ]),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isView = !isView;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20.0, right: 10.0),
                    alignment: Alignment.topRight,
                    child: const Icon(
                      Icons.repeat,
                      color: Colors.grey,
                      size: 35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            child: AnimatedSwitcher(
              switchInCurve: Curves.easeInQuad,
              duration: const Duration(milliseconds: 700),
              transitionBuilder: (child, animation) => SizeTransition(
                child: child,
                sizeFactor: animation,
              ),
              child: isView ? history() : calc(),
            ),
          ),
        ],
      ),
    );
  }

  Widget history() => ListView.builder(
      itemCount: data.length,
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                  color: Colors.black,
                  border: Border.symmetric(
                      horizontal: BorderSide(width: 1.0, color: Colors.grey))),
              child: ListTile(
                title: Text(
                  data[index].history,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                  ),
                ),
                subtitle: Text(
                  data[index].result.toString(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 32,
                  ),
                ),
              ),
            ),
          ],
        );
      });

  Widget calc() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(bottom: 10.0),
          width: MediaQuery.of(context).size.width,
          child: Table(
            children: [
              TableRow(children: [
                buildButton("C", 1, Colors.redAccent, textColor: Colors.white),
                buildButton("⌫", 1, Colors.black54, textColor: Colors.orange),
                buildButton("(", 1, Colors.black54, textColor: Colors.yellow),
                buildButton(")", 1, Colors.black54, textColor: Colors.yellow),
                buildButton("÷", 1, Colors.black54, textColor: Colors.orange),
              ]),
              TableRow(children: [
                buildButton("√", 1, Colors.black54, textColor: Colors.orange),
                buildButton("7", 1, Colors.black54, textColor: Colors.white),
                buildButton("8", 1, Colors.black54, textColor: Colors.white),
                buildButton("9", 1, Colors.black54, textColor: Colors.white),
                buildButton("×", 1, Colors.black54, textColor: Colors.orange),
              ]),
              TableRow(children: [
                buildButton("^", 1, Colors.black54, textColor: Colors.orange),
                buildButton("4", 1, Colors.black54, textColor: Colors.white),
                buildButton("5", 1, Colors.black54, textColor: Colors.white),
                buildButton("6", 1, Colors.black54, textColor: Colors.white),
                buildButton("-", 1, Colors.black54, textColor: Colors.orange),
              ]),
              TableRow(children: [
                buildButton("%", 1, Colors.black54, textColor: Colors.orange),
                buildButton("1", 1, Colors.black54, textColor: Colors.white),
                buildButton("2", 1, Colors.black54, textColor: Colors.white),
                buildButton("3", 1, Colors.black54, textColor: Colors.white),
                buildButton("+", 1, Colors.black54, textColor: Colors.orange),
              ]),
              TableRow(children: [
                buildButton("e", 1, Colors.black54, textColor: Colors.orange),
                buildButton(".", 1, Colors.black54, textColor: Colors.white),
                buildButton("0", 1, Colors.black54, textColor: Colors.white),
                buildButton("00", 1, Colors.black54, textColor: Colors.white),
                buildButton("=", 1, Colors.redAccent, textColor: Colors.white),
              ]),
            ],
          ),
        ),
      ],
    );
  }

}
