class Topic {
  final String id;
  final String slug;
  final String title;
  final String description;
  final String publishedAt;
  final String updatedAt;
  final String startsAt;
  final String? endsAt;
  final String visibility;
  final bool featured;
  final int totalPhotos;
  final String selfLink;
  final String htmlLink;
  final String photosLink;

  Topic({
    required this.id,
    required this.slug,
    required this.title,
    required this.description,
    required this.publishedAt,
    required this.updatedAt,
    required this.startsAt,
    this.endsAt,
    required this.visibility,
    required this.featured,
    required this.totalPhotos,
    required this.selfLink,
    required this.htmlLink,
    required this.photosLink,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'],
      slug: json['slug'],
      title: json['title'],
      description: json['description'],
      publishedAt: json['published_at'],
      updatedAt: json['updated_at'],
      startsAt: json['starts_at'],
      endsAt: json['ends_at'],
      visibility: json['visibility'],
      featured: json['featured'],
      totalPhotos: json['total_photos'],
      selfLink: json['links']['self'],
      htmlLink: json['links']['html'],
      photosLink: json['links']['photos'],
    );
  }
}
