extension ComparableExtends<T extends Comparable> on Comparable<T> {
  T clamp(T min, T max) {
    if (Comparable.compare(this, min) < 0) {
      return min;
    } else if (Comparable.compare(this, max) > 0) {
      return max;
    }
    return this as T;
  }
}
