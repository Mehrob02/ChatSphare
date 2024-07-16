// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, depend_on_referenced_packages

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

extension MyExtension on String {
  String modefy() {
    return "$this#modefied";
  }
}

extension StringExtension on String {
  bool get isPalindrome {
    String cleaned = replaceAll(RegExp(r'[\W_]+'), '').toLowerCase();
    return cleaned == cleaned.split('').reversed.join('');
  }
}

typedef MyString = String;
typedef MyList = List<int>;
typedef FormSubmitCallback = void Function(String username, String password);
typedef JsonMap = Map<String, dynamic>;

void processJsonData(JsonMap jsonData) {
  // Логика для обработки данных JSON
  if (kDebugMode) {
    print('Processing JSON data: $jsonData');
  }
}

extension ListExtension on List<num> {
  num get sum {
    return fold(0, (previousValue, element) => previousValue + element);
  }
}

mixin MyMixin {
  void myMethod(MyString string) async {
    debugPrint("${string}d");
  }

  VoidCallback method() {
    return () async {
      JsonMap data = {
        'name': 'John Doe',
        'age': 30,
        'email': 'john.doe@example.com'
      };
      processJsonData(data);
      debugPrint("called");
    };
  }
}
mixin SeconndMixin{
  void mySMethod(MyString string) async {
    debugPrint("${string}s");
    }
}
class MyClass with MyMixin, SeconndMixin{}

extension DateTimeExtension on DateTime {
  String get formattedDate {
    return "$day-$month-$year";
  }
}

void main() {
  MyClass myClass = MyClass();
  myClass.method;
  myClass.myMethod("abc".modefy());
  debugPrint("abcd".isPalindrome.toString());
  debugPrint("A man, a plan, a canal, Panama".isPalindrome.toString());
  debugPrint([1, 2, 3, 4].sum.toString());
  debugPrint(DateTime.now().formattedDate);

  // Тесты

  test('String modefy extension', () {
    expect("abc".modefy(), "abc#modefied");
  });

  test('String isPalindrome extension', () {
    expect("A man, a plan, a canal, Panama".isPalindrome, true);
    expect("Hello, World!".isPalindrome, false);
  });

  test('List<num> sum extension', () {
    expect([1, 2, 3, 4].sum, 10);
    expect([1.5, 2.5, 3.5].sum, 7.5);
  });

  test('DateTime formattedDate extension', () {
    DateTime date = DateTime(2023, 7, 10);
    expect(date.formattedDate, "10-7-2023");
  });

  test('MyMixin method', () {
    MyClass myClass = MyClass();
    expect(() async => myClass.method(), returnsNormally);
  });

  test('MyMixin myMethod', () {
    MyClass myClass = MyClass();
    expect(() async => myClass.myMethod("test"), returnsNormally);
  });
  test('List typedef', () {
    MyList myList = [1,2,4];
    expect(myList.runtimeType, List<int>);
  });
  test('SecondMixin mySMethod', () {
    MyClass myClass = MyClass();
    expect(() async => myClass.mySMethod("test"), returnsNormally);
  });
}
