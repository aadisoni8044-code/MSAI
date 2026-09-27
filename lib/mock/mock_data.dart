import '../models/user.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/status.dart';
import '../models/call.dart';
import '../models/community.dart';

class MockData {
  static const User currentUser = User(
    id: 'user_me',
    name: 'Alex Rivera',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    statusMessage: 'Building the future with ZIPgram 🚀',
    status: UserStatus.online,
    phoneNumber: '+1 (555) 019-2834',
    username: '@alexrivera',
  );

  static const List<User> mockUsers = [
    User(
      id: 'user_1',
      name: 'Amit',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      statusMessage: 'Coding Flutter apps 💻',
      status: UserStatus.online,
      phoneNumber: '+1 (555) 234-5678',
      username: '@amit_dev',
    ),
    User(
      id: 'user_2',
      name: 'Khushi',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      statusMessage: 'Design is intelligence made visible ✨',
      status: UserStatus.online,
      phoneNumber: '+1 (555) 345-6789',
      username: '@khushi_ui',
    ),
    User(
      id: 'user_3',
      name: 'Roshani',
      avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
      statusMessage: 'At the gym 🏋️‍♀️',
      status: UserStatus.away,
      phoneNumber: '+1 (555) 456-7890',
      username: '@roshani_fit',
    ),
    User(
      id: 'user_4',
      name: 'Rahul',
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
      statusMessage: 'Busy with product launch 🚀',
      status: UserStatus.busy,
      phoneNumber: '+1 (555) 567-8901',
      username: '@rahul_pm',
    ),
    User(
      id: 'user_5',
      name: 'Priya',
      avatarUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=150',
      statusMessage: 'Coffee & Books ☕️📚',
      status: UserStatus.offline,
      phoneNumber: '+1 (555) 678-9012',
      username: '@priya_reads',
    ),
    User(
      id: 'user_6',
      name: 'Arjun',
      avatarUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150',
      statusMessage: 'Exploring new places 🗺️',
      status: UserStatus.online,
      phoneNumber: '+1 (555) 789-0123',
      username: '@arjun_travels',
    ),
  ];

  static List<Chat> getInitialChats() {
    final now = DateTime.now();
    return [
      Chat(
        id: 'chat_1',
        type: ChatType.individual,
        name: 'Khushi',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        participant: mockUsers[1],
        isPinned: true,
        unreadCount: 2,
        updatedAt: now.subtract(const Duration(minutes: 3)),
        lastMessage: Message(
          id: 'msg_1_last',
          senderId: 'user_2',
          senderName: 'Khushi',
          text: 'Did you check out the new dark UI palette for ZIPgram?',
          timestamp: now.subtract(const Duration(minutes: 3)),
          status: MessageStatus.delivered,
        ),
      ),
      Chat(
        id: 'chat_2',
        type: ChatType.individual,
        name: 'Amit',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        participant: mockUsers[0],
        isPinned: true,
        unreadCount: 0,
        updatedAt: now.subtract(const Duration(minutes: 25)),
        lastMessage: Message(
          id: 'msg_2_last',
          senderId: 'user_me',
          senderName: 'Alex',
          text: 'Awesome, all tests are passing cleanly!',
          timestamp: now.subtract(const Duration(minutes: 25)),
          status: MessageStatus.read,
        ),
      ),
      Chat(
        id: 'chat_group_1',
        type: ChatType.group,
        name: 'ZIPgram Core Engineers ⚡️',
        avatarUrl: 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=150',
        groupMembers: [currentUser, mockUsers[0], mockUsers[1], mockUsers[3]],
        isPinned: false,
        unreadCount: 5,
        updatedAt: now.subtract(const Duration(hours: 1)),
        lastMessage: Message(
          id: 'msg_g1_last',
          senderId: 'user_4',
          senderName: 'Rahul',
          text: 'Deployment is scheduled for 8:00 PM tonight.',
          timestamp: now.subtract(const Duration(hours: 1)),
          status: MessageStatus.delivered,
        ),
      ),
      Chat(
        id: 'chat_3',
        type: ChatType.individual,
        name: 'Roshani',
        avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
        participant: mockUsers[2],
        isPinned: false,
        unreadCount: 0,
        isMuted: true,
        updatedAt: now.subtract(const Duration(hours: 3)),
        lastMessage: Message(
          id: 'msg_3_last',
          senderId: 'user_3',
          senderName: 'Roshani',
          text: 'Let us catch up during lunch tomorrow!',
          timestamp: now.subtract(const Duration(hours: 3)),
          status: MessageStatus.read,
        ),
      ),
      Chat(
        id: 'chat_4',
        type: ChatType.individual,
        name: 'Arjun',
        avatarUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150',
        participant: mockUsers[5],
        isPinned: false,
        unreadCount: 1,
        updatedAt: now.subtract(const Duration(hours: 6)),
        lastMessage: Message(
          id: 'msg_4_last',
          senderId: 'user_6',
          senderName: 'Arjun',
          text: 'Check out this photo from the summit! 🏔️',
          timestamp: now.subtract(const Duration(hours: 6)),
          type: MessageType.image,
          mediaUrl: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400',
          status: MessageStatus.delivered,
        ),
      ),
      Chat(
        id: 'chat_5',
        type: ChatType.individual,
        name: 'Priya',
        avatarUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=150',
        participant: mockUsers[4],
        isPinned: false,
        unreadCount: 0,
        updatedAt: now.subtract(const Duration(days: 1)),
        lastMessage: Message(
          id: 'msg_5_last',
          senderId: 'user_me',
          senderName: 'Alex',
          text: 'Thanks for sharing the document!',
          timestamp: now.subtract(const Duration(days: 1)),
          status: MessageStatus.read,
        ),
      ),
    ];
  }

