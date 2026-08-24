import 'package:chumley_navigator/models/user_model.dart';

enum JobKind {
  bath, // Fixed Price / PM Bathroom / Refurbishment
  gas, // Gas PPM / Boiler / Heating
  leak, // Leak Detection / Default
}

class JobClassifier {
  /// Categorises a job into one of three primary flows:
  /// - `bath` (FP / PM Works): if job_type is "FP" or "PM", or trade contains bath/refurb
  /// - `gas` (Gas PPM / Boiler): if trade/title contains gas, boiler, or heat
  /// - `leak` (Leak Detection): if trade/title contains leak, detect, or default
  static JobKind kindOf({
    String? jobType,
    String? trade,
    String? title,
    String? workType,
  }) {
    final jt = (jobType ?? '').toUpperCase().trim();
    final tr = (trade ?? '').toLowerCase().trim();
    final ti = (title ?? '').toLowerCase().trim();
    final wt = (workType ?? '').toLowerCase().trim();

    // 1. Bath / FP / PM
    if (jt == 'FP' || jt == 'PM' || tr.contains('bath') || tr.contains('refurb') || ti.contains('bath') || ti.contains('refurb')) {
      return JobKind.bath;
    }

    // 2. Gas / PPM
    if (tr.contains('gas') || tr.contains('boiler') || tr.contains('heat') || ti.contains('gas') || ti.contains('boiler') || ti.contains('heat') || wt.contains('gas') || wt.contains('boiler') || wt.contains('heat')) {
      return JobKind.gas;
    }

    // 3. Leak detection / Default
    return JobKind.leak;
  }

  /// Classifies from Appointment model
  static JobKind kindOfAppointment(Appointment appointment) {
    return kindOf(
      jobType: appointment.type,
      title: appointment.title,
    );
  }

  /// Returns display label for job kind
  static String kindLabel(JobKind kind) {
    switch (kind) {
      case JobKind.bath:
        return 'Fixed Price / Project Works';
      case JobKind.gas:
        return 'Gas PPM / Boiler';
      case JobKind.leak:
        return 'Leak Detection';
    }
  }
}
