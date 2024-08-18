class Photo {
  final String id;
  final String? description;
  final Urls urls;
  final User user;

  Photo({
    required this.id,
    this.description,
    required this.urls,
    required this.user,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      description: json['description'] ?? 'No Description',
      urls: Urls.fromJson(json['urls']),
      user: User.fromJson(json['user']),
    );
  }
}

class Urls {
  final String regular;

  Urls({
    required this.regular,
  });

  factory Urls.fromJson(Map<String, dynamic> json) {
    return Urls(
      regular: json['regular'],
    );
  }

  get full => null;
}

class User {
  final String? name;

  User({
    this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
    );
  }
}
