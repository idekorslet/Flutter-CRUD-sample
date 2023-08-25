class Constant {
  /// ==================== for product data =======================
  static const maxProductNameLength = 100;
  static const maxProductDescriptionLength = 1000;
  static const minProductPrice = 1;
  static const maxProductPrice = 200000000; // 200,000,000
  static const maxProductStock = 10000;
  static const currencySymbol = 'Rp';

  /// ================= for image picker ==========================
  static const maxAllowedImage = 7;

  /// ===================== for server ============================
  static const connectionTimeout = 15; // in second
  // static const host = "http://192.168.227.86/api"; // http://10.0.2.2/api --> emulator, http://ip address/api --> real device
  static String get getUrl => '/get_data.php';
  static String get putUrl => '/edit_data.php';
  static String get postUrl => '/insert_data.php';
  static String get deleteUrl => '/delete_data.php';

  // static String token = "seller1-token-123456789";
  // static String sellerId = 1.toString();

}