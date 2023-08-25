import 'package:flutter/material.dart';
import 'package:flutter_crud/constant.dart';
import 'package:flutter_crud/controllers/products_controller.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../routes.dart';
import '../utils.dart';

/// kelas basis untuk tampilan input ketika input data baru atapun edit data
/// this class is as base of UI for input new data or edit data

class InputFormBuilder extends StatefulWidget {
  const InputFormBuilder({Key? key}) : super(key: key);

  @override
  State<InputFormBuilder> createState() => _InputFormBuilderState();
}

class _InputFormBuilderState extends State<InputFormBuilder> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey();

  final double _defaultHeight = 36.0;
  final double _defaultErrorHeightSize = 24.0;
  final double _counterTextHeight = 20;

  late final double _maxHeightErrorSize = _defaultHeight + _defaultErrorHeightSize;
  late double _productNameHeightSize = _defaultHeight;
  late double _priceHeightSize = _defaultHeight;
  late double _stockHeightSize = _defaultHeight;

  bool isDescriptionValid = false;
  String? priceErrorText;
  String? stockErrorText;

  final String formattedMaxStock = Utils.formatAmount(value: Constant.maxProductStock.toString());
  final String formattedMaxPrice = Utils.formatAmount(value: Constant.maxProductPrice.toString());

  @override
  void initState() {
    super.initState();
    debugPrint('[input_form_builder] init');
    InputValidatorHelper(
        formKey: _formKey,
        setState: setState,
        defaultHeight: _defaultHeight,
        maxHeightErrorSize: _maxHeightErrorSize,
        // productNameHeightSize: _productNameHeightSize,
        priceErrorText: priceErrorText,
        priceHeightSize: _priceHeightSize,
        stockErrorText: stockErrorText,
        stockHeightSize: _stockHeightSize
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildInputForm(context);
  }

  Widget _buildInputForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FormBuilder(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ******************************* Product name Input ***************************** ///
            Container(
              height: _productNameHeightSize + _counterTextHeight,
              width: double.infinity,
              // decoration: BoxDecoration(
                // border: Border.all(color: Colors.red)
              // ),
              constraints: BoxConstraints(maxHeight: _maxHeightErrorSize + 10),
              margin: const EdgeInsets.symmetric(vertical: 14.0),
              child: FormBuilderTextField(
                name: 'name',
                controller: ProductController.prodNameCtrl,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                maxLength: Constant.maxProductNameLength,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  contentPadding: const EdgeInsets.only(left: 10),
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.highlight_remove),
                    onPressed: () {
                      if (ProductController.prodNameCtrl.text.isNotEmpty) {
                        ProductController.prodNameCtrl.clear();
                        InputValidatorHelper.productNameValidation('');
                      }
                    },
                  ),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.minLength(3, errorText: 'Please add min 3 characters')
                ]),
                onChanged: (val) {
                  InputValidatorHelper.productNameValidation(val ?? '');
                },
              ),
            ),

            /// ******************************* Product description input ***************************** ///
            FormBuilderTextField(
              name: 'desc',
              controller: ProductController.prodDescCtrl,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              maxLength: Constant.maxProductDescriptionLength,
              decoration: InputDecoration(
                labelText: 'Description',
                contentPadding: const EdgeInsets.all(10.0),
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))
                ),

                suffixIcon: Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.fullscreen),
                      onPressed: () {
                        showDescriptionInFullScreen();
                      },
                    ),

                    IconButton(
                      icon: const Icon(Icons.highlight_remove),
                      onPressed: () {
                        if (ProductController.prodDescCtrl.text.isNotEmpty) {
                          ProductController.prodDescCtrl.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
              minLines: 3,
              maxLines: 5,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.minLength(3, errorText: 'Please add min 3 characters')
              ]),
              onChanged: (val) {
                isDescriptionValid = val!.length >= 3;
              },
            ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ******************************* Price Input ***************************** ///
                Container(
                  height: _priceHeightSize,
                  width: 200,
                  margin: const EdgeInsets.symmetric(vertical: 14.0),
                  child: FormBuilderTextField(
                    name: 'price',
                    maxLength: 11,
                    controller: ProductController.priceCtrl,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    // textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      labelText: 'Price',
                      counterText: '', // to hide max length text
                      errorText: priceErrorText,
                      contentPadding: const EdgeInsets.only(left: 10),
                      // isCollapsed: true,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.min(Constant.minProductPrice, errorText: 'Price min is: ${Constant.currencySymbol} ${Constant.minProductPrice}'),
                      FormBuilderValidators.minWordsCount(1, errorText: 'Please fill the product price'),
                      // FormBuilderValidators.integer(errorText: 'Please input numeric only')
                    ]),

                    inputFormatters: [
                      CurrencyInputFormatter(
                        // leadingSymbol: Constant.currencySymbol,
                          mantissaLength: 0
                      )
                    ],
                    onChanged: (val) {
                      InputValidatorHelper.priceValidation(val);
                      priceErrorText = InputValidatorHelper.getPriceErrorText;
                      _priceHeightSize = InputValidatorHelper.getPriceHeightSize;
                    },

                    onSaved: (val) {
                      InputValidatorHelper.priceValidation(val);
                      // priceErrorText = InputValidatorHelper.getPriceErrorText;
                      _priceHeightSize = InputValidatorHelper.getPriceHeightSize;
                    },

                  ),
                ),

                const Expanded(child: SizedBox()),

                /// ******************************* Stock Input ***************************** ///
                Container(
                  height: _stockHeightSize,
                  width: 150,
                  margin: const EdgeInsets.symmetric(vertical: 14.0),
                  child: FormBuilderTextField(
                    name: 'stock',
                    controller: ProductController.stockCtrl,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: 'Stock',
                      counterText: '', // to hide max length text
                      errorText: stockErrorText,
                      contentPadding: const EdgeInsets.only(left: 10),
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: FormBuilderValidators.compose([
                      // FormBuilderValidators.integer(errorText: 'Please input numeric only')
                      FormBuilderValidators.min(0, errorText: 'Stock from 0 to $formattedMaxStock'),
                      FormBuilderValidators.minWordsCount(1, errorText: 'Please fill the stock'),
                      // FormBuilderValidators.max(Constant.maxProductStock, errorText: '0 to ${Utils.formatAmount(value: Constant.maxProductStock.toString())}'),
                    ]),

                    inputFormatters: [
                      CurrencyInputFormatter(
                        mantissaLength: 0,
                      )
                    ],
                    onChanged: (val) {
                      InputValidatorHelper.stockValidation(val);
                      stockErrorText = InputValidatorHelper.getStockErrorText;
                      _stockHeightSize = InputValidatorHelper.getStockHeightSize;
                    },

                    onSaved: (val) {
                      InputValidatorHelper.stockValidation(val);
                      _stockHeightSize = InputValidatorHelper.getStockHeightSize;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void Function()? showDescriptionInFullScreen() {

    final data = {
      "controller": ProductController.prodDescCtrl,
      "oldDesc": ProductController.prodDescCtrl.text
    };

    Routes.moveToPage(
        pageName: PageName.productDescription,
        data: data,
        context: context,
        setState: setState
    );

    return null;
  }
}

/// ****************************** class to help for input validation ************************ ///
class InputValidatorHelper {
  static late GlobalKey<FormBuilderState> _formKey;
  static late Function _setState;
  static late double _defaultHeight;
  static late double _maxHeightErrorSize;
  // static late double _productNameHeightSize;
  static late double _priceHeightSize;
  static late double _stockHeightSize;

  static String? _priceErrorText;
  static String? _stockErrorText;

  static bool isPriceValid = false;
  static bool isStockValid = false;
  static bool isNameValid = false;
  static bool isDescriptionValid = false;
  static int numericPrice = 0;
  static int numericStock = 0;
  static late bool _isInputValid;

  static final String formattedMaxPrice = Utils.formatAmount(value: Constant.maxProductPrice.toString());
  static final String formattedMaxStock = Utils.formatAmount(value: Constant.maxProductStock.toString());

  InputValidatorHelper({
    required GlobalKey<FormBuilderState> formKey,
    required Function setState,
    required double defaultHeight,
    required double maxHeightErrorSize,
    // required double productNameHeightSize,
    required double priceHeightSize,
    required double stockHeightSize,
    required String? priceErrorText,
    required String? stockErrorText,
  }) {
    _formKey = formKey;
    _setState = setState;
    _defaultHeight = defaultHeight;
    _maxHeightErrorSize = maxHeightErrorSize;
    // _productNameHeightSize = productNameHeightSize;
    _priceHeightSize = priceHeightSize;
    _priceErrorText = priceErrorText;
    _stockErrorText = stockErrorText;
  }


  static const minPriceText = 'Price min is ${Constant.currencySymbol} ${Constant.minProductPrice}';

  static String? get getPriceErrorText => _priceErrorText;
  static double get getPriceHeightSize => _priceHeightSize;

  static String? get getStockErrorText => _stockErrorText;
  static double get getStockHeightSize => _stockHeightSize;

  static bool get isInputValid => _isInputValid;

  static void productNameValidation(String value) {
    isNameValid = value.length >= 3;
    // _productNameHeightSize = isNameValid ? _defaultHeight : _maxHeightErrorSize;
  }

  static void productDescriptionValidation(String value) {
    isDescriptionValid = value.length >= 3;
    // _productNameHeightSize = isNameValid ? _defaultHeight : _maxHeightErrorSize;
  }

  static void priceValidation(String? value) {
    final priceString = (value == null || value.isEmpty) ? '0' : value;
    // ProductController.priceCtrl.text = priceString;

    numericPrice = int.parse(Utils.removeAllCharExceptNumbers(currencyString: priceString));
    isPriceValid = numericPrice > 0 && numericPrice <= Constant.maxProductPrice;
    _priceHeightSize = isPriceValid ? _defaultHeight : _maxHeightErrorSize;

    _priceErrorText = isPriceValid ? null : (numericPrice == 0 ? minPriceText : 'Max price is $formattedMaxPrice');
    // print('_priceErrorText: $_priceErrorText');
    _setState(() {});
  }

  static void stockValidation(String? value) {
    final stockString = value ?? '';
    // ProductController.stockCtrl.text = stockString;

    numericStock = int.parse(Utils.removeAllCharExceptNumbers(currencyString: stockString == '' ? '0' : stockString));
    isStockValid = (numericStock > -1 && numericStock <= Constant.maxProductStock) && stockString.isNotEmpty;
    _stockHeightSize = isStockValid ? _defaultHeight : _maxHeightErrorSize;
    _stockErrorText = isStockValid ? null : 'Stock from 0 to $formattedMaxStock';
    _setState(() {});
  }

  static void checkValidation() {
    _formKey.currentState?.saveAndValidate();
    final inputData = _formKey.currentState?.instantValue;
    debugPrint(inputData.toString());

    productNameValidation(inputData?['name'] ?? '');
    productDescriptionValidation(inputData?['desc'] ?? '');
    priceValidation(inputData?['price'] ?? '0');
    // priceValidation(inputData?['stock'] ?? '0');

    _isInputValid = false;

    if (isNameValid && isDescriptionValid && isPriceValid && isStockValid) {
      _isInputValid = true;
    }
  }
}