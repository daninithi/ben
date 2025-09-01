import 'package:chat_app/core/constants/colors.dart';
import 'dart:async';
import 'package:chat_app/core/constants/styles.dart';
import 'package:chat_app/core/extension/widget_extension.dart';
import 'package:chat_app/core/models/user.dart';
import 'package:chat_app/core/services/chat_service.dart';
import 'package:chat_app/ui/screens/bottom_navigator/chat_list/chatroom/chat_viewmodel.dart';
import 'package:chat_app/ui/screens/bottom_navigator/chat_list/chatroom/chat_widgets.dart';
import 'package:chat_app/ui/screens/other/user_provider.dart';
import 'package:chat_app/core/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.receiver});
  final UserModel receiver;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool canChat = true;
  bool isContact = false;
  DateTime? chatStartTime;
  int secondsLeft = 30;
  Timer? countdownTimer;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _checkChatExpiration();
    _resetUnreadCounter();
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _resetUnreadCounter() async {
    // Reset unread counter when receiver opens chat
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final currentUser = Provider.of<UserProvider>(
        context,
        listen: false,
      ).user;
      final receiver = widget.receiver;

      if (currentUser != null && currentUser.uid != null) {
        try {
          // Reset unread counter for this chat in temporary_chats
          final chatIdList = [currentUser.uid, receiver.uid]..sort();
          final chatIdStr = chatIdList.join('_');

          await FirebaseFirestore.instance
              .collection('temporary_chats')
              .doc(chatIdStr)
              .update({'unreadCounter_${currentUser.uid}': 0});

          // Removed the redundant ChatService call since we're already doing it above
          print('Unread counter reset successfully');
        } catch (e) {
          // Handle error silently
          print('Error resetting unread counter: $e');
        }
      }
    });
  }

  Future<void> _checkChatExpiration() async {
    final currentUser = Provider.of<UserProvider>(context, listen: false).user;
    if (currentUser?.uid == null) return;

    final chatIdList = [currentUser!.uid, widget.receiver.uid]..sort();
    final chatIdStr = chatIdList.join('_');

    try {
      final tempChatRef = FirebaseFirestore.instance
          .collection('temporary_chats')
          .doc(chatIdStr);
      final tempChatDoc = await tempChatRef.get();

      // Check if both users are contacts
      final contactDoc = await FirebaseFirestore.instance
          .collection('contacts')
          .doc(currentUser.uid)
          .collection('userContacts')
          .doc(widget.receiver.uid)
          .get();

      if (contactDoc.exists) {
        setState(() {
          isContact = true;
          canChat = true;
          secondsLeft = 0;
        });
        countdownTimer?.cancel();
        return;
      } else {
        setState(() {
          isContact = false;
        });
      }

      if (tempChatDoc.exists) {
        final data = tempChatDoc.data();
        final Timestamp? createdAt = data?['createdAt'];
        if (createdAt != null) {
          chatStartTime = createdAt.toDate();
          final now = DateTime.now();
          final diff = now.difference(chatStartTime!);
          if (diff.inSeconds >= 30) {
            setState(() {
              canChat = false;
              secondsLeft = 0;
            });
          } else {
            setState(() {
              canChat = true;
              secondsLeft = 30 - diff.inSeconds;
            });
            _startCountdownTimer();
          }
        }
      }
    } catch (e) {
      print('Error checking chat expiration: $e');
    }
  }

  void _startCountdownTimer() {
    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (chatStartTime == null) {
        timer.cancel();
        return;
      }

      final now = DateTime.now();
      final diff = now.difference(chatStartTime!);
      final left = 30 - diff.inSeconds;

      if (left <= 0) {
        setState(() {
          canChat = false;
          secondsLeft = 0;
        });
        timer.cancel();
      } else {
        setState(() {
          secondsLeft = left;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).user;
    return ChangeNotifierProvider(
      create: (context) =>
          ChatViewmodel(ChatService(), currentUser!, widget.receiver),
      child: Consumer<ChatViewmodel>(
        builder: (context, model, _) {
          // Scroll to bottom when messages change
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients && model.messages.isNotEmpty) {
              _scrollController.jumpTo(
                _scrollController.position.maxScrollExtent,
              );
            }
          });

          // Set contact request callback
          model.onContactRequestReceived = (request, requestId) {
            if (request['receiverUid'] == currentUser!.uid) {
              _showContactRequestDialog(request, requestId);
            }
          };

          return Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 1.sw * 0.05,
                      vertical: 25.h,
                    ),
                    child: Column(
                      children: [
                        35.verticalSpace,
                        _buildHeader(context, name: widget.receiver.name!),
                        Expanded(
                          child: ListView.separated(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(10),
                            itemCount: model.messages.length,
                            separatorBuilder: (context, index) =>
                                10.verticalSpace,
                            itemBuilder: (context, index) {
                              final message = model.messages[index];
                              return ChatBubble(
                                isCurrentUser:
                                    message.senderId == currentUser!.uid,
                                message: message,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                BottomFeild(
                  controller: model.controller,
                  onTap: canChat
                      ? () async {
                          try {
                            await model.saveMessage();
                          } catch (e) {
                            context.showSnackBar(e.toString());
                          }
                        }
                      : null,
                ),
                if (!canChat)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    color: Colors.red.withOpacity(0.1),
                    child: Text(
                      'Temporary chat expired. You can no longer send messages.',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // This method handles incoming contact requests (with parameters)
  void _showContactRequestDialog(
      Map<String, dynamic> request, String requestId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Contact Request'),
          content: Text(
            'User ${request['senderName']} wants to add you as a contact.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await DatabaseService().updateContactRequestStatus(
                  requestId,
                  'rejected',
                );
                Navigator.of(context).pop();
              },
              child: const Text('Reject'),
            ),
            TextButton(
              onPressed: () async {
                final currentUser = Provider.of<UserProvider>(
                  context,
                  listen: false,
                ).user;

                await DatabaseService().updateContactRequestStatus(
                  requestId,
                  'accepted',
                );
                await DatabaseService().saveContact(currentUser!.uid!, {
                  'uid': request['senderUid'],
                  'name': request['senderName'],
                });
                await DatabaseService().saveContact(
                  request['senderUid'],
                  {
                    'uid': currentUser.uid!,
                    'name': currentUser.name ?? '',
                  },
                );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contact added!')),
                );

                // Refresh contact status
                setState(() {
                  isContact = true;
                  canChat = true;
                  secondsLeft = 0;
                });
                countdownTimer?.cancel();
              },
              child: const Text('Accept'),
            ),
          ],
        );
      },
    );
  }

  Row _buildHeader(BuildContext context, {String name = ""}) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.only(left: 10, top: 6, bottom: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: grey.withOpacity(0.15),
            ),
            child: const Icon(Icons.arrow_back_ios),
          ),
        ),
        15.horizontalSpace,
        Text(name, style: h.copyWith(fontSize: 20.sp)),
        const Spacer(),

        // Countdown timer to the left of person icon
        if (canChat && !isContact)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              '$secondsLeft s',
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),

        // Show tick with person icon if already contacts, else show person+ icon
        if (isContact)
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: grey.withOpacity(0.15),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.person, size: 28),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 16,
                  ),
                ),
              ],
            ),
          )
        else
          IgnorePointer(
            ignoring: !canChat,
            child: Opacity(
              opacity: canChat ? 1.0 : 0.5,
              child: InkWell(
                onTap: canChat ? () => _showSendContactRequestDialog() : null,
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: grey.withOpacity(0.15),
                  ),
                  child: const Icon(Icons.person_add_alt_1),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // This method handles sending contact requests (renamed to avoid duplicate)
  void _showSendContactRequestDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Contact Request'),
          content: const Text(
            'Do you want to send a contact request to the receiver?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final currentUser = Provider.of<UserProvider>(
                  context,
                  listen: false,
                ).user;
                final receiver = widget.receiver;

                await DatabaseService().sendContactRequest(
                  senderUid: currentUser!.uid!,
                  senderName: currentUser.name ?? '',
                  receiverUid: receiver.uid!,
                );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Contact request sent!'),
                  ),
                );
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }
}
