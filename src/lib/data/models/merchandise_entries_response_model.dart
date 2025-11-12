import 'merchandise_type_model.dart';
import 'merchandise_with_batch_model.dart';

class MerchandiseEntriesResponseModel {
  final bool success;
  final MerchandiseEntriesDataModel data;
  final String message;

  MerchandiseEntriesResponseModel({
    required this.success,
    required this.data,
    required this.message,
  });

  factory MerchandiseEntriesResponseModel.fromJson(Map<String, dynamic> json) {
    return MerchandiseEntriesResponseModel(
      success: json['success'] ?? false,
      data: MerchandiseEntriesDataModel.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
      'message': message,
    };
  }
}

class MerchandiseEntriesDataModel {
  final MerchandiseTypeModel merchandiseType;
  final List<MerchandiseWithBatchModel> merchandises;

  MerchandiseEntriesDataModel({
    required this.merchandiseType,
    required this.merchandises,
  });

  factory MerchandiseEntriesDataModel.fromJson(Map<String, dynamic> json) {
    return MerchandiseEntriesDataModel(
      merchandiseType: MerchandiseTypeModel.fromJson(json['merchandiseType'] ?? {}),
      merchandises: (json['merchandises'] as List<dynamic>?)
          ?.map((item) => MerchandiseWithBatchModel.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'merchandiseType': merchandiseType.toJson(),
      'merchandises': merchandises.map((item) => item.toJson()).toList(),
    };
  }
}