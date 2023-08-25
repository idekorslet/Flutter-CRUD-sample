class Product {
  final int id;
  final String name;
  final String description;
  final int stock;
  final int price;
  final List<String> imagesPath;

  // product constructor
  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.stock,
    required this.price,
    required this.imagesPath
  });

  static Product fromJson({required Map<String, dynamic> data, List<String>? imageList}) {
    final List<String> images = imageList ?? data['images_url'];

    return Product(
      id: data["id"],
      name: data['name'],
      description: data['description'],
      stock: data['stock'],
      price: data['price'],
      imagesPath: images
    );
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     "id": id,
  //     "name": name,
  //     "description": description,
  //     "stock": stock,
  //     "price": price,
  //     "imagePath": jsonEncode(imagesPath)
  //   };
  // }
}