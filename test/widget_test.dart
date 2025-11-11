// Test básico de la aplicación Gestor de Caja

import 'package:flutter_test/flutter_test.dart';
import 'package:dancorsportgym/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Construir la aplicación y ejecutar un frame
    await tester.pumpWidget(const GestorDeCajaApp());

    // Verificar que la aplicación se carga correctamente
    expect(find.text('Gestor de Caja'), findsOneWidget);
  });
}
