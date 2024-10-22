class RetryPolicy {
  final int retrialCount;
  final Duration retryDelay;

  RetryPolicy({
    this.retrialCount = 0,
    this.retryDelay = const Duration(seconds: 1),
  });
}