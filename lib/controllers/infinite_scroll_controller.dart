import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../models/product_model.dart';

class InfiniteScrollController {
  static final PagingController<int, Product> pagingController = PagingController(firstPageKey: 1);
  static final PagingController<int, Product> pagingSearchController = PagingController(firstPageKey: 1);
}