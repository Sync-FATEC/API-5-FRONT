// lib/ui/views/exam_types/widgets/exam_type_detail_modal.dart

import 'package:flutter/material.dart';
import '../../../../data/models/exam_type_model.dart';

class ExamTypeDetailModal extends StatelessWidget {
  final ExamTypeModel model;

  const ExamTypeDetailModal({super.key, required this.model});

  static Future<void> show(BuildContext context, ExamTypeModel model) {
    return showDialog(
      context: context,
      builder: (_) => ExamTypeDetailModal(model: model),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Detalhes do Exame'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ID: ${model.id ?? '—'}'),
          Text('Nome: ${model.name}'),
          Text('Descrição: ${model.description ?? '—'}'),
          Text('Duração estimada: ${model.estimatedDuration} min'),
          Text('Preparo necessário: ${model.requiredPreparation ?? '—'}'),
          Text('Ativo: ${model.isActive ? 'Sim' : 'Não'}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}

