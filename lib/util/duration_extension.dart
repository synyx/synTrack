extension DurationExtension on Duration {
  Duration roundUp({Duration delta = const Duration(minutes: 15)}) {
    if (compareTo(delta) < 0) {
      return delta;
    }

    if (inMilliseconds % delta.inMilliseconds == 0) {
      return this;
    }

    return Duration(
      milliseconds: inMilliseconds + delta.inMilliseconds - inMilliseconds % delta.inMilliseconds,
    );
  }
}
