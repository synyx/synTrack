extension DurationExtension on Duration {
  Duration roundUp({Duration delta = const Duration(minutes: 15)}) {
    if (this.compareTo(delta) < 0) {
      return delta;
    }

    if (this.inMilliseconds % delta.inMilliseconds == 0) {
      return this;
    }

    return Duration(
      milliseconds: this.inMilliseconds + delta.inMilliseconds - this.inMilliseconds % delta.inMilliseconds,
    );
  }
}
