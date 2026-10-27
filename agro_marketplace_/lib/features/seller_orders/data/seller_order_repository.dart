import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart' hide Result;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/result/result.dart';
import '../../../../core/commerce/order_lifecycle.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../shared/services/firebase_service.dart';
import '../../notifications/data/notification_repository.dart';
import '../domain/entities/seller_order.dart';

part 'seller_order_repository.g.dart';

/// Repository for handling seller order operations in Firestore.
class SellerOrderRepository {
  final FirebaseFirestore _firestore;

  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;

  SellerOrderRepository(
    this._firestore, {
    FirebaseFunctions? functions,
    FirebaseAuth? auth,
  }) : _functions =
           functions ?? FirebaseFunctions.instanceFor(region: 'asia-south1'),
       _auth = auth ?? FirebaseAuth.instance;

  /// Streams all orders assigned to a specific seller.
  Stream<List<SellerOrder>> streamSellerOrders(String sellerId) {
    return _firestore
        .collection('sellerOrders')
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .map((snapshot) {
          final orders = snapshot.docs.map((doc) {
            final data = Map<String, dynamic>.from(doc.data());
            _normalizeSchemaV2(data);
            for (final field in ['createdAt', 'updatedAt']) {
              final value = data[field];
              if (value is Timestamp) {
                data[field] = value.toDate().toIso8601String();
              }
            }
            return SellerOrder.fromJson(data);
          }).toList();
          orders.sort(
            (a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
                .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
          );
          return orders;
        });
  }

  static void _normalizeSchemaV2(Map<String, dynamic> data) {
    data['status'] ??= data['fulfilmentStatus'] ?? 'pending';
    data['parentOrderId'] ??= data['id'] ?? '';
    data['shippingAddress'] ??= _addressText(data['deliveryAddressSnapshot']);
    data['totalAmount'] ??= _minorToMajor(data['totalMinor']);
    final rawItems = data['items'];
    if (rawItems is! List) {
      data['items'] = <Map<String, dynamic>>[];
      return;
    }
    data['items'] = rawItems.map((raw) {
      final item = Map<String, dynamic>.from(raw as Map);
      item['id'] ??= item['productId'];
      item['price'] ??= _minorToMajor(item['unitPriceMinor']);
      item['quantity'] ??= 0;
      item['unit'] ??= 'unit';
      item['sellerId'] ??= data['sellerId'];
      return item;
    }).toList();
  }

  static double _minorToMajor(Object? value) =>
      value is num ? value.toDouble() / 100 : 0;

  static String _addressText(Object? value) {
    if (value is Map) {
      return [
        value['address'],
        value['city'],
        value['state'],
        value['countryCode'],
      ].whereType<String>().where((part) => part.trim().isNotEmpty).join(', ');
    }
    return value is String ? value : '';
  }

  /// Updates the status of a specific seller order.
  Future<Result<void>> updateOrderStatus({
    required String orderId,
    required String newStatus,
  }) async {
    return Result.guard(() async {
      try {
        await _functions.httpsCallable('updateTrustedSellerFulfilment').call({
          'sellerOrderId': orderId,
          'status': newStatus,
        });
      } on FirebaseFunctionsException catch (error) {
        if (error.code != 'not-found') rethrow;
        await _updateLegacyOrderStatus(orderId: orderId, newStatus: newStatus);
      }
      await _saveActorNotification(
        eventId: 'seller_order_${orderId}_$newStatus',
        title: 'Order status updated',
        message: 'Order status changed to $newStatus.',
        type: 'order_status',
        orderId: orderId,
      );
    });
  }

  Future<void> _updateLegacyOrderStatus({
    required String orderId,
    required String newStatus,
  }) async {
    final orderRef = _firestore.collection('sellerOrders').doc(orderId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(orderRef);
      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        throw const NotFoundException(message: 'Seller order was not found.');
      }
      if (data['schemaVersion'] != null) {
        throw const BusinessRuleException(
          message: 'This order requires the deployed trusted fulfilment service.',
        );
      }
      final current = data['status'] as String? ?? 'pending';
      if (!OrderLifecycle.canTransition(
        from: current,
        to: newStatus,
        actor: OrderActor.seller,
      )) {
        throw BusinessRuleException(
          message: 'Cannot move order from $current to $newStatus.',
        );
      }
      transaction.update(orderRef, {
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<Result<void>> assignTransport({
    required String orderId,
    required Map<String, dynamic> transport,
  }) async {
    return Result.guard(() async {
      try {
        await _functions.httpsCallable('assignSellerTransport').call({
          'sellerOrderId': orderId,
          'transport': transport,
        });
      } on FirebaseFunctionsException catch (error) {
        if (error.code != 'not-found') rethrow;
        await _assignLegacyTransport(orderId: orderId, transport: transport);
      }
      await _saveActorNotification(
        eventId: 'seller_delivery_${orderId}_assigned',
        title: 'Delivery assigned',
        message: 'Delivery was assigned for this order.',
        type: 'delivery',
        orderId: orderId,
      );
    });
  }

  Future<void> _assignLegacyTransport({
    required String orderId,
    required Map<String, dynamic> transport,
  }) async {
    final orderRef = _firestore.collection('sellerOrders').doc(orderId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(orderRef);
      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        throw const NotFoundException(message: 'Seller order was not found.');
      }
      if (data['schemaVersion'] != null) {
        throw const BusinessRuleException(
          message: 'This order requires the deployed trusted delivery service.',
        );
      }
      final status = data['status'] as String? ?? 'pending';
      if (status != 'ready') {
        throw BusinessRuleException(
          message: 'Delivery can be assigned only when the order is ready.',
        );
      }
      if (transport['driverName'] is! String ||
          (transport['driverName'] as String).trim().isEmpty ||
          transport['vehicleType'] is! String ||
          (transport['vehicleType'] as String).trim().isEmpty ||
          transport['vehicleNumber'] is! String ||
          (transport['vehicleNumber'] as String).trim().isEmpty) {
        throw const BusinessRuleException(
          message: 'Driver and vehicle details are required.',
        );
      }
      transaction.update(orderRef, {
        'transportAssignment': transport,
        'deliveryStage': 'assigned',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<Result<void>> updateDeliveryStage({
    required String orderId,
    required String stage,
  }) async {
    return Result.guard(() async {
      const stages = {
        'assigned',
        'picked_up',
        'in_transit',
        'delivered',
        'failed',
        'returned',
      };
      if (!stages.contains(stage)) {
        throw BusinessRuleException(message: 'Delivery stage is invalid.');
      }
      try {
        await _functions.httpsCallable('updateSellerDeliveryStage').call({
          'sellerOrderId': orderId,
          'deliveryStage': stage,
        });
      } on FirebaseFunctionsException catch (error) {
        if (error.code != 'not-found') rethrow;
        await _updateLegacyDeliveryStage(orderId: orderId, stage: stage);
      }
      await _saveActorNotification(
        eventId: 'seller_delivery_${orderId}_$stage',
        title: 'Delivery updated',
        message: 'Delivery status changed to ${stage.replaceAll('_', ' ')}.',
        type: 'delivery',
        orderId: orderId,
      );
    });
  }

  Future<void> _updateLegacyDeliveryStage({
    required String orderId,
    required String stage,
  }) async {
    final orderRef = _firestore.collection('sellerOrders').doc(orderId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(orderRef);
      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        throw const NotFoundException(message: 'Seller order was not found.');
      }
      if (data['schemaVersion'] != null) {
        throw const BusinessRuleException(
          message: 'This order requires the deployed trusted delivery service.',
        );
      }
      final current = data['deliveryStage'] as String? ?? 'assigned';
      const transitions = {
        'assigned': {'picked_up', 'failed'},
        'picked_up': {'in_transit', 'failed'},
        'in_transit': {'delivered', 'failed'},
        'failed': {'returned'},
        'delivered': <String>{},
        'returned': <String>{},
      };
      if (!transitions[current]!.contains(stage)) {
        throw BusinessRuleException(
          message: 'Cannot move delivery from $current to $stage.',
        );
      }
      transaction.update(orderRef, {
        'deliveryStage': stage,
        'updatedAt': FieldValue.serverTimestamp(),
        if (stage == 'delivered') ...{
          'status': 'delivered',
          'fulfilmentStatus': 'delivered',
          'deliveredAt': FieldValue.serverTimestamp(),
        },
      });
    });
  }

  Future<void> _saveActorNotification({
    required String eventId,
    required String title,
    required String message,
    required String type,
    required String orderId,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    try {
      await NotificationRepository(_firestore).createForUser(
        uid: uid,
        eventId: eventId,
        title: title,
        message: message,
        type: type,
        entityId: orderId,
        entityType: 'sellerOrder',
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'Seller notification could not be saved.',
        context: 'SellerOrderRepository',
        error: error,
        stackTrace: stackTrace,
        data: {'orderId': orderId, 'eventId': eventId},
      );
    }
  }
}

@riverpod
SellerOrderRepository sellerOrderRepository(Ref ref) {
  final firebase = ref.watch(firebaseServiceProvider);
  return SellerOrderRepository(firebase.firestore);
}
