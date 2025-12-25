class CourtDate {
  final String id;
  final String clientId;
  final DateTime courtDate;
  final String courtName;
  final String caseNumber;
  final String? notes;
  final bool reminderOneDayBefore;
  final bool reminderOnDay;
  final bool isCompleted;
  
  CourtDate({
    required this.id,
    required this.clientId,
    required this.courtDate,
    required this.courtName,
    required this.caseNumber,
    this.notes,
    required this.reminderOneDayBefore,
    required this.reminderOnDay,
    required this.isCompleted,
  });
  
  factory CourtDate.fromJson(Map<String, dynamic> json) {
    return CourtDate(
      id: json['id'] ?? '',
      clientId: json['client_id'] ?? '',
      courtDate: DateTime.parse(json['court_date'] ?? DateTime.now().toIso8601String()),
      courtName: json['court_name'] ?? '',
      caseNumber: json['case_number'] ?? '',
      notes: json['notes'],
      reminderOneDayBefore: json['reminder_one_day_before'] ?? true,
      reminderOnDay: json['reminder_on_day'] ?? true,
      isCompleted: json['is_completed'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'court_date': courtDate.toIso8601String(),
      'court_name': courtName,
      'case_number': caseNumber,
      'notes': notes,
      'reminder_one_day_before': reminderOneDayBefore,
      'reminder_on_day': reminderOnDay,
      'is_completed': isCompleted,
    };
  }
}
