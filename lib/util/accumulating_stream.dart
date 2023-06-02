import 'dart:async';

class AccumulatingStream<T> extends Stream<List<T>> {
  late final StreamSubscription<T> _sub;
  final _accumulatingController = StreamController<List<T>>.broadcast();
  final _list = <T>[];

  AccumulatingStream(Stream<T> sourceStream) {
    _sub = sourceStream.listen((data) {
      _list.add(data);
      _accumulatingController.add(_list);
    }, onError: (error) {
      _accumulatingController.addError(error);
    }, onDone: () {
      close();
    });
  }

  @override
  StreamSubscription<List<T>> listen(void Function(List<T> list)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    final sub = _accumulatingController.stream.listen(onData, onError: onError, onDone: onDone);
    if (onData != null) onData(_list);
    return sub;
  }

  Future<void> close() async {
    try {
      await _sub.cancel();

      if (!_accumulatingController.isClosed) {
        await _accumulatingController.close();
      }
    } catch (e) {
      // noop
    } finally {
      _list.clear();
    }
  }
}
