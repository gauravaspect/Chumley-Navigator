import 'package:chumley_navigator/screens/forms/eicr/models/eicr_circuit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EicrCircuit Tests', () {
    test(
      'EicrCircuit initializes with controllers and default null fields',
      () {
        final circuit = EicrCircuit();

        expect(circuit.description, isNull);
        expect(circuit.wiring, isNull);
        expect(circuit.dbRef.text, isEmpty);
        expect(circuit.way.text, isEmpty);
        expect(circuit.points.text, isEmpty);
        expect(circuit.measuredZs.text, isEmpty);

        circuit.description = 'Ring Main Sockets';
        circuit.dbRef.text = 'DB-1';
        circuit.way.text = '3';
        circuit.measuredZs.text = '0.34';

        expect(circuit.description, 'Ring Main Sockets');
        expect(circuit.dbRef.text, 'DB-1');
        expect(circuit.way.text, '3');
        expect(circuit.measuredZs.text, '0.34');

        circuit.dispose();
      },
    );
  });
}
