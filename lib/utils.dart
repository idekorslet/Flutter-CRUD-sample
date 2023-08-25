import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Utils {
  static DateTime? currentBackPressTime;

  static String removeAllCharExceptNumbers({required String currencyString}) {
    return currencyString.replaceAll(RegExp(r"\D"), ""); // remove all char except number
  }

  static String formatAmount({required String value}){
    /// source: https://stackoverflow.com/a/72508302/22171100
    String price = removeAllCharExceptNumbers(currencyString: value);
    String priceInText = "";
    int counter = 0;
    for (int i = (price.length - 1);  i >= 0; i--){
      counter++;
      String str = price[i];
      if ((counter % 3) != 0 && i !=0){
        priceInText = "$str$priceInText";
      } else if (i == 0 ){
        priceInText = "$str$priceInText";

      } else {
        priceInText = ",$str$priceInText";
      }
    }
    return priceInText.trim();
  }

  static hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus(); // to hide keyboard
  }

  static Future<String> getImagePathFromCache(String imageUrl) async {
    // final cache = await CacheManager.getInstance();
    final cache = DefaultCacheManager();
    final file = await cache.getSingleFile(imageUrl);
    return file.path;
  }

}