import 'package:rxdart/rxdart.dart';

// 合并两个bool stream
Stream<bool> combineBoolStream(Stream<bool> s1, Stream<bool> s2) {
  return Rx.combineLatest2<bool, bool, bool>(
    s1.startWith(false),
    s2.startWith(false),
    (a, b) => a || b,
  );
}
