class Payment {
  final String id;
  final String clientId;
  final double amount;
  final DateTime paymentDate;
  final String? description;
  final String paymentType; // 'payment', 'expense', 'court_fee', 'file_expense'
  final bool isIncome;
  
  Payment({
    required this.id,
    required this.clientId,
    required this.amount,
    required this.paymentDate,
    this.description,
    required this.paymentType,
    required this.isIncome,
  });
  
  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? '',
      clientId: json['client_id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      paymentDate: DateTime.parse(json['payment_date'] ?? DateTime.now().toIso8601String()),
      description: json['description'],
      paymentType: json['payment_type'] ?? 'payment',
      isIncome: json['is_income'] ?? true,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'amount': amount,
      'payment_date': paymentDate.toIso8601String(),
      'description': description,
      'payment_type': paymentType,
      'is_income': isIncome,
    };
  }
}

class PaymentCommitment {
  final String id;
  final String clientId;
  final double amount;
  final DateTime commitmentDate;
  final bool isCompleted;
  final bool hasAlarm;
  final String? notes;
  
  PaymentCommitment({
    required this.id,
    required this.clientId,
    required this.amount,
    required this.commitmentDate,
    required this.isCompleted,
    required this.hasAlarm,
    this.notes,
  });
  
  factory PaymentCommitment.fromJson(Map<String, dynamic> json) {
    return PaymentCommitment(
      id: json['id'] ?? '',
      clientId: json['client_id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      commitmentDate: DateTime.parse(json['commitment_date'] ?? DateTime.now().toIso8601String()),
      isCompleted: json['is_completed'] ?? false,
      hasAlarm: json['has_alarm'] ?? false,
      notes: json['notes'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'amount': amount,
      'commitment_date': commitmentDate.toIso8601String(),
      'is_completed': isCompleted,
      'has_alarm': hasAlarm,
      'notes': notes,
    };
  }
}
