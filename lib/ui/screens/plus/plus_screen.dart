import 'package:chat_app/core/constants/strings.dart';
import 'package:chat_app/ui/screens/other/user_provider.dart';
import 'package:chat_app/core/models/user.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PlusScreen extends StatelessWidget {
  const PlusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).user;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            'Contacts ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
        ),
      ),

      body: currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('contacts')
                  .doc(currentUser.uid)
                  .collection('userContacts')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final contacts = snapshot.data?.docs ?? [];
                return ListView.builder(
                  itemCount: contacts.isEmpty ? 3 : contacts.length + 2,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ListTile(
                        onTap: () {
                          Navigator.pushNamed(context, qrSystem);
                        },
                        leading: const Icon(
                          Icons.person_add,
                          color: Colors.black,
                        ),
                        title: const Text(
                          'New Contact',
                          style: TextStyle(color: Colors.black),
                        ),
                      );
                    } else if (index == 1) {
                      return const Padding(
                        padding: EdgeInsets.fromLTRB(16, 12, 16, 6),
                        child: Text(
                          'Saved Contacts',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }
                    if (contacts.isEmpty && index == 2) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(
                          child: Text(
                            'You have no any contacts',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }
                    final contact =
                        contacts[index - 2].data() as Map<String, dynamic>;
                    final contactUid = contact['uid'];
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(contactUid)
                          .get(),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const ListTile(
                            leading: CircleAvatar(backgroundColor: Colors.grey),
                            title: Text(
                              'Loading...',
                              style: TextStyle(color: Colors.black),
                            ),
                          );
                        }
                        if (!userSnapshot.hasData ||
                            !userSnapshot.data!.exists) {
                          return ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.grey,
                            ),
                            title: Text(
                              contact['name'] ?? '',
                              style: const TextStyle(color: Colors.black),
                            ),
                          );
                        }
                        final userData =
                            userSnapshot.data!.data() as Map<String, dynamic>?;
                        final profileImage = userData?['imageUrl'] ?? '';
                        final profileName =
                            userData?['name'] ?? contact['name'] ?? '';
                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.grey,
                              backgroundImage: profileImage.isNotEmpty
                                  ? NetworkImage(profileImage)
                                  : null,
                              child: profileImage.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 24,
                                    )
                                  : null,
                            ),
                            title: Text(
                              profileName,
                              style: const TextStyle(color: Colors.black),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.black45,
                              size: 20,
                            ),
                            onTap: () {
                              final userModel = UserModel(
                                uid: contactUid,
                                name: profileName,
                                imageUrl: profileImage,
                              );
                              Navigator.pushNamed(
                                context,
                                chatroom,
                                arguments: userModel,
                              );
                            },
                            onLongPress: () async {
                              final contactId = contacts[index - 2].id;
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Contact'),
                                  content: const Text(
                                    'Do you want to remove this contact?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        await FirebaseFirestore.instance
                                            .collection('contacts')
                                            .doc(currentUser.uid)
                                            .collection('userContacts')
                                            .doc(contactId)
                                            .delete();
                                        final otherUid = contactUid;
                                        await FirebaseFirestore.instance
                                            .collection('contacts')
                                            .doc(otherUid)
                                            .collection('userContacts')
                                            .doc(currentUser.uid)
                                            .delete();
                                        final chatId = [
                                          currentUser.uid,
                                          otherUid,
                                        ]..sort();
                                        final chatIdStr = chatId.join('_');
                                        await FirebaseFirestore.instance
                                            .collection('chats')
                                            .doc(chatIdStr)
                                            .delete();
                                        await FirebaseFirestore.instance
                                            .collection('temporary_chats')
                                            .doc(chatIdStr)
                                            .delete();
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Contact and chat deleted for both users!',
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
