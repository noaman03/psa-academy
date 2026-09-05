import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/date_parser.dart';
import '../../domain/entities/player_entity.dart';

class PlayerModel extends PlayerEntity {
  const PlayerModel({
    required super.id,
    required super.userId,
    required super.name,
    super.email = '',
    super.phone,
    required super.level,
    required super.category,
    required super.ageGroup,
    super.balance = 0.0,
    super.sessionsPaid = 0,
    super.sessionsAttended = 0,
    super.isAllowedPlayer = true,
    super.parentName,
    super.parentPhone,
    super.emergencyContact,
    super.dateOfBirth,
    super.address,
    super.medicalInfo,
    super.height,
    super.weight,
    super.position,
    required super.joinDate,
    super.lastAttendance,
    super.isActive = true,
    super.history,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> data, [String? docId]) {
    final int schemaVersion = (data['schemaVersion'] as num?)?.toInt() ?? 1;

    // Backward compatible session parsing (handle sessionPaid typo and String types)
    final rawSessionsPaid = data['sessionsPaid'] ?? data['sessionPaid'] ?? 0;
    final int rawPaidInt = rawSessionsPaid is num
        ? rawSessionsPaid.toInt()
        : int.tryParse(rawSessionsPaid.toString()) ?? 0;

    final rawSessionsAttended = data['sessionsAttended'] ?? 0;
    final int sessionsAttended = rawSessionsAttended is num
        ? rawSessionsAttended.toInt()
        : int.tryParse(rawSessionsAttended.toString()) ?? 0;

    // In legacy schema (version < 2), rawPaidInt was decremented on each attendance,
    // so it represented remaining sessions. Cumulative lifetime paid is rawPaidInt + sessionsAttended.
    final int canonicalSessionsPaid = schemaVersion >= 2
        ? rawPaidInt
        : (rawPaidInt + sessionsAttended);

    // Backward compatible balance parsing (handle paymentBalance vs balance and String types)
    final rawBalance = data['balance'] ?? data['paymentBalance'] ?? 0;
    final double balance = rawBalance is num
        ? rawBalance.toDouble()
        : double.tryParse(rawBalance.toString()) ?? 0.0;

    // User ID fallback
    final String id = docId ?? data['id'] ?? data['uid'] ?? data['userId'] ?? '';
    final String userId = data['userId'] ?? data['uid'] ?? id;

    // Level, Category, AgeGroup fallbacks
    final String level =
        data['level'] ?? data['playerLevel'] ?? 'Beginner';
    final String category =
        data['category'] ?? data['playerCategory'] ?? 'Junior';
    final String ageGroup =
        data['ageGroup'] ?? data['playerAgeGroup'] ?? 'Under 12';

    final isAllowed = data['isAllowedPlayer'] is bool
        ? data['isAllowedPlayer'] as bool
        : (data['isAllowedPlayer']?.toString().toLowerCase() == 'true');

    return PlayerModel(
      id: id,
      userId: userId,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? data['phoneNumber'],
      level: level,
      category: category,
      ageGroup: ageGroup,
      balance: balance,
      sessionsPaid: canonicalSessionsPaid,
      sessionsAttended: sessionsAttended,
      isAllowedPlayer: isAllowed,
      parentName: data['parentName'],
      parentPhone: data['parentPhone'],
      emergencyContact: data['emergencyContact'],
      dateOfBirth: DateParser.parseNullable(data['dateOfBirth'] ?? data['birthDate']),
      address: data['address'],
      medicalInfo: data['medicalInfo'],
      height: (data['height'] as num?)?.toDouble(),
      weight: (data['weight'] as num?)?.toDouble(),
      position: data['position'],
      joinDate: DateParser.parse(data['joinDate']),
      lastAttendance: DateParser.parseNullable(data['lastAttendance']),
      isActive: data['isActive'] ?? true,
      history: data['history'] is List ? data['history'] as List : null,
    );
  }

  factory PlayerModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return PlayerModel.fromJson(data, doc.id);
  }

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': 2,
      'id': id,
      'userId': userId,
      'name': name,
      'email': email,
      if (phone != null) 'phone': phone,
      'level': level,
      'category': category,
      'ageGroup': ageGroup,
      'balance': balance,
      'sessionsPaid': sessionsPaid,
      'sessionsAttended': sessionsAttended,
      'isAllowedPlayer': isAllowedPlayer,
      if (parentName != null) 'parentName': parentName,
      if (parentPhone != null) 'parentPhone': parentPhone,
      if (emergencyContact != null) 'emergencyContact': emergencyContact,
      if (dateOfBirth != null) 'dateOfBirth': Timestamp.fromDate(dateOfBirth!),
      if (address != null) 'address': address,
      if (medicalInfo != null) 'medicalInfo': medicalInfo,
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (position != null) 'position': position,
      'joinDate': Timestamp.fromDate(joinDate),
      if (lastAttendance != null)
        'lastAttendance': Timestamp.fromDate(lastAttendance!),
      'isActive': isActive,
      if (history != null) 'history': history,
    };
  }

  Map<String, dynamic> toFirestore() => toJson();

  PlayerModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? level,
    String? category,
    String? ageGroup,
    double? balance,
    int? sessionsPaid,
    int? sessionsAttended,
    bool? isAllowedPlayer,
    String? parentName,
    String? parentPhone,
    String? emergencyContact,
    DateTime? dateOfBirth,
    String? address,
    String? medicalInfo,
    double? height,
    double? weight,
    String? position,
    DateTime? joinDate,
    DateTime? lastAttendance,
    bool? isActive,
    List<dynamic>? history,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      level: level ?? this.level,
      category: category ?? this.category,
      ageGroup: ageGroup ?? this.ageGroup,
      balance: balance ?? this.balance,
      sessionsPaid: sessionsPaid ?? this.sessionsPaid,
      sessionsAttended: sessionsAttended ?? this.sessionsAttended,
      isAllowedPlayer: isAllowedPlayer ?? this.isAllowedPlayer,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      medicalInfo: medicalInfo ?? this.medicalInfo,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      position: position ?? this.position,
      joinDate: joinDate ?? this.joinDate,
      lastAttendance: lastAttendance ?? this.lastAttendance,
      isActive: isActive ?? this.isActive,
      history: history ?? this.history,
    );
  }
}
