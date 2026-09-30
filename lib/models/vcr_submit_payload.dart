import 'dart:io';

import 'package:equatable/equatable.dart';

class VcrSubmitFile extends Equatable {
  const VcrSubmitFile({required this.slotId, required this.file});

  final String slotId;
  final File file;

  @override
  List<Object?> get props => [slotId, file.path];
}

class VcrSubmitPayload extends Equatable {
  const VcrSubmitPayload({
    required this.vehicleId,
    required this.description,
    required this.internalNotes,
    required this.inspectionResult,
    required this.files,
  });

  final String vehicleId;
  final String description;
  final String internalNotes;
  final String inspectionResult;
  final List<VcrSubmitFile> files;

  @override
  List<Object?> get props => [
    vehicleId,
    description,
    internalNotes,
    inspectionResult,
    files,
  ];
}
