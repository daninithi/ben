import 'package:chat_app/core/constants/strings.dart';
import 'package:chat_app/ui/screens/bottom_navigator/bottom_navigation_viewmodel.dart';
import 'package:chat_app/ui/screens/bottom_navigator/chat_list/chat_list_screen.dart';
import 'package:chat_app/ui/screens/plus/plus_screen.dart';
import 'package:chat_app/ui/screens/other/user_provider.dart';
import 'package:chat_app/ui/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class BottomNavigationsScreen extends StatelessWidget {
  const BottomNavigationsScreen({super.key});

  static final List<Widget> _screens = [
    const ChatsListScreen(),
    const PlusScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).user;
    final items = const [
      BottomNavigationBarItem(
        label: "",
        icon: BottomNavButton(iconPath: chatsIcon),
      ),
       BottomNavigationBarItem(
        label: "",
        icon: BottomNavButton(iconPath: plusIcon),
      ),
      BottomNavigationBarItem(
        label: "",
        icon: BottomNavButton(iconPath: profileIcon),
      ),
    ];

    return ChangeNotifierProvider(
      create: (context) => BottomNavigationViewModel(),
      child: Consumer<BottomNavigationViewModel>(
        builder: (context, model, _) {
          return currentUser == null ? const Center(
            child: CircularProgressIndicator(),
          )  
          : Scaffold(
            body: BottomNavigationsScreen
                ._screens[model.currentIndex], // Default to the first screen
            bottomNavigationBar: CustomNavBar(
              ontap: model.setIndex,
              items: items,
            ),
          );
        },
      ),
    );
  }
}

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({super.key, this.ontap, required this.items});

  final void Function(int)? ontap;
  final List<BottomNavigationBarItem> items;

  @override
  Widget build(BuildContext context) {
    final borderradius = BorderRadius.only(
      topLeft: Radius.circular(30.0),
      topRight: Radius.circular(30.0),
    );
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderradius,
        boxShadow: [
          BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 10),
        ],
      ),

      child: ClipRRect(
        borderRadius: borderradius,
        child: BottomNavigationBar(onTap: ontap, items: items),
      ),
    );
  }
}

class BottomNavButton extends StatelessWidget {
  const BottomNavButton({super.key, required this.iconPath});

  final String iconPath;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Image.asset(iconPath, height: 35, width: 35),
    );
  }
}
