class DeleteBookingFailedException implements Exception {
  final String message;
  const DeleteBookingFailedException(this.message);

  @override
  String toString() {
    return message;
  }
}
