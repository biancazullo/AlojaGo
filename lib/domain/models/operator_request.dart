enum OperatorRequestStatus { pending, approved, rejected }

class OperatorRequest {
  const OperatorRequest({
    required this.id,
    required this.userId,
    required this.email,
    required this.name,
    this.status = OperatorRequestStatus.pending,
    this.operatorPin = '',
  });

  final String id;
  final String userId;
  final String email;
  final String name;
  final OperatorRequestStatus status;
  final String operatorPin;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'status': status.name,
      'operatorPin': operatorPin,
    };
  }

  factory OperatorRequest.fromMap(String id, Map<String, dynamic> map) {
    return OperatorRequest(
      id: id,
      userId: (map['userId'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      status: OperatorRequestStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => OperatorRequestStatus.pending,
      ),
      operatorPin: (map['operatorPin'] ?? '').toString(),
    );
  }
}
