import 'package:flutter_test/flutter_test.dart';
import 'package:api2025/ui/viewmodels/exam_types_viewmodel.dart';
import 'package:api2025/core/services/exam_service.dart';
import 'package:api2025/data/models/exam_type_model.dart';

class _FakeExamService extends ExamService {
  @override
  Future<List<ExamTypeModel>> fetchExamTypes({String? query, bool? isActive}) async {
    return const [];
  }

  @override
  Future<ExamTypeModel> createExamType(ExamTypeModel model) async {
    return model;
  }
}

void main() {
  group('ExamTypesViewModel', () {
    test('valida entrada inválida no cadastro', () async {
      final vm = ExamTypesViewModel(service: _FakeExamService());
      await vm.load();

      final invalid = ExamTypeModel(name: '', estimatedDuration: 0, isActive: true);
      final ok = await vm.create(invalid);
      expect(ok, false);
      expect(vm.error, isNotNull);
    });
  });
}
