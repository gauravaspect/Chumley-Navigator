import 'package:flutter/material.dart';

/// Holds TextEditingControllers for an individual sub-operative row in Vent Hygiene.
class SubOperativeControllers {
  SubOperativeControllers()
    : name = TextEditingController(),
      travelHours = TextEditingController(),
      totalCost = TextEditingController();

  final TextEditingController name;
  final TextEditingController travelHours;
  final TextEditingController totalCost;

  void dispose() {
    name.dispose();
    travelHours.dispose();
    totalCost.dispose();
  }

  void clear() {
    name.clear();
    travelHours.clear();
    totalCost.clear();
  }
}
