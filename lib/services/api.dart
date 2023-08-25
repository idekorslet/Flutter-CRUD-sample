import 'dart:convert';
import 'package:flutter_crud/config.dart';
import 'package:flutter_crud/constant.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../controllers/product_filter_controller.dart';
import '../controllers/products_controller.dart';

enum ApiMethod {get, post, put, delete}

class ApiService {
  static String errorMessage = '';
  static int totalPage = 1;

  static Future<Map<String, dynamic>> _connectToServer({
    required String apiUrl, required ApiMethod method, Map<String, dynamic>? payload
  }) async {
    Map<String, dynamic> result = {};
    String status = '';
    var client = http.Client();

    try {
      final uri = Uri.parse(apiUrl);

      late http.Response response;

      switch (method) {
        case ApiMethod.get:
          status = 'Get data';
          response = await client.get(uri)
              .timeout(const Duration(seconds: Constant.connectionTimeout));
          break;
        case ApiMethod.post:
          status = 'Post data';
          response = await client.post(uri, body: payload);
          break;
        case ApiMethod.put:
          status = 'Edit data';
          response = await client.put(uri, body: payload);
          break;
        default:
          status = 'Delete data';
          response = await client.delete(uri, body: payload);
      }

      // print('response');
      // print(response.body);
      // var response = await client.get(uri);

      if (response.statusCode == 200) {
        // convert dari json ke list map
        // allData = List<Map>.from(jsonDecode(response.body));
        // return allData;
        result = jsonDecode(response.body);
        // return Map.from(jsonDecode(response.body));
      } else {
        throw Exception('[api] Something wrong: ${response.statusCode}');
      }
    } catch (e) {
        final errorString = '[api] error to $status: $e';

        if (errorString.contains('Future not completed')) {
          errorMessage = '(Timeout)';
        }
        else {
          errorMessage = '$status: $e';
        }

        // print(errorString);
        result = {
          "info": "NOT OK",
          "error_msg": errorMessage
        };
    }
    finally {
      client.close();
    }

    return result;
  }

  static Future<Map<String, dynamic>> loadData({required String apiUrl}) async {
    return await _connectToServer(apiUrl: apiUrl, method: ApiMethod.get);
  }

  static Future<Map<String, dynamic>> postData({required String apiUrl, required Map<String, dynamic> dataToSend}) {
    return _connectToServer(apiUrl: apiUrl, method: ApiMethod.post, payload: dataToSend);
  }

  static Future<Map<String, dynamic>> putData({required String apiUrl, required Map<String, dynamic> dataToSend}) {
    return _connectToServer(apiUrl: apiUrl, method: ApiMethod.put, payload: dataToSend);
  }

  static Future<Map<String, dynamic>> deleteData({required String apiUrl, required Map<String, dynamic> dataToSend}) {
    return _connectToServer(apiUrl: apiUrl, method: ApiMethod.delete, payload: dataToSend);
  }

  static Future<Map<String, dynamic>> getProductData({required int pageNo, String filterParams='&'}) async {
    final url = '${Config.host}${Constant.getUrl}?seller_id=${Config.sellerId}&page=$pageNo$filterParams';
    debugPrint('[api] $url');
    final result = await loadData(apiUrl: url);
    return result;
  }

  static Future<void> getDataFromServer({
    String searchParams='',
    required PagingController pagingController
  }) async {
    ProductController.isAllDataLoaded = false;

    debugPrint('[api] requesting data for page no: ${ProductController.pageNo}');
    final params = FilterController.isFilterActive ? FilterController.newFilterParamValue : searchParams;
    Map<String, dynamic> data = {};

    try {
      // if (ProductController.pageNo == 1 || ProductController.pageNo <= totalPage) {
        await getProductData(pageNo: ProductController.pageNo, filterParams: params).then((value) {
          data = value;

          return value;
        }).whenComplete(() {
          debugPrint('[api] loading data complete');
          debugPrint(data.toString());

          if (data["info"] == "OK") {
            ProductController.totalData = data["total_data"];

            totalPage = (data['total_data'] / data['data_per_page']).ceil();
            final int pageNo = data["page_no"];
            debugPrint('[api] total page: $totalPage / current page no: $pageNo');

            final isLastPage = pageNo >= totalPage;

            debugPrint('[api] is last page: $isLastPage');

            final newProduct = ProductController.processNewData(data: data["data"]);

            if (isLastPage) {
              pagingController.appendLastPage(newProduct);
            }
            else {
              pagingController.appendPage(newProduct, ProductController.pageNo);
            }

            ProductController.isAllDataLoaded = isLastPage;
          }
          else {
            throw('Failed to load data\n${data["error_msg"]}');
          }

          debugPrint('');
        });
    } catch (error) {
      debugPrint('error: $error');
      pagingController.error = error;
    }

  }

}