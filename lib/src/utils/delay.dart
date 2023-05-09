Future<void> delay(bool addDelay, [int milisseconds = 2000]) {
  if (addDelay) {
    return Future.delayed(Duration(milliseconds: milisseconds));
  } else {
    return Future.value();
  }
}
