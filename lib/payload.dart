class Payload {

  static Map<String, String> insertPayload({
    required String sellerId,
    required String productName,
    required String description,
    required String price,
    required String stock,
    required String token
  }) {
    return {
      "seller_id": sellerId,
      "name": productName,
      "desc": description,
      "price": price,
      "stock": stock,
      "token": token
    };
  }

  static Map<String, String> updatePayload({
    required String sellerId,
    required String productId,
    required String newName,
    required String newDescription,
    required String newPrice,
    required String newStock,
    required String token,
    bool isEditImage = false
  }) {
    return {
      "seller_id": sellerId,
      "product_id": productId,
      "name": newName,
      "desc": newDescription,
      "price": newPrice,
      "stock": newStock,
      "token": token,
      "edit_image": isEditImage.toString()
    };
  }

  static Map<String, String> deletePayload({
    required String sellerId,
    required String token,
    required String productId,
  }) {
    return {
      "seller_id": sellerId,
      "token": token,
      "product_id": productId
    };
  }

}