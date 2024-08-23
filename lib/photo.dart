import 'dart:convert';

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'urls': urls.toJson(),
      'user': user.toJson(),
    };
  }

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      description: json['description'],
      urls: Urls.fromJson(json['urls']),
      user: User.fromJson(json['user']),
    );
  }
}

class Urls {
  final String regular;

  Urls({required this.regular});

  Map<String, dynamic> toJson() {
    return {
      'regular': regular,
    };
  }

  factory Urls.fromJson(Map<String, dynamic> json) {
    return Urls(
      regular: json['regular'],
    );
  }
}

class User {
  final String name;

  User({required this.name});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
    );
  }
}
