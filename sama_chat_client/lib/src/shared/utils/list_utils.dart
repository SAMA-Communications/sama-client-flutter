extension ListGetExtension<T> on List<T> {
  T? tryGet(int index) {
    return index >= 0 && index < length ? this[index] : null;
  }
}
