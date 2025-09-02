import 'package:chat_app/ui/screens/other/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/strings.dart';
import 'package:chat_app/core/constants/styles.dart';
import 'package:chat_app/core/models/user.dart';
import 'package:chat_app/core/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});
  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  final DatabaseService _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    final currentUserUid = _db.getCurrentUserUid();

    if (currentUserUid == null) {
      return const Center(child: Text('User not logged in.'));
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.user;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'Lynk!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
            ),
            if (currentUser != null && currentUser.name != null)
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  'Welcome! ${currentUser.name!}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner, color: Colors.black, size: 24),
            tooltip: 'Scan',
            onPressed: () {
              Navigator.pushNamed(context, qrScan);
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.getTemporaryChats(currentUserUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No chats available. Scan a QR code to start!"),
            );
          }

          final chatDocs = snapshot.data!.docs;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.sw * 0.05),
            child: Column(
              children: [
                15.verticalSpace,
                // Search field
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search user...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim().toLowerCase();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 0,
                    ),
                    itemCount: chatDocs.length,
                    separatorBuilder: (context, index) => 8.verticalSpace,
                    itemBuilder: (context, index) {
                      final chatData =
                          chatDocs[index].data() as Map<String, dynamic>;
                      final participants = List<String>.from(
                        chatData['participants'],
                      );
                      final otherUserId = participants.firstWhere(
                        (id) => id != currentUserUid,
                      );

                      return FutureBuilder<Map<String, dynamic>?>(
                        future: _db.loadUser(otherUserId),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const ListTile(
                              title: Text('Loading user...'),
                              leading: CircleAvatar(),
                            );
                          }
                          if (userSnapshot.hasError ||
                              !userSnapshot.hasData ||
                              userSnapshot.data == null) {
                            return const ListTile(
                              title: Text('Unknown User'),
                              leading: CircleAvatar(child: Icon(Icons.person)),
                            );
                          }

                          final otherUser = UserModel.fromMap(
                            userSnapshot.data!,
                          );
                          final userWithLastMessage = otherUser.copyWith(
                            lastMessage: {
                              "content": chatData['lastMessage'],
                              "timestamp":
                                  chatData['lastMessageTimestamp'] != null
                                      ? (chatData['lastMessageTimestamp']
                                              as Timestamp)
                                          .millisecondsSinceEpoch
                                      : null,
                            },
                            unreadCounter:
                                chatData['unreadCounter_${currentUserUid}'] ??
                                    0,
                          );

                          // ChatId for deletion
                          final chatIdList = [currentUserUid, otherUserId]
                            ..sort();
                          final chatIdStr = chatIdList.join('_');

                          // Filter by search query
                          if (_searchQuery.isNotEmpty &&
                              !(userWithLastMessage.name
                                      ?.toLowerCase()
                                      .contains(_searchQuery) ??
                                  false)) {
                            return const SizedBox.shrink();
                          }

                          return GestureDetector(
                            onLongPress: () async {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete Chat'),
                                  content: const Text(
                                    'Do you want to delete this chat?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        // Delete from temporary_chats
                                        await FirebaseFirestore.instance
                                            .collection('temporary_chats')
                                            .doc(chatIdStr)
                                            .delete();
                                        // Optionally delete from chats
                                        await FirebaseFirestore.instance
                                            .collection('chats')
                                            .doc(chatIdStr)
                                            .delete();
                                        Navigator.of(ctx).pop();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Chat deleted!'),
                                          ),
                                        );
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: ChatTile(
                              user: userWithLastMessage,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  chatroom,
                                  arguments: userWithLastMessage,
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ChatTile extends StatelessWidget {
  final UserModel user;
  final void Function()? onTap;

  const ChatTile({super.key, this.onTap, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      // ignore: deprecated_member_use
      tileColor: grey.withOpacity(0.12),
      contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      leading: user.imageUrl == null
          ? CircleAvatar(
              backgroundColor: grey,
              radius: 25,
              child: Text(
                user.name![0].toUpperCase(),
                style: h2.copyWith(color: white),
              ),
            )
          : ClipOval(
              child: Image.network(
                user.imageUrl!,
                height: 50,
                width: 50,
                fit: BoxFit.fill,
              ),
            ),
      title: Text(user.name!),
      subtitle: Text(
        user.lastMessage != null ? user.lastMessage!["content"] : "",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),

      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            user.lastMessage == null ? "" : getTime(),
            style: TextStyle(color: grey),
          ),
          10.verticalSpace,
          user.unreadCounter == 0 || user.unreadCounter == null
              ? SizedBox(height: 15)
              : CircleAvatar(
                  radius: 9.r,
                  backgroundColor: Primary,
                  child: Text(
                    "${user.unreadCounter}",
                    style: small.copyWith(color: white),
                  ),
                ),
        ],
      ),
    );
  }

  String getTime() {
    if (user.lastMessage == null) {
      return "";
    }

    DateTime lastMessageTime = DateTime.fromMillisecondsSinceEpoch(
      user.lastMessage!["timestamp"],
    );
    Duration difference = DateTime.now().difference(lastMessageTime);

    if (difference.inMinutes < 1) {
      return "Just now";
    } else if (difference.inHours < 1) {
      int minutes = difference.inMinutes;
      return "$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago";
    } else if (difference.inDays < 1) {
      int hours = difference.inHours;
      return "$hours ${hours == 1 ? 'hour' : 'hours'} ago";
    } else if (difference.inDays < 7) {
      int days = difference.inDays;
      return "$days ${days == 1 ? 'day' : 'days'} ago";
    } else {
      return "${lastMessageTime.day}/${lastMessageTime.month}/${lastMessageTime.year}";
    }
  }
}
