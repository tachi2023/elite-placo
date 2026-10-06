class SiteContent {
  final int? id;
  final String type;
  final String? key;
  final String title;
  final String? description;
  final String? imageUrl;
  final int order;
  final bool visible;
  final String? publicId;

  const SiteContent({
    this.id,
    required this.type,
    this.key,
    required this.title,
    this.description,
    this.imageUrl,
    this.order = 0,
    this.visible = true,
    this.publicId,
  });

  factory SiteContent.fromJson(Map<String, dynamic> json) => SiteContent(
        id: (json['id'] as num?)?.toInt(),
        type: json['type'] as String? ?? 'SERVICE',
        key: json['cle'] as String?,
        title: json['titre'] as String? ?? '',
        description: json['description'] as String?,
        imageUrl: json['imageUrl'] as String?,
        order: (json['ordre'] as num?)?.toInt() ?? 0,
        visible: json['visible'] as bool? ?? true,
        publicId: json['publicId'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'cle': key,
        'titre': title,
        'description': description,
        'imageUrl': imageUrl,
        'ordre': order,
        'visible': visible,
        'publicId': publicId,
      };
}
