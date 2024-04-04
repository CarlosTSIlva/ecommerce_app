import 'package:ecommerce_app/src/exceptions/app_exception.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ErrorLogger {
  void logError(Object err, StackTrace? stackTrace) {
    debugPrint('''
      Error: $err
      StackTrace: $stackTrace
    ''');
  }

  void logAppException(AppException appException) {
    debugPrint('''
      Error: ${appException.message}
      StackTrace: ${appException.code}
    ''');
  }
}

final errorLoggerProvider = Provider<ErrorLogger>((ref) {
  return ErrorLogger();
});
