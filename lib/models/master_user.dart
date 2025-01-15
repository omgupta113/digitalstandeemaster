class MasterUser {
  final String uid;
  final String email;
  final String displayName;

  MasterUser({
    required this.uid,
    required this.email,
    required this.displayName,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
    };
  }
}
