class Content {
  final String id;
  final String name;
  final String type; // 'pdf', 'video', 'image'
  final String url;
  final int displayDuration; // in seconds
  final int sequence;
  final DateTime createdAt;
  final String slaveId;

  Content({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    required this.displayDuration,
    required this.sequence,
    required this.createdAt,
    required this.slaveId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'url': url,
      'displayDuration': displayDuration,
      'sequence': sequence,
      'createdAt': createdAt.toIso8601String(),
      'slaveId': slaveId,
    };
  }

  factory Content.fromMap(Map<String, dynamic> map) {
    return Content(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      url: map['url'],
      displayDuration: map['displayDuration'],
      sequence: map['sequence'],
      createdAt: DateTime.parse(map['createdAt']),
      slaveId: map['slaveId'],
    );
  }
}