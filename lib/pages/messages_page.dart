import 'package:chat_app/screens/chat_screen.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

import '../helpers.dart';
import '../widgets/display_error_message.dart';
import '../theme.dart';
import '../widgets/widgets.dart';
import '../models/models.dart';
import '../app.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({Key? key}) : super(key: key);

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final channelListController = ChannelListController();

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return ChannelListCore(
      channelListController: channelListController,
      filter: Filter.and(
        [
          Filter.equal('type', 'messaging'),
          Filter.in_(
            'members',
            [
              StreamChatCore.of(context).currentUser!.id,
            ],
          ),
        ],
      ),
      listBuilder: (context, channels) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            const SliverToBoxAdapter(
              child: _Stories(),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _MessageTile(
                    channel: channels[index],
                  );
                },
                childCount: channels.length,
              ),
            ),
          ],
        );
      },
      errorBuilder: (context, error) {
        return DisplayErrorMessage(
          error: error,
        );
      },
      emptyBuilder: (context) {
        return const Center(
          child: Text(
            'So empty.\nStart messaging someone.',
            textAlign: TextAlign.center,
          ),
        );
      },
      loadingBuilder: (context) {
        return const Center(
          child: SizedBox(
            height: 100,
            width: 100,
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

class _MessageTile extends StatelessWidget {
  final Channel channel;

  const _MessageTile({
    Key? key,
    required this.channel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(ChatScreen.routeWithChannel(channel));
      },
      child: Container(
        height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Avatar.medium(
                  url: Helpers.getChannelImage(channel, context.currentUser!),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Text(
                        Helpers.getChannelName(channel, context.currentUser!),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          letterSpacing: 0.2,
                          wordSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                      child: _buildLastMessage(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(
                      height: 4,
                    ),
                    _buildLastMessageAt(),
                    const SizedBox(
                      height: 8,
                    ),
                    Center(
                      child: UnreadIndicator(
                        channel: channel,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLastMessage() {
    return BetterStreamBuilder<int>(
      stream: channel.state!.unreadCountStream,
      initialData: channel.state?.unreadCount ?? 0,
      builder: (context, count) {
        return BetterStreamBuilder<Message>(
          stream: channel.state!.lastMessageStream,
          initialData: channel.state!.lastMessage,
          builder: (context, lastMessage) {
            return Text(
              lastMessage.text ?? '',
              overflow: TextOverflow.fade,
              style: (count > 0)
                  ? const TextStyle(
                      fontSize: 12,
                      color: AppColors.secondary,
                    )
                  : const TextStyle(
                      fontSize: 12,
                      color: AppColors.textFaded,
                    ),
            );
          },
        );
      },
    );
  }

  Widget _buildLastMessageAt() {
    return BetterStreamBuilder<DateTime>(
      stream: channel.lastMessageAtStream,
      initialData: channel.lastMessageAt,
      builder: (context, data) {
        final lastMessageAt = data.toLocal();
        String stringDate;
        final now = DateTime.now();

        final startOfDay = DateTime(now.year, now.month, now.day);

        if (lastMessageAt.millisecondsSinceEpoch >=
            startOfDay.millisecondsSinceEpoch) {
          stringDate = Jiffy(lastMessageAt.toLocal()).jm;
        } else if (lastMessageAt.millisecondsSinceEpoch >=
            startOfDay
                .subtract(const Duration(days: 1))
                .millisecondsSinceEpoch) {
          stringDate = 'YESTERDAY';
        } else if (startOfDay.difference(lastMessageAt).inDays < 7) {
          stringDate = Jiffy(lastMessageAt.toLocal()).EEEE;
        } else {
          stringDate = Jiffy(lastMessageAt.toLocal()).yMd;
        }
        return Text(
          stringDate,
          style: const TextStyle(
            fontSize: 11,
            letterSpacing: -0.2,
            fontWeight: FontWeight.w600,
            color: AppColors.textFaded,
          ),
        );
      },
    );
  }
}

class _Stories extends StatelessWidget {
  const _Stories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Expanded(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          itemBuilder: (BuildContext context, index) {
            final faker = Faker();
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                width: 60,
                child: _StoryCard(
                  storyData: StoryData(
                    name: faker.person.name(),
                    url: Helpers.randomPictureUrl(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({
    Key? key,
    required this.storyData,
  }) : super(key: key);

  final StoryData storyData;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Avatar.medium(url: storyData.url),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              storyData.name,
              overflow: TextOverflow.fade,
              style: const TextStyle(
                fontSize: 10,
                letterSpacing: 0.3,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
