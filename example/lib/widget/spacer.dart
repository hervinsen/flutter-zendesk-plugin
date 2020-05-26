import 'package:flutter/material.dart';

Widget SpacerVerticalSmall() {
  return const SizedBox(
    height: 12,
  );
}

Widget SpacerVerticalMedium() {
  return const SizedBox(
    height: 24,
  );
}

Widget SpacerVerticalBig() {
  return const SizedBox(
    height: 48,
  );
}

Widget SpacerVerticalCustom(double size) {
  return SizedBox(
    height: size,
  );
}

Widget SpacerHorizontalSmall() {
  return const SizedBox(
    width: 8,
  );
}

Widget SpacerHorizontalMedium() {
  return const SizedBox(
    height: 16,
  );
}

Widget HorizontalBig() {
  return const SizedBox(
    width: 32,
  );
}

Widget SpacerHorizontalCustom(double size) {
  return SizedBox(
    width: size,
  );
}
