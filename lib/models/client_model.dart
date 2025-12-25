class Client {
  final String id;
  final String tcNo;
  final String firstName;
  final String lastName;
  final String? photoUrl;
  final String phoneNumber;
  final String address;
  final String? vasiName;
  final String? vasiPhone;
  final double agreedAmount;
  final double paidAmount;
  final double debt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? notes;
  final String? birthDate;
  final String? birthPlace;
  final String? motherName;
  final String? fatherName;
  final String? idSerialNo;
  
  Client({
    required this.id,
    required this.tcNo,
    required this.firstName,
    required this.lastName,
    this.photoUrl,
    required this.phoneNumber,
    required this.address,
    this.vasiName,
    this.vasiPhone,
    required this.agreedAmount,
    required this.paidAmount,
    required this.debt,
    required this.createdAt,
    this.updatedAt,
    this.notes,
    this.birthDate,
    this.birthPlace,
    this.motherName,
    this.fatherName,
    this.idSerialNo,
  });
  
  double get remainingAmount => agreedAmount - paidAmount;
  
  String get fullName => '$firstName $lastName';
  
  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] ?? '',
      tcNo: json['tc_no'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      photoUrl: json['photo_url'],
      phoneNumber: json['phone_number'] ?? '',
      address: json['address'] ?? '',
      vasiName: json['vasi_name'],
      vasiPhone: json['vasi_phone'],
      agreedAmount: (json['agreed_amount'] ?? 0).toDouble(),
      paidAmount: (json['paid_amount'] ?? 0).toDouble(),
      debt: (json['debt'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      notes: json['notes'],
      birthDate: json['birth_date'],
      birthPlace: json['birth_place'],
      motherName: json['mother_name'],
      fatherName: json['father_name'],
      idSerialNo: json['id_serial_no'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tc_no': tcNo,
      'first_name': firstName,
      'last_name': lastName,
      'photo_url': photoUrl,
      'phone_number': phoneNumber,
      'address': address,
      'vasi_name': vasiName,
      'vasi_phone': vasiPhone,
      'agreed_amount': agreedAmount,
      'paid_amount': paidAmount,
      'debt': debt,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'notes': notes,
      'birth_date': birthDate,
      'birth_place': birthPlace,
      'mother_name': motherName,
      'father_name': fatherName,
      'id_serial_no': idSerialNo,
    };
  }
  
  Client copyWith({
    String? id,
    String? tcNo,
    String? firstName,
    String? lastName,
    String? photoUrl,
    String? phoneNumber,
    String? address,
    String? vasiName,
    String? vasiPhone,
    double? agreedAmount,
    double? paidAmount,
    double? debt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    String? birthDate,
    String? birthPlace,
    String? motherName,
    String? fatherName,
    String? idSerialNo,
  }) {
    return Client(
      id: id ?? this.id,
      tcNo: tcNo ?? this.tcNo,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      vasiName: vasiName ?? this.vasiName,
      vasiPhone: vasiPhone ?? this.vasiPhone,
      agreedAmount: agreedAmount ?? this.agreedAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      debt: debt ?? this.debt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      birthDate: birthDate ?? this.birthDate,
      birthPlace: birthPlace ?? this.birthPlace,
      motherName: motherName ?? this.motherName,
      fatherName: fatherName ?? this.fatherName,
      idSerialNo: idSerialNo ?? this.idSerialNo,
    );
  }
}
