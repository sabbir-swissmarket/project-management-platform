class Developer {
  final String id;
  final String name;
  final String email;

  Developer({
    required this.id,
    required this.name,
    required this.email,
  });

  factory Developer.fromJson(Map<String, dynamic> json) {
    return Developer(
      id: json["id"] as String,
      name: (json["name"] ?? "") as String,
      email: (json["email"] ?? "") as String,
    );
  }
}
