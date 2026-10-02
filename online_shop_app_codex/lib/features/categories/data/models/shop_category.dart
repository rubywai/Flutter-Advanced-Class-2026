class ShopCategory {
  const ShopCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.parent,
    required this.description,
    required this.display,
    required this.menuOrder,
    required this.count,
    this.image,
  });

  factory ShopCategory.fromJson(Map<String, dynamic> json) {
    return ShopCategory(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      parent: (json['parent'] as num?)?.toInt() ?? 0,
      description: json['description'] as String? ?? '',
      display: json['display'] as String? ?? 'default',
      menuOrder: (json['menu_order'] as num?)?.toInt() ?? 0,
      count: (json['count'] as num?)?.toInt() ?? 0,
      image: json['image'] is Map<String, dynamic>
          ? CategoryImage.fromJson(json['image'] as Map<String, dynamic>)
          : null,
    );
  }

  final int id;
  final String name;
  final String slug;
  final int parent;
  final String description;
  final String display;
  final int menuOrder;
  final int count;
  final CategoryImage? image;
}

class CategoryImage {
  const CategoryImage({
    required this.id,
    required this.src,
    required this.name,
    required this.alt,
  });

  factory CategoryImage.fromJson(Map<String, dynamic> json) => CategoryImage(
    id: (json['id'] as num?)?.toInt() ?? 0,
    src: json['src'] as String? ?? '',
    name: json['name'] as String? ?? '',
    alt: json['alt'] as String? ?? '',
  );

  final int id;
  final String src;
  final String name;
  final String alt;
}
