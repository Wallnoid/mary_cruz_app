import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/loading_dialog_controller.dart';

class CommentsLoadingDialog extends StatefulWidget {
  final ValueNotifier<String> statusNotifier;
  final Function onAccept;
  final Function onReject;

  const CommentsLoadingDialog({
    super.key,
    required this.statusNotifier,
    required this.onAccept,
    required this.onReject,
  });

  @override
  _CommentsLoadingDialogState createState() => _CommentsLoadingDialogState();
}

class _CommentsLoadingDialogState extends State<CommentsLoadingDialog> {
  final LoadingDialogController _controller =
      Get.put(LoadingDialogController());

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GetBuilder<LoadingDialogController>(
              builder: (_) {
                return _controller.isProcessing
                    ? CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                      )
                    : _controller.icon;
              },
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<String>(
              valueListenable: widget.statusNotifier,
              builder: (context, value, child) {
                return Text(
                  value,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                );
              },
            ),
            GetBuilder<LoadingDialogController>(
              builder: (_) {
                return _controller.isProcessing
                    ? const SizedBox()
                    : Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.secondary,
                                    padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'Cancelar',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(color: Colors.white, fontSize: 18),
                                  ),
                                )),
                            SizedBox(width: 10),
                            Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () async {
                                    widget.onAccept();
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'Aceptar',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(color: Colors.white, fontSize: 18),
                                  ),
                                )),
                          ],
                        ),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}
