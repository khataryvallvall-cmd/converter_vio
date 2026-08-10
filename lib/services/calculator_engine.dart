enum CalcOperator { add, subtract, multiply, divide }

class CalculatorEngine {
  String displayValue = '0';
  double? firstOperand;
  CalcOperator? operator;
  bool waitingForSecondOperand = false;

  static const int _maxDigits = 15;

  void inputDigit(String digit) {
    if (displayValue == 'Error') {
      displayValue = digit;
      firstOperand = null;
      operator = null;
      waitingForSecondOperand = false;
      return;
    }
    if (waitingForSecondOperand) {
      displayValue = digit;
      waitingForSecondOperand = false;
      if (operator == null) firstOperand = null;
    } else {
      if (displayValue == '0') {
        displayValue = digit;
      } else {
        final digitCount = displayValue.replaceAll(RegExp(r'[.,-]'), '').length;
        if (digitCount < _maxDigits) {
          displayValue += digit;
        }
      }
    }
  }

  void inputDecimal() {
    if (displayValue == 'Error') {
      displayValue = '0.';
      firstOperand = null;
      operator = null;
      waitingForSecondOperand = false;
      return;
    }
    if (waitingForSecondOperand) {
      displayValue = '0.';
      waitingForSecondOperand = false;
      return;
    }
    if (!displayValue.contains('.')) {
      displayValue += '.';
    }
  }

  void handlePercent() {
    if (displayValue == 'Error') return;
    final currentVal = double.tryParse(displayValue);
    if (currentVal == null) return;

    double result;
    if (firstOperand != null && operator != null) {
      result = (firstOperand! * currentVal) / 100;
    } else {
      result = currentVal / 100;
    }
    result = _round(result);
    displayValue = _numToStr(result);
  }

  void handleOperator(CalcOperator nextOperator) {
    if (displayValue == 'Error') return;

    final inputValue = double.tryParse(displayValue);

    if (operator != null && waitingForSecondOperand) {
      operator = nextOperator;
      return;
    }

    if (firstOperand == null && inputValue != null) {
      firstOperand = inputValue;
    } else if (operator != null && inputValue != null) {
      final result = calculate(firstOperand!, inputValue, operator!);
      if (result == null) {
        displayValue = 'Error';
        firstOperand = null;
        operator = null;
        waitingForSecondOperand = false;
        return;
      }
      displayValue = _numToStr(result);
      firstOperand = result;
    }

    waitingForSecondOperand = true;
    operator = nextOperator;
  }

  double? calculate(double a, double b, CalcOperator op) {
    double result;
    switch (op) {
      case CalcOperator.add:
        result = a + b;
        break;
      case CalcOperator.subtract:
        result = a - b;
        break;
      case CalcOperator.multiply:
        result = a * b;
        break;
      case CalcOperator.divide:
        if (b == 0) return null;
        result = a / b;
        break;
    }
    return _round(result);
  }

  void handleEqual() {
    if (displayValue == 'Error') return;
    if (operator != null && !waitingForSecondOperand) {
      final inputValue = double.tryParse(displayValue);
      if (inputValue == null) return;
      final result = calculate(firstOperand!, inputValue, operator!);
      if (result == null) {
        displayValue = 'Error';
        firstOperand = null;
        operator = null;
        waitingForSecondOperand = false;
      } else {
        displayValue = _numToStr(result);
        firstOperand = result;
        operator = null;
        waitingForSecondOperand = true;
      }
    } else if (operator == null) {
      firstOperand = null;
      waitingForSecondOperand = false;
    }
  }

  void handleClear() {
    displayValue = '0';
    firstOperand = null;
    waitingForSecondOperand = false;
    operator = null;
  }

  void handleBackspace() {
    if (displayValue == 'Error') return;
    if (waitingForSecondOperand) {
      waitingForSecondOperand = false;
      operator = null;
      return;
    }
    if (displayValue.length > 1) {
      displayValue = displayValue.substring(0, displayValue.length - 1);
      if (RegExp(r'^-?\.?$').hasMatch(displayValue)) {
        displayValue = '0';
      }
    } else {
      displayValue = '0';
    }
  }

  static double _round(double value) {
    return (value * 1e10).round() / 1e10;
  }

  static String _numToStr(double value) {
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }
    return value.toString();
  }
}
