import 'package:warranty_manager_cloud/models/product.dart';

class WarrantyList {
  List<Product> active = [];
  List<Product> expiring = [];
  List<Product> expired = [];

  WarrantyList({required active, required expiring, required expired});
}
