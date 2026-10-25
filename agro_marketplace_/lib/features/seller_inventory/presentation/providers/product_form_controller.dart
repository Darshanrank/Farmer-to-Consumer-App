import 'dart:io';

import 'package:uuid/uuid.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/result/result.dart';
import '../../../../shared/models/detailed_address.dart';
import '../../../../shared/models/location.dart';
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

    if (stockQuantity < 0) {
      return Result.failure(
        BusinessRuleException(message: 'Stock quantity cannot be negative.'),
      );
    }
    if (minOrderQuantity <= 0) {
      return Result.failure(
        BusinessRuleException(
          message: 'Minimum order quantity must be greater than zero.',
        ),
      );
    }
    if (!price.isFinite || price < 0) {
      return Result.failure(
        BusinessRuleException(
          message: 'Price must be a valid non-negative number.',
        ),
      );
    }

    final user = ref.read(appUserProvider).value;
    if (user == null) {
      final ex = Exception('User is not authenticated');
      state = AsyncError(ex, StackTrace.current);
      return Result.failure(
        AuthenticationException(
          message: 'User is not authenticated',
          originalError: ex,
        ),
      );
    }

    // Determine ID
    final productId = existingProduct?.id ?? const Uuid().v4();
    final sellerId = user.uid;
    DetailedAddress? sellerAddress;
    if (user.address != null) {
      sellerAddress = DetailedAddress.fromMap(user.address!);
    }

    final result = await Result.guard(() async {
      final productRepo = ref.read(productRepositoryProvider);

      List<ProductImage> finalImages = List.from(existingImages);

      // Process new images locally and convert to Blobs
      if (newImagesToUpload.isNotEmpty) {
        for (final file in newImagesToUpload) {
          final bytes = await file.readAsBytes();
          final imageId = const Uuid().v4();

          finalImages.add(
            ProductImage(
              id: imageId,
              data: bytes,
              contentType: 'image/jpeg',
              fileName: file.uri.pathSegments.last,
              uploadedAt: DateTime.now(),
            ),
          );
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
        supportsFastDelivery:
            existingProduct?.supportsFastDelivery ?? user.fastDeliveryEnabled,
        supportsRegularDelivery:
            existingProduct?.supportsRegularDelivery ??
            user.regularDeliveryEnabled,
        sellerManagedFastDelivery:
            existingProduct?.sellerManagedFastDelivery ??
            user.fastDeliveryEnabled,
        sellerCountryCode:
            existingProduct?.sellerCountryCode ??
            user.deliveryCountryCode ??
            sellerAddress?.address.normalizedCountryCode,
        sellerServiceLocation:
            existingProduct?.sellerServiceLocation ??
            (user.deliveryOrigin == null
                ? sellerAddress?.location
                : GeoLocation.fromMap(user.deliveryOrigin!)),
        fastDeliveryMinDays:
            existingProduct?.fastDeliveryMinDays ?? user.fastDeliveryMinDays,
        fastDeliveryMaxDays:
            existingProduct?.fastDeliveryMaxDays ?? user.fastDeliveryMaxDays,
        regularDeliveryMinDays:
            existingProduct?.regularDeliveryMinDays ??
            user.regularDeliveryMinDays,
        regularDeliveryMaxDays:
            existingProduct?.regularDeliveryMaxDays ??
            user.regularDeliveryMaxDays,
        fastDeliveryFee:
            existingProduct?.fastDeliveryFee ?? user.fastDeliveryFee,
        regularDeliveryFee:
            existingProduct?.regularDeliveryFee ?? user.regularDeliveryFee,
        reservedQuantity: existingProduct?.reservedQuantity ?? 0,
        soldQuantity: existingProduct?.soldQuantity ?? 0,
        createdAt: existingProduct?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (existingProduct == null) {
        final res = await productRepo.createProduct(product);
        if (res.isFailure) throw res.exceptionOrNull!;
      } else {
        final res = await productRepo.updateProduct(
          product.copyWith(stockQuantity: existingProduct.stockQuantity),
        );
        if (res.isFailure) throw res.exceptionOrNull!;
        if (stockQuantity != existingProduct.stockQuantity) {
          final inventoryResult = await productRepo.updateSellerInventory(
            productId: product.id,
            stockQuantity: stockQuantity,
          );
          if (inventoryResult.isFailure) throw inventoryResult.exceptionOrNull!;
        }
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