  static Map<String, List<Message>> getInitialMessages() {
    final now = DateTime.now();
    return {
      'chat_1': [
        Message(
          id: 'm1',
          senderId: 'user_2',
          senderName: 'Khushi',
          text: 'Hey Alex! How is the new messaging app UI coming along?',
          timestamp: now.subtract(const Duration(minutes: 15)),
          status: MessageStatus.read,
        ),
        Message(
          id: 'm2',
          senderId: 'user_me',
          senderName: 'Alex',
          text: 'Hey Khushi! It looks super crisp with the deep dark theme & blue accent!',
          timestamp: now.subtract(const Duration(minutes: 12)),
          status: MessageStatus.read,
        ),
        Message(
          id: 'm3',
          senderId: 'user_2',
          senderName: 'Khushi',
          text: 'Here is the latest mock preview file.',
          timestamp: now.subtract(const Duration(minutes: 8)),
          type: MessageType.image,
          mediaUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=400',
          status: MessageStatus.read,
        ),
        Message(
          id: 'm4',
          senderId: 'user_2',
          senderName: 'Khushi',
          text: 'Did you check out the new dark UI palette for ZIPgram?',
          timestamp: now.subtract(const Duration(minutes: 3)),
          status: MessageStatus.delivered,
          reactions: ['👍', '❤️'],
        ),
      ],
      'chat_2': [
        Message(
          id: 'm2_1',
          senderId: 'user_1',
          senderName: 'Amit',
          text: 'Hey man, did you finish running flutter analyze on the project?',
          timestamp: now.subtract(const Duration(minutes: 35)),
          status: MessageStatus.read,
        ),
        Message(
          id: 'm2_2',
          senderId: 'user_me',
          senderName: 'Alex',
          text: 'Awesome, all tests are passing cleanly!',
          timestamp: now.subtract(const Duration(minutes: 25)),
          status: MessageStatus.read,
          reactions: ['🚀'],
        ),
      ],
      'chat_group_1': [
        Message(
          id: 'mg1_1',
          senderId: 'user_1',
          senderName: 'Amit',
          text: 'Welcome team! Let us review the roadmap for ZIPgram launch.',
          timestamp: now.subtract(const Duration(hours: 3)),
          status: MessageStatus.read,
        ),
        Message(
          id: 'mg1_2',
          senderId: 'user_2',
          senderName: 'Khushi',
          text: 'UI and assets are ready.',
          timestamp: now.subtract(const Duration(hours: 2)),
          status: MessageStatus.read,
        ),
        Message(
          id: 'mg1_3',
          senderId: 'user_4',
          senderName: 'Rahul',
          text: 'Deployment is scheduled for 8:00 PM tonight.',
          timestamp: now.subtract(const Duration(hours: 1)),
          status: MessageStatus.delivered,
        ),
      ],
    };
  }

