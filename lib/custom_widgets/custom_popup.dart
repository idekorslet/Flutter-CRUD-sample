import 'package:flutter/material.dart';

class CustomPopup {
  static bool _status = false;
  static bool _asForm = false;

  static bool get status => _status;

  static Widget _defaultButton(BuildContext context, String btnText) {
    return _baseButton(
        context: context,
        buttonText: btnText,
        onPressed: () {
          Navigator.pop(context);
        }
    );
  }

  static Widget _cancelButton({required BuildContext context, String? buttonText, VoidCallback? onPressed}) {
    return _baseButton(
      context: context,
      buttonText: buttonText,
      onPressed: () {
        _status = false;
        Navigator.of(context).pop(false);
        onPressed;
      }
    );
  }

  static Widget _confirmButton({required BuildContext context, String? buttonText, VoidCallback? onPressed}) {
    return _baseButton(
      context: context,
      buttonText: buttonText,
      onPressed: () {
        _status = true;
        Navigator.of(context).pop(true);
        onPressed;
      }
    );
  }

  static Widget _baseButton({required BuildContext context, String? buttonText, VoidCallback? onPressed}) {
    return FilledButton.tonal(
      child: Text(buttonText!),
      onPressed:  () {
        onPressed!();
      },
    );
  }

  static Future<bool> showConfirmPopup({
    required BuildContext context,
    String title="Confirm",
    String? content,
    String cancelButtonText="Cancel",
    VoidCallback? onButtonCancelPressed,
    String confirmButtonText="Continue",
    VoidCallback? onButtonConfirmPressed,
    bool keepBarrier = false,
    Widget? child,
    bool asForm=false,
  }) async {
    _status = false;
    _asForm = asForm;

    return await _showBasePopUp(
        keepBarrier: keepBarrier,
        context: context,
        title: title,
        content: content,
        actions: [
          child ?? const SizedBox(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _cancelButton(context: context, buttonText: cancelButtonText, onPressed: onButtonCancelPressed),
              const SizedBox(width: 20,),
              _confirmButton(context: context, buttonText: confirmButtonText, onPressed: onButtonConfirmPressed),
            ],
          )
        ]
    ).then((value) {
      // print('option selected, value: $value status: $status');
      return status;
    });
  }

  static Future<bool> showDefaultPopup({
    required String title,
    required String content,
    required BuildContext context,
    List<Widget>? action,
    bool keepBarrier = false
  }) async {
    return await _showBasePopUp(
      keepBarrier: keepBarrier,
      context: context,
      title: title,
      content: content,
      actions: action ?? [_defaultButton(context, "OK")]
    );
  }

  static showProcessLoading({
    required BuildContext context,
  }) async {
    return await _showBasePopUp(
      keepBarrier: true,
      context: context,
      actions: [_circularLoading()]
    );
  }

  static Widget _circularLoading() {
    return const Center(
      child: Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 10,),
          Text('Processing...')
        ],
      ),
    );
  }

  static Future<bool> _showBasePopUp({
    required BuildContext context,
    String? title,
    String? content,
    bool keepBarrier = false,
    required List<Widget> actions
  }) async {
    return await showDialog(
      barrierDismissible: !keepBarrier,
      context: context,
      builder: (ctx) {
        return WillPopScope(
          onWillPop: () async {
            return !keepBarrier;
          },
          child: AlertDialog(
              // insetPadding: content == null ? const EdgeInsets.symmetric(horizontal: 120) : EdgeInsets.zero,
              insetPadding: EdgeInsets.symmetric(horizontal: content == null ? (_asForm ? 50 : 120) : 50),
              title: title == null ? null : Text(title, style: const TextStyle(fontSize: 20),),
              content: content == null ? null : Text(content),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))
              ),
              titlePadding: const EdgeInsets.only(left: 18, top: 8),
              actionsPadding: const EdgeInsets.only(bottom: 8, right: 12, top: 8),
              actions: actions,
          ),
        );
      },
    ).then((value) {
      return value ?? false; // the value of "value" is taken from Navigator.of(context).pop(true/false);
    });
  }
}