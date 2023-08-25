import 'package:flutter/material.dart';
import 'package:flutter_crud/custom_widgets/info_container.dart';
import 'package:flutter_crud/services/api.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../config.dart';
import '../routes.dart';

/// ini hanyalah tampilan untuk login yang bersifat dummy
/// this is just a dummy login screen

class DummyLogin extends StatefulWidget {
  const DummyLogin({Key? key}) : super(key: key);

  @override
  State<DummyLogin> createState() => _DummyLoginState();
}

class _DummyLoginState extends State<DummyLogin> {
  final defaultHost = 'http://10.0.2.2/api';
  String selectedSeller = '1';
  Color seller1Color = Colors.blueAccent.shade100;
  Color seller2Color = Colors.transparent;
  bool isConnected = false;
  bool isConnecting = false;
  bool isFirstRun = true;
  String? errorText;
  final String baseToken = Config.token;

  TextEditingController hostCtrl = TextEditingController();

  @override
  void dispose() {
    hostCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    hostCtrl.text = defaultHost;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(18.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0x23111205),
              Color(0x98656759),
              // Color.fromARGB(110, 110, 112, 100),
              // Color.fromARGB(0, 0, 21, 24),
            ],
          )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: errorText == null ? 40 : 60,
              width: double.infinity,
              child: TextField(
                controller: hostCtrl,
                decoration: InputDecoration(
                  labelText: 'Host',
                  errorText: errorText,
                  hintText: defaultHost,
                  suffixIcon: isFirstRun
                    ? null
                    : isConnecting
                      ? const SizedBox(width: 20, height: 20,
                          child: Center(
                            child: SizedBox(
                              width: 14, height: 14,
                              child: CircularProgressIndicator()
                            )
                          )
                        )
                      : isConnected
                        ? const Icon(Icons.check, color: Colors.green,)
                        : const Icon(Icons.cancel_outlined, color: Colors.red,),
                  contentPadding: const EdgeInsets.all(10.0),
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16))
                  ),
                ),

              ),
            ),

            const SizedBox(height: 24,),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text('Select seller : ', style: TextStyle(fontSize: 16),),

                GestureDetector(
                  onTap: () {
                    selectedSeller = '1';

                    setState(() {
                      seller1Color = Colors.blueAccent.shade100;
                      seller2Color = Colors.transparent;
                    });
                  },
                  child: InfoContainer(
                    title: 'Seller 1',
                    fontSize: 14,
                    height: 34,
                    leftPadding: 10,
                    rightPadding: 10,
                    borderRadius: 16,
                    borderColor: Colors.blue.shade100,
                    color: seller1Color,
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    selectedSeller = '2';

                    setState(() {
                      seller1Color = Colors.transparent;
                      seller2Color = Colors.blueAccent.shade100;
                    });
                  },
                  child: InfoContainer(
                    title: 'Seller 2',
                    fontSize: 14,
                    height: 34,
                    leftPadding: 10,
                    rightPadding: 10,
                    borderRadius: 16,
                    borderColor: Colors.blue.shade100,
                    color: selectedSeller == '2' ? Colors.blueAccent.shade100 : Colors.transparent,
                  ),
                )

              ],
            ),

            const SizedBox(height: 50,),
            SizedBox(
              width: 180,
              height: 50,
              child: FilledButton.tonal(
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.login),
                    SizedBox(width: 15,),
                    Text('Login')
                  ],
                ),
                onPressed: () async {

                  if (isConnecting == false) {

                    setState(() {
                      isConnecting = true;
                      isFirstRun = false;
                      errorText = null;
                    });

                    Config.host = hostCtrl.text;
                    Config.sellerId = selectedSeller;
                    Config.token = "seller$selectedSeller$baseToken";

                    debugPrint('[dummy_login] Connecting to ${Config.host}');

                    final pingTests = await ApiService.getProductData(pageNo: 1);
                    await Future.delayed(const Duration(seconds: 2));

                    isConnecting = false;
                    isConnected = pingTests['info'] == "OK";

                    if (isConnected) {
                      errorText = null;
                      Fluttertoast.showToast(msg: 'You are logged in as Seller $selectedSeller');

                      if (mounted) {
                        Routes.moveToPage(context: context, keepPrevPage: false, pageName: PageName.home);
                      }

                    }
                    else {
                      errorText = 'Failed to connect';
                      Config.token = '';
                    }

                    setState(() {

                    });
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
