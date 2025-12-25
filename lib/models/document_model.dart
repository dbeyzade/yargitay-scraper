class ClientDocument {
  final String id;
  final String clientId;
  final String fileName;
  final String filePath;
  final String documentType; // 'reasoned_decision', 'request', 'other'
  final String? categoryId;
  final DateTime createdAt;
  final String? notes;
  
  ClientDocument({
    required this.id,
    required this.clientId,
    required this.fileName,
    required this.filePath,
    required this.documentType,
    this.categoryId,
    required this.createdAt,
    this.notes,
  });
  
  factory ClientDocument.fromJson(Map<String, dynamic> json) {
    return ClientDocument(
      id: json['id'] ?? '',
      clientId: json['client_id'] ?? '',
      fileName: json['file_name'] ?? '',
      filePath: json['file_path'] ?? '',
      documentType: json['document_type'] ?? 'other',
      categoryId: json['category_id'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      notes: json['notes'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'file_name': fileName,
      'file_path': filePath,
      'document_type': documentType,
      'category_id': categoryId,
      'created_at': createdAt.toIso8601String(),
      'notes': notes,
    };
  }
}

class DocumentCategory {
  final String id;
  final String name;
  final String? parentId;
  final List<DocumentCategory> subCategories;
  final DateTime createdAt;
  
  DocumentCategory({
    required this.id,
    required this.name,
    this.parentId,
    this.subCategories = const [],
    required this.createdAt,
  });
  
  factory DocumentCategory.fromJson(Map<String, dynamic> json) {
    return DocumentCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      parentId: json['parent_id'],
      subCategories: json['sub_categories'] != null
          ? (json['sub_categories'] as List)
              .map((e) => DocumentCategory.fromJson(e))
              .toList()
          : [],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parent_id': parentId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
