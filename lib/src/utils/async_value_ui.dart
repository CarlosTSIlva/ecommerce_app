import 'package:ecommerce_app/src/localization/string_hardcoded.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common_widgets/alert_dialogs.dart';

extension AsyncValueUi on AsyncValue {
  void showAlertDialogOnError(BuildContext context) {
    if (!isLoading && hasError) {
      if (context.mounted) {
        showExceptionAlertDialog(
          context: context,
          title: 'Error'.hardcoded,
          exception: error,
        );
      }
    }
  }
}
