import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/date_parser.dart';
import '../../domain/entities/coach_work_session_entity.dart';

class CoachWorkSessionModel extends CoachWorkSessionEntity {
  const CoachWorkSessionModel({
    required super.id,
    required super.coachId,
    super.coachName,
    required super.checkIn,
    super.checkOut,
    super.hoursWorked = 0.0,
    super.calculatedSalary = 0.0,
    required super.date,
  });

  factory CoachWorkSessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};

    return CoachWorkSessionModel(
      id: doc.id,
      coachId: data['coachId'] ?? '',
      coachName: data['coachName'],
      checkIn: parseRequiredDateTime(data['checkIn']),
      checkOut: parseSafeDateTime(data['checkOut']),
      hoursWorked: (data['hoursWorked'] as num?)?.toDouble() ?? 0.0,
      calculatedSalary: (data['calculatedSalary'] as num?)?.toDouble() ?? 0.0,
      date: parseRequiredDateTime(data['date']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'coachId': coachId,
      if (coachName != null) 'coachName': coachName,
      'checkIn': Timestamp.fromDate(checkIn),
      if (checkOut != null) 'checkOut': Timestamp.fromDate(checkOut!),
      'hoursWorked': hoursWorked,
      'calculatedSalary': calculatedSalary,
      'date': Timestamp.fromDate(date),
    };
  }
}
