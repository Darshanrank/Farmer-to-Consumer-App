class AppCategory {
  final String id;
  final String title;
  final String emoji;

  const AppCategory(this.id, this.title, this.emoji);
}

class AppCategories {
  static const List<AppCategory> list = [
    AppCategory('all', 'All', '🍱'),
    AppCategory('seeds', 'Seeds', '🌱'),
    AppCategory('fertilizers', 'Fertilizers', '🧪'),
    AppCategory('pesticides', 'Pesticides', '🛡️'),
    AppCategory('tools', 'Tools', '🛠️'),
    AppCategory('irrigation', 'Irrigation', '💧'),
    AppCategory('organic', 'Organic', '🌿'),
    AppCategory('other', 'Other', '📦'),
  ];
  
  // List without 'All' for forms and explore screen
  static List<AppCategory> get selectable => list.where((c) => c.id != 'all').toList();
}
