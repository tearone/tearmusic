class WillPopProvider {
  bool Function()? _popper;

  bool Function()? get popper => _popper;

  void registerPopper(bool Function() value) {
    _popper = value;
  }
}
