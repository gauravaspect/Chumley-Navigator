import 'package:flutter/material.dart';

/// Data and controller holder for an individual circuit in the EICR form.
class EicrCircuit {
  String? description;
  String? wiring;
  String? refMethod;
  String? csaLive;
  String? csaNeutral;
  String? csaCpc;
  String? ocpdType;
  String? ocpdRating;
  String? ocpdBreaking;
  String? rcdFitted;
  String? continuityMethod;
  String? irVoltage;
  String? polarity;
  String? afdd;
  String? spd;

  final dbRef = TextEditingController();
  final way = TextEditingController();
  final points = TextEditingController();
  final ocpdBs = TextEditingController();
  final maxZs = TextEditingController();
  final continuityReading = TextEditingController();
  final irLl = TextEditingController();
  final irLe = TextEditingController();
  final irNe = TextEditingController();
  final measuredZs = TextEditingController();
  final remarks = TextEditingController();

  void dispose() {
    for (final c in [
      dbRef,
      way,
      points,
      ocpdBs,
      maxZs,
      continuityReading,
      irLl,
      irLe,
      irNe,
      measuredZs,
      remarks,
    ]) {
      c.dispose();
    }
  }
}
