import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/contact_service.dart';
import '../services/chat_service.dart';
import '../services/call_service.dart';
import '../models/call_model.dart';
import '../theme/app_theme.dart';
import '../widgets/user_avatar.dart';

class ContactsTab extends StatefulWidget {
  final ContactService contactService;
  final ChatService chatService;
  final CallService callService;
  final Function(User) onStartChatWithUser;
  final VoidCallback onStartCall;

  const ContactsTab({
    super.key,
    required this.contactService,
    required this.chatService,
    required this.callService,
    required this.onStartChatWithUser,
    required this.onStartCall,
  });

  @override
  State<ContactsTab> createState() => _ContactsTabState();
}

class _ContactsTabState extends State<ContactsTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddContactModal() {
    final nameCtrl = TextEditingController();
    final usernameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final bioCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 24.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                alignment: Alignment.center,
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondaryDark.withAlpha(80),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Add New Contact',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: usernameCtrl,
                decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.alternate_email)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bioCtrl,
                decoration: const InputDecoration(labelText: 'Bio (Optional)', prefixIcon: Icon(Icons.info_outline)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.trim().isNotEmpty && phoneCtrl.text.trim().isNotEmpty) {
                    widget.contactService.addContact(
                      nameCtrl.text.trim(),
                      usernameCtrl.text.trim().isNotEmpty ? usernameCtrl.text.trim() : nameCtrl.text.toLowerCase().replaceAll(' ', ''),
                      phoneCtrl.text.trim(),
                      bio: bioCtrl.text.trim().isNotEmpty ? bioCtrl.text.trim() : null,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Contact added successfully!')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Add Contact', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.contactService,
      builder: (context, _) {
        final allContacts = widget.contactService.contacts;
        final filteredContacts = allContacts.where((item) {
          final query = _searchQuery.toLowerCase();
          final matchesName = item.user.name.toLowerCase().contains(query);
          final matchesUsername = item.user.username.toLowerCase().contains(query);
          return matchesName || matchesUsername;
        }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Search contacts...',
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryBlueLight),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    onPressed: _showAddContactModal,
                    icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.all(14),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredContacts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.contacts_outlined, size: 64, color: AppColors.textSecondaryDark.withAlpha(100)),
                          const SizedBox(height: 16),
                          const Text('No contacts found', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 16)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredContacts.length,
                      itemBuilder: (context, index) {
                        final item = filteredContacts[index];
                        final showHeader = index == 0 ||
                            filteredContacts[index - 1].categoryHeader != item.categoryHeader;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showHeader)
                              Padding(
                                padding: const EdgeInsets.only(left: 20, top: 12, bottom: 4),
                                child: Text(
                                  item.categoryHeader,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBlueLight,
                                  ),
                                ),
                              ),
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                              leading: UserAvatar(user: item.user, radius: 24),
                              title: Text(item.user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('@${item.user.username} • ${item.user.bio}',
                                  maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondaryDark)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primaryBlueLight, size: 20),
                                    onPressed: () => widget.onStartChatWithUser(item.user),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.call_outlined, color: AppColors.primaryBlueLight, size: 20),
                                    onPressed: () {
                                      widget.callService.startCall(item.user, CallType.audio);
                                      widget.onStartCall();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
