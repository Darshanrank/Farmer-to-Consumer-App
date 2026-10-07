import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/services/firebase_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Help & Support screen.
/// Shows FAQ items and a working contact form that saves to Firestore.
class SellerHelpScreen extends ConsumerStatefulWidget {
  const SellerHelpScreen({super.key});

  @override
  ConsumerState<SellerHelpScreen> createState() => _SellerHelpScreenState();
}

class _SellerHelpScreenState extends ConsumerState<SellerHelpScreen> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  final _faqs = const [
    _Faq(
      question: 'How do I add a product?',
      answer: 'Go to the Products tab and tap the + button. Fill in the product details including name, price, stock quantity, and at least one photo.',
    ),
    _Faq(
      question: 'How do I receive orders?',
      answer: 'When a buyer places an order for your product, it will appear in the Orders tab. You will also receive a notification (if enabled in Settings).',
    ),
    _Faq(
      question: 'How do I update my business information?',
      answer: 'Go to Profile → Business Settings. Make your changes and tap Save Changes.',
    ),
    _Faq(
      question: 'Why is my product not showing to buyers?',
      answer: 'Check that your product status is set to "active" and that it has stock quantity > 0. Products set to "hidden" or "outOfStock" do not appear in buyer searches.',
    ),
    _Faq(
      question: 'How do I cancel or deactivate a product?',
      answer: 'Go to Products → tap the product → Edit Product → change status to "hidden" or set stock to 0. You can also delete the product from the edit screen.',
    ),
    _Faq(
      question: 'How do I delete my account?',
      answer: 'Go to Profile → Delete Account. You will need to enter your password to confirm. Your personal data will be removed, but order history may be preserved for record-keeping.',
    ),
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    if (subject.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both subject and message.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    FocusScope.of(context).unfocus();

    try {
      final user = ref.read(appUserProvider).value;
      final firestore = ref.read(firebaseServiceProvider).firestore;

      await firestore.collection('supportRequests').add({
        'userId': user?.uid ?? 'anonymous',
        'email': user?.email ?? '',
        'subject': subject,
        'message': message,
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _subjectController.clear();
      _messageController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Support request submitted! We\'ll get back to you soon.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // FAQ Section
          Text(
            'Frequently Asked Questions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._faqs.map((faq) => _FaqTile(faq: faq)),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          // Contact Form
          Text(
            'Contact Support',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Can\'t find your answer above? Send us a message and we\'ll help you.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _subjectController,
            enabled: !_isSubmitting,
            decoration: const InputDecoration(
              labelText: 'Subject',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.subject),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _messageController,
            enabled: !_isSubmitting,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Message',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 60.0),
                child: Icon(Icons.message_outlined),
              ),
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitRequest,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send),
              label: Text(_isSubmitting ? 'Submitting...' : 'Submit Request'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _Faq {
  final String question;
  final String answer;
  const _Faq({required this.question, required this.answer});
}

class _FaqTile extends StatefulWidget {
  final _Faq faq;
  const _FaqTile({required this.faq});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          widget.faq.question,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
        onExpansionChanged: (val) => setState(() => _expanded = val),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              widget.faq.answer,
              style: TextStyle(color: Colors.grey[700], height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
