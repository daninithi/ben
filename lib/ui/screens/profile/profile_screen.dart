import 'package:chat_app/core/constants/strings.dart';
import 'package:chat_app/core/services/auth_service.dart';
import 'package:chat_app/core/services/database_service.dart';
import 'package:chat_app/ui/screens/profile/profile_viewmodel.dart';
import 'package:chat_app/ui/screens/other/user_provider.dart';
import 'package:chat_app/ui/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return ChangeNotifierProvider(
      create: (context) => ProfileViewmodel(DatabaseService()),
      child: Consumer<ProfileViewmodel>(
        builder: (context, model, _) {
          return Scaffold(
            body: Center(
              child: userProvider.user == null
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 18.0),
                              child: userProvider.user!.imageUrl != null &&
                                      userProvider.user!.imageUrl!.isNotEmpty
                                  ? CircleAvatar(
                                      radius: 40,
                                      backgroundImage: NetworkImage(
                                        userProvider.user!.imageUrl!,
                                      ),
                                    )
                                  : CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Colors.grey[300],
                                      child: Text(
                                        userProvider.user!.name?.isNotEmpty ==
                                                true
                                            ? userProvider.user!.name![0]
                                                .toUpperCase()
                                            : '',
                                        style: const TextStyle(
                                          fontSize: 32,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Name : ${userProvider.user!.name ?? ''}',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 20),
                                        tooltip: 'Edit Name',
                                        onPressed: () async {
                                          final TextEditingController
                                              _nameController =
                                              TextEditingController(
                                                  text:
                                                      userProvider.user!.name ??
                                                          '');
                                          final newName =
                                              await showDialog<String>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text('Edit Name'),
                                              content: TextField(
                                                controller: _nameController,
                                                decoration:
                                                    const InputDecoration(
                                                        hintText:
                                                            'Enter new name'),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(ctx).pop(),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(ctx).pop(
                                                          _nameController.text
                                                              .trim()),
                                                  child: const Text('Save'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (newName != null &&
                                              newName.isNotEmpty &&
                                              newName !=
                                                  userProvider.user!.name) {
                                            // Update in Firestore
                                            await DatabaseService()
                                                .updateUserName(
                                                    userProvider.user!.uid!,
                                                    newName);
                                            // Update locally
                                            userProvider.updateUser(userProvider
                                                .user!
                                                .copyWith(name: newName));
                                            // Force rebuild
                                            (context as Element)
                                                .markNeedsBuild();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content:
                                                      Text('Name updated!')),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Email : ${userProvider.user!.email ?? ''}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: 160,
                          child: CustomButton(
                            text: 'Log Out',
                            onPressed: () {
                              // Provider.of<UserProvider>(context,listen: false).clearUser();
                              // AuthService().logout();
                              Provider.of<UserProvider>(
                                context,
                                listen: false,
                              ).clearUser();
                              Navigator.of(context).pushReplacementNamed(
                                login,
                              ); // or splash, or your login route
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}
