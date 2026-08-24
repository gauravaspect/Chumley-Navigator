/// Port of `app/live_bind.js` `jobTypeOf` + `kindOf`. Do not "improve".
enum FormKind { leak, gas, bath }

class JobTypeCoerce {
  static String coerce(String? raw) {
    final t = (raw ?? '').trim().toUpperCase();
    if (t == 'FIXED PRICE' || t == 'FIXEDPRICE') return 'FP';
    if (t == 'PM PROJECT' || t == 'PROJECT') return 'PM';
    return t;
  }
}

class FormKindResolver {
  static FormKind kindOf({
    required String? jobType,
    required String? trade,
    required String? workType,
    required String? description,
  }) {
    final tradeBlob = '${trade ?? ''} ${workType ?? ''}'.toLowerCase();
    final desc = (description ?? '').toLowerCase();
    final jt = JobTypeCoerce.coerce(jobType);
    if (jt == 'FP' || jt == 'PM') return FormKind.bath;
    if (RegExp(r'leak|detect').hasMatch(tradeBlob)) return FormKind.leak;
    if (RegExp(r'gas|boiler|heat').hasMatch(tradeBlob)) return FormKind.gas;
    if (RegExp(r'bathroom|refurb|fitting|fixed price|project').hasMatch(tradeBlob)) {
      return FormKind.bath;
    }
    if (RegExp(r'gas safety|boiler|cp12').hasMatch(desc)) return FormKind.gas;
    if (RegExp(r'refurbishment|strip out|first fix|second fix|snagging').hasMatch(desc)) {
      return FormKind.bath;
    }
    return FormKind.leak;
  }
}
