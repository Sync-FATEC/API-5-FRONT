import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:api2025/ui/viewmodels/exam_types_viewmodel.dart';
import 'package:api2025/ui/views/exam_types/widgets/exam_type_form_modal.dart';
import 'package:api2025/core/services/exam_service.dart';

class _FakeExamService extends ExamService {
  @override
  Future<List<dynamic>> fetchExamTypes({String? query, bool? isActive}) async => [];
}

void main() {
  testWidgets('Form validation blocks invalid duration and shows error', (tester) async {
    final vm = ExamTypesViewModel(service: _FakeExamService() as ExamService);
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider.value(
          value: vm,
          child: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    ExamTypeFormModal.show(context);
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Fill invalid data
    await tester.enterText(find.bySemanticsLabel('Nome'), 'Teste');
    await tester.enterText(find.bySemanticsLabel('Duração estimada (min)'), '0');
    await tester.tap(find.text('Salvar'));
    await tester.pump();

    // Expect field error message
    expect(find.text('Informe um valor válido'), findsOneWidget);
  });
}