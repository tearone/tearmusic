double rangeProgress({
  required final double a,
  required final double b,
  required final double c,
}) {
  return c * (b - a) + a;
}

double progressValue({
  required final double min,
  required final double max,
  required final double value,
}) {
  return (value - min) / (max - min);
}

double norm(double val, double minVal, double maxVal, double newMin, double newMax) {
  return newMin + (val - minVal) * (newMax - newMin) / (maxVal - minVal);
}

double inverseAboveOne(double n) {
  if (n > 1) return (1 - (1 - n) * -1);
  return n;
}
