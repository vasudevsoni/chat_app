import 'package:flutter/material.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

import 'app.dart';
import 'theme.dart';
import 'screens/home_screen.dart';
import 'screens/select_users_screen.dart';

void main() {
  final client = StreamChatClient(streamKey);

  runApp(MyApp(client: client));
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
    required this.client,
  }) : super(key: key);

  final StreamChatClient client;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Octo Chat',
      builder: (context, child) {
        return StreamChatCore(
          client: client,
          // ignore: deprecated_member_use
          child: ChannelsBloc(
            // ignore: deprecated_member_use
            child: UsersBloc(
              child: child!,
            ),
          ),
        );
      },
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      home: SelectUserScreen(),
    );
  }
}
