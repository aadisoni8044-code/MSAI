class TabItem {
  final String id;
  String url;
  String title;
  String? favicon;
  double progress;
  bool isLoading;
  bool isPrivate;
  bool isDesktopMode;
  String? currentHtmlSnippet;
  String? selectedText;

  TabItem({
    required this.id,
    this.url = '',
    this.title = 'New Tab',
    this.favicon,
    this.progress = 0.0,
    this.isLoading = false,
    this.isPrivate = false,
    this.isDesktopMode = false,
    this.currentHtmlSnippet,
    this.selectedText,
  });

  TabItem copyWith({
    String? id,
    String? url,
    String? title,
    String? favicon,
    double? progress,
    bool? isLoading,
    bool? isPrivate,
    bool? isDesktopMode,
    String? currentHtmlSnippet,
    String? selectedText,
  }) {
    return TabItem(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      favicon: favicon ?? this.favicon,
      progress: progress ?? this.progress,
      isLoading: isLoading ?? this.isLoading,
      isPrivate: isPrivate ?? this.isPrivate,
      isDesktopMode: isDesktopMode ?? this.isDesktopMode,
      currentHtmlSnippet: currentHtmlSnippet ?? this.currentHtmlSnippet,
      selectedText: selectedText ?? this.selectedText,
    );
  }
}
