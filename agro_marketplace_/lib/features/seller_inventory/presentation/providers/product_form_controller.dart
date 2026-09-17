import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/result/result.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/product_repository.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_image.dart';

part 'product_form_controller.g.dart';

@riverpod
class ProductFormController extends _$ProductFormController {
  @override
  FutureOr<void> build() {
    return null;
  }

  /// Submits the product form. If [existingProduct] is provided, it updates it.
  Future<Result<void>> submit({
    Product? existingProduct,
    required String name,
    required String description,
    required double price,
    required String unit,
    required int stockQuantity,
    required String category,
    String? brand,
    required int minOrderQuantity,
    required Map<String, dynamic> attributes,
    required List<ProductImage> existingImages,
    required List<File> newImagesToUpload,
    required String status,
  }) async {
    state = const AsyncLoading();

    final user = ref.read(authUserProvider).value;
    if (user == null) {
      final ex = Exception('User is not authenticated');
      state = AsyncError(ex, StackTrace.current);
      return Result.failure(AuthenticationException(message: 'User is not authenticated', originalError: ex));
    }

    // Determine ID
    final productId = existingProduct?.id ?? const Uuid().v4();
    final sellerId = user.uid;

    final result = await Result.guard(() async {
      final productRepo = ref.read(productRepositoryProvider);

      List<ProductImage> finalImages = List.from(existingImages);

      // Process new images locally and convert to Blobs
      if (newImagesToUpload.isNotEmpty) {
        for (final file in newImagesToUpload) {
          final bytes = await file.readAsBytes();
          final imageId = const Uuid().v4();
          
          finalImages.add(ProductImage(
            id: imageId,
            data: bytes,
            contentType: 'image/jpeg',
            fileName: file.uri.pathSegments.last,
            uploadedAt: DateTime.now(),
          ));
        }
      }

      // Construct product
      final product = Product(
        id: productId,
        sellerId: sellerId,
        name: name,
        description: description,
        price: price,
        unit: unit,
        stockQuantity: stockQuantity,
        category: category,
        brand: brand,
        minOrderQuantity: minOrderQuantity,
        attributes: attributes,
        images: finalImages,
        status: status,
        createdAt: existingProduct?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (existingProduct == null) {
        final res = await productRepo.createProduct(product);
        if (res.isFailure) throw res.exceptionOrNull!;
      } else {
        final res = await productRepo.updateProduct(product);
        if (res.isFailure) throw res.exceptionOrNull!;
      }
    });

    if (result.isSuccess) {
      state = const AsyncData(null);
    } else {
      state = AsyncError(result.exceptionOrNull!, StackTrace.current);
    }
    
    return result;
  }
}
