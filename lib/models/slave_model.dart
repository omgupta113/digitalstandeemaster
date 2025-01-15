class Slave {
  final String id;
  final String name;
  final bool isActive;
  final DateTime lastSeen;

  Slave({
    required this.id,
    required this.name,
    required this.isActive,
    required this.lastSeen,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isActive': isActive,
      'lastSeen': lastSeen.toIso8601String(),
    };
  }

  factory Slave.fromMap(Map<String, dynamic> map) {
    return Slave(
      id: map['id'],
      name: map['name'],
      isActive: map['isActive'],
      lastSeen: DateTime.parse(map['lastSeen']),
    );
  }
}
