// lib/app/data/models/store_model.dart
class StoreModel {
  final String storeID;
  final String storeName;
  final bool isActive;
  // Você pode adicionar os campos 'images' se quiser mostrar logos das lojas
  // final Map<String, String>? images;

  StoreModel({
    required this.storeID,
    required this.storeName,
    required this.isActive,
    // this.images,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      storeID: json['storeID'] as String? ?? '',
      storeName: json['storeName'] as String? ?? 'Loja Desconhecida',
      isActive: (json['isActive'] as int? ?? 0) == 1,
      // images: json['images'] != null ? Map<String, String>.from(json['images']) : null,
    );
  }

  // Para facilitar o uso em Dropdowns ou listas, se necessário
  @override
  String toString() => storeName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreModel &&
          runtimeType == other.runtimeType &&
          storeID == other.storeID;

  @override
  int get hashCode => storeID.hashCode;
}