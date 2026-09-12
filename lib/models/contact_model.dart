import 'user_model.dart';

class ContactItem {
  final User user;
  final String categoryHeader;

  const ContactItem({
    required this.user,
    required this.categoryHeader,
  });
}
