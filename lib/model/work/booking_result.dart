typedef BookingId = String;

class BookingResult {
  final BookingId bookingId;
  final Duration duration;

  BookingResult({
    required this.bookingId,
    required this.duration,
  });
}