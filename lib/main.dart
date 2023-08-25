import 'package:flutter/material.dart';
import 'package:flutter_crud/pages/dummy_login.dart';
import 'package:flutter_crud/pages/products/my_products.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  bool isShowLoginPage = false;
  DateTime? currentBackPressTime;

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)
            .copyWith(background: const Color(0xf4f4f4f4)),

        useMaterial3: true,
      ),
      home: WillPopScope(
        onWillPop: () {
          return _exitConfirm();
        },
        // child: const MyProducts()
        child: isShowLoginPage ? const MyProducts() : const DummyLogin()
      ),
    );
  }

  Future<bool> _exitConfirm() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: "Press again to exit");

      return Future.value(false);
    }
    return Future.value(true);
  }
}