  static List<Status> getInitialStatuses() {
    final now = DateTime.now();
    return [
      Status(
        id: 's_me',
        userId: currentUser.id,
        userName: 'My Status',
        userAvatar: currentUser.avatarUrl,
        isViewed: false,
        mediaItems: [
          StatusMedia(
            id: 'sm_me_1',
            type: StatusType.text,
            url: '',
            caption: 'Working on ZIPgram Flutter App! 🚀',
            backgroundColorHex: '#0088CC',
            timestamp: now.subtract(const Duration(hours: 1)),
          ),
        ],
      ),
      Status(
        id: 's_1',
        userId: 'user_2',
        userName: 'Khushi',
        userAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        isViewed: false,
        mediaItems: [
          StatusMedia(
            id: 'sm_1_1',
            type: StatusType.image,
            url: 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=500',
            caption: 'Weekend vibes 🏡✨',
            timestamp: now.subtract(const Duration(hours: 2)),
          ),
        ],
      ),
      Status(
        id: 's_2',
        userId: 'user_1',
        userName: 'Amit',
        userAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        isViewed: false,
        mediaItems: [
          StatusMedia(
            id: 'sm_2_1',
            type: StatusType.text,
            url: '',
            caption: 'Flutter 3.41 is blazingly fast! ⚡️',
            backgroundColorHex: '#1E293B',
            timestamp: now.subtract(const Duration(hours: 4)),
          ),
        ],
      ),
      Status(
        id: 's_3',
        userId: 'user_6',
        userName: 'Arjun',
        userAvatar: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150',
        isViewed: true,
        mediaItems: [
          StatusMedia(
            id: 'sm_3_1',
            type: StatusType.image,
            url: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=500',
            caption: 'Mountain peak morning view!',
            timestamp: now.subtract(const Duration(hours: 10)),
          ),
        ],
      ),
    ];
  }

  static List<Call> getInitialCalls() {
    final now = DateTime.now();
    return [
      Call(
        id: 'c1',
        userId: 'user_2',
        userName: 'Khushi',
        userAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        type: CallType.video,
        direction: CallDirection.incoming,
        timestamp: now.subtract(const Duration(minutes: 45)),
        duration: '12:40',
      ),
      Call(
        id: 'c2',
        userId: 'user_1',
        userName: 'Amit',
        userAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        type: CallType.voice,
        direction: CallDirection.outgoing,
        timestamp: now.subtract(const Duration(hours: 3)),
        duration: '05:15',
      ),
      Call(
        id: 'c3',
        userId: 'user_4',
        userName: 'Rahul',
        userAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        type: CallType.video,
        direction: CallDirection.missed,
        timestamp: now.subtract(const Duration(hours: 8)),
      ),
      Call(
        id: 'c4',
        userId: 'user_3',
        userName: 'Roshani',
        userAvatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
        type: CallType.voice,
        direction: CallDirection.incoming,
        timestamp: now.subtract(const Duration(days: 1)),
        duration: '02:08',
      ),
    ];
  }

  static List<Community> getInitialCommunities() {
    final now = DateTime.now();
    return [
      Community(
        id: 'comm_1',
        name: 'Flutter Global Developers',
        avatarUrl: 'https://images.unsplash.com/photo-1531482615713-2afd69097998?w=150',
        description: 'Official community for Flutter engineers, designers, and creators.',
        memberCount: 14200,
        groupCount: 8,
        latestAnnouncement: 'Flutter 3.41 Release Party starts in 2 hours!',
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      Community(
        id: 'comm_2',
        name: 'Tech & Product Leaders',
        avatarUrl: 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=150',
        description: 'Connecting Founders, PMs, and Product Strategists worldwide.',
        memberCount: 5600,
        groupCount: 4,
        latestAnnouncement: 'New AMA session with Product VP announced.',
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }
}
