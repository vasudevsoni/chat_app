import 'package:chat_app/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screens/screens.dart';
import '../widgets/glowing_action_button.dart';
import '../app.dart';
import '../widgets/icon_buttons.dart';
import '../widgets/avatar.dart';
import '../pages/calls_page.dart';
import '../pages/contacts_page.dart';
import '../pages/messages_page.dart';
import '../pages/notifications_page.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final ValueNotifier<int> pageIndex = ValueNotifier(0);
  final ValueNotifier<String> title = ValueNotifier('Chats');

  final pages = const [
    MessagesPage(),
    NotificationsPage(),
    CallsPage(),
    ContactsPage(),
  ];

  final pageTitles = [
    'Chats',
    'Notifications',
    'Calls',
    'Contacts',
  ];

  void _onNavigationItemSelected(index) {
    title.value = pageTitles[index];
    pageIndex.value = index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: ValueListenableBuilder(
          valueListenable: title,
          builder: (BuildContext context, String value, _) {
            return Center(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textHighlight,
                ),
              ),
            );
          },
        ),
        leadingWidth: 54,
        leading: Align(
          alignment: Alignment.centerRight,
          child: IconBackground(
            icon: Icons.search,
            onTap: () {
              // ignore: avoid_print
              print('todo search');
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: Hero(
              tag: 'hero-profile-picture',
              child: Avatar.small(
                url: context.currentUserImage,
                onTap: () {
                  Navigator.of(context).push(ProfileScreen.route);
                },
              ),
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: pageIndex,
        builder: (BuildContext context, int value, _) {
          return pages[value];
        },
      ),
      bottomNavigationBar: _BottomNavigationBar(
        onItemSelected: _onNavigationItemSelected,
      ),
    );
  }
}

class _BottomNavigationBar extends StatefulWidget {
  final ValueChanged<int> onItemSelected;

  const _BottomNavigationBar({
    Key? key,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  State<_BottomNavigationBar> createState() => _BottomNavigationBarState();
}

class _BottomNavigationBarState extends State<_BottomNavigationBar> {
  var selectedIndex = 0;
  void handleItemSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
    widget.onItemSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Card(
      color: brightness == Brightness.light ? Colors.transparent : null,
      elevation: 0.0,
      margin: const EdgeInsets.all(0),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavigationBarItem(
                index: 0,
                isSelected: (selectedIndex == 0),
                icon: CupertinoIcons.bubble_left_bubble_right_fill,
                onTap: handleItemSelected,
              ),
              _NavigationBarItem(
                index: 1,
                isSelected: (selectedIndex == 1),
                icon: CupertinoIcons.bell_solid,
                onTap: handleItemSelected,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GlowingActionButton(
                  color: AppColors.secondary,
                  icon: CupertinoIcons.add,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => const Dialog(
                        child: AspectRatio(
                          aspectRatio: 5 / 7,
                          child: ContactsPage(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              _NavigationBarItem(
                index: 2,
                isSelected: (selectedIndex == 2),
                icon: CupertinoIcons.phone_fill,
                onTap: handleItemSelected,
              ),
              _NavigationBarItem(
                index: 3,
                isSelected: (selectedIndex == 3),
                icon: CupertinoIcons.person_2_fill,
                onTap: handleItemSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationBarItem extends StatelessWidget {
  final IconData icon;
  final int index;
  final bool isSelected;
  final ValueChanged<int> onTap;

  const _NavigationBarItem({
    Key? key,
    required this.icon,
    required this.index,
    required this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        onTap(index);
      },
      child: SizedBox(
        width: 70,
        child: Icon(
          icon,
          size: 25,
          color: isSelected ? AppColors.secondary : null,
        ),
      ),
    );
  }
}
