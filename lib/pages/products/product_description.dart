import 'package:flutter/material.dart';
import 'package:flutter_crud/constant.dart';
import 'package:flutter_crud/controllers/products_controller.dart';
import '../../custom_widgets/custom_popup.dart';
import '../../routes.dart';

class ProductDescription extends StatelessWidget {
  /// di class ini saya gunakan ValueNotifier & ValueListenableBuilder untuk merefresh UI
  /// in this class i use ValueNotifier & ValueListenableBuilder to refresh the UI

  // final TextEditingController textController;
  // final int maxTextLength;
  // final String oldDescription;
  final dynamic data;

  ProductDescription({
    Key? key,
    // required this.textController,
    // required this.maxTextLength,
    // required this.oldDescription,
    this.data
  }) : super(key: key);

  ValueNotifier<int> currentTextLength = ValueNotifier(0);
  late TextEditingController textController;
  late int maxTextLength;
  late String oldDescription;

  @override
  Widget build(BuildContext context) {
    textController = data["controller"];
    // maxTextLength = data["maxTextLength"];
    // maxTextLength = CustomTextField.getMaxTextLength();
    // maxTextLength = CustomTextFieldController.getMaxTextLength();
    maxTextLength = Constant.maxProductDescriptionLength;
    oldDescription = data["oldDesc"];

    return SafeArea(
      child: WillPopScope(
        onWillPop: () {
          return CustomPopup.showConfirmPopup(
              context: context,
              title: "Cancel",
              content: "Are you sure to cancel edit product description?",
              cancelButtonText: 'No',
              confirmButtonText: 'Yes'
          ).then((value) {
            if (value) {
              ProductController.prodDescCtrl.text = oldDescription;
              // Routes.backToPreviousPage(context);
            }

            return value;
          });
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Product Description'),
            actions: [
              IconButton.filledTonal(
                  onPressed: () {
                    saveProductDescription(context);
                  },
                  icon: const Icon(Icons.check)
              ),
              const SizedBox(width: 10,)
            ],
          ),

          body: buildProductDescription(),
        ),
      ),
    );
  }

  void saveProductDescription(BuildContext context) {
    Routes.backToPreviousPage(context);
  }

  Widget buildProductDescription() {
    currentTextLength.value = textController.text.length;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(right: 10),
          height: 20,
          child: Row(
            children: [
              const Spacer(),
              ValueListenableBuilder(
                  valueListenable: currentTextLength,
                  builder: (BuildContext context, int value, Widget? child) {
                    // return Text('${textController.text.length}/$maxTextLength');
                    return Text('$value/$maxTextLength');
                  }
              )
            ],
          ),
        ),

        Expanded(
          child: SizedBox(
            width: double.maxFinite,
            child: Scrollbar(
              child: TextField(
                controller: textController,
                maxLength: maxTextLength,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                expands: true, // to make size = parent size
                textAlignVertical: TextAlignVertical.top, // jika tanpa border, pasangkan dengan ini supaya text dari posisi atas
                decoration: const InputDecoration(
                    counterText: "", // to hide counter max length
                    filled: true,
                    hintText: 'Write product description here...',
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    contentPadding: EdgeInsets.all(10)
                ),

                onChanged: (newValue) {
                  // print('old desc');
                  // print(oldDescription);
                  currentTextLength.value = textController.text.length;
                  // CustomTextField.currentTextLength.value = textController.text.length;
                  // CustomTextFieldController.currentTextLength.value = textController.text.length;
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}