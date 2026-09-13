import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kisanbazaar/models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream all products
  Stream<List<ProductModel>> streamProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }

  // Stream products by category
  Stream<List<ProductModel>> streamProductsByCategory(String category) {
    if (category == 'All') {
      return streamProducts();
    }
    return _firestore
        .collection('products')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }

  // Search products by name, description, or category
  Stream<List<ProductModel>> streamSearchProducts(String query) {
    if (query.isEmpty) {
      return Stream.value([]);
    }
    
    final lowerQuery = query.toLowerCase();
    
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data(), doc.id))
          .where((product) {
            return product.name.toLowerCase().contains(lowerQuery) || 
                   product.description.toLowerCase().contains(lowerQuery) ||
                   product.category.toLowerCase().contains(lowerQuery);
          })
          .toList();
    });
  }

  // Stream trending products (limit to 8)
  Stream<List<ProductModel>> streamTrendingProducts() {
    return _firestore
        .collection('products')
        .limit(8)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }

  // Stream deals of the day (products with a valid originalPrice that is > price)
  Stream<List<ProductModel>> streamDealsOfTheDay() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data(), doc.id))
          .where((product) => product.originalPrice != null && product.originalPrice! > product.price)
          .toList();
    });
  }
}
