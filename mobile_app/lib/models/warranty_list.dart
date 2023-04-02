import 'package:warranty_manager_cloud/models/warranty_with_images.dart';

class WarrantyList {
  List<WarrantyWithImages> active = [];
  List<WarrantyWithImages> expiring = [];
  List<WarrantyWithImages> expired = [];

  WarrantyList({required active, required expiring, required expired});
}
