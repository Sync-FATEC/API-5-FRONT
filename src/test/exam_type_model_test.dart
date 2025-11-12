import 'package:flutter_test/flutter_test.dart';
import 'package:api2025/data/models/exam_type_model.dart';

void main() {
  group('ExamTypeModel', () {
    test('serializa e desserializa corretamente', () {
      final model = ExamTypeModel(
        id: '123',
        name: 'Ultrassom Abdômen',
        description: 'Exame de imagem',
        estimatedDuration: 30,
        requiredPreparation: 'Jejum de 8h',
        isActive: true,
      );

      final json = model.toJson();
      expect(json['nome'], 'Ultrassom Abdômen');
      expect(json['duracaoEstimada'], 30);
      expect(json['preparoNecessario'], 'Jejum de 8h');
      expect(json['isActive'], true);

      final parsed = ExamTypeModel.fromJson(json);
      expect(parsed.id, '123');
      expect(parsed.name, 'Ultrassom Abdômen');
      expect(parsed.estimatedDuration, 30);
      expect(parsed.requiredPreparation, 'Jejum de 8h');
      expect(parsed.isActive, true);
    });

    test('validações básicas', () {
      final invalidName = ExamTypeModel(name: '', estimatedDuration: 10, isActive: true);
      expect(invalidName.isValidName, false);

      final invalidDuration = ExamTypeModel(name: 'Teste', estimatedDuration: 0, isActive: true);
      expect(invalidDuration.isValidDuration, false);
    });
  });
}