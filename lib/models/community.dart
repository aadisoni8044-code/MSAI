class Community {
  final String id;
  final String name;
  final String avatarUrl;
  final String description;
  final int memberCount;
  final int groupCount;
  final String latestAnnouncement;
  final DateTime updatedAt;

  const Community({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.description,
    required this.memberCount,
    required this.groupCount,
    required this.latestAnnouncement,
    required this.updatedAt,
  });
}
