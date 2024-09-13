extension TakeRight<T> on Iterable<T> {
  Iterable<T> takeRight(int count) {
    final length = this.length;
    final start = length - count;
    return this.skip(start > 0 ? start : 0);
  }
}