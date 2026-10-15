enum OrderActor { seller, buyer, system }

class OrderLifecycle {
  const OrderLifecycle._();

  static const sellerTransitions = <String, Set<String>>{
    'pending': {'accepted', 'rejected', 'cancelled'},
    'accepted': {'preparing', 'cancelled'},
    'preparing': {'packed', 'cancelled'},
    'packed': {'ready'},
    'ready': {'dispatched'},
    'dispatched': {'delivered'},
  };

  static bool canTransition({
    required String from,
    required String to,
    required OrderActor actor,
  }) {
    if (actor != OrderActor.seller) return false;
    return sellerTransitions[from]?.contains(to) ?? false;
  }

  static String parentStatusForSellerStatuses(Iterable<String> statuses) {
    final values = statuses.toList();
    if (values.isEmpty) return 'pending';
    if (values.every((status) => status == 'delivered')) return 'delivered';
    if (values.every((status) => status == 'cancelled')) return 'cancelled';
    if (values.any((status) => status == 'rejected')) {
      return 'partially_fulfilled';
    }
    if (values.any(
      (status) => {
        'accepted',
        'preparing',
        'packed',
        'ready',
        'dispatched',
      }.contains(status),
    )) {
      return 'processing';
    }
    return 'pending';
  }
}
