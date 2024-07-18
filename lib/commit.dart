class Commit {
  final String message;
  final String sha;
  final String authorName;
  final String authorEmail;
  final DateTime date;
  final String url;

  const Commit({
    required this.message,
    required this.sha,
    required this.authorName,
    required this.authorEmail,
    required this.date,
    required this.url,
  });

  factory Commit.fromJson(Map<String, dynamic> json) {
    return Commit(
      message: json['commit']['message'] ?? 'No commit message',
      sha: json['sha'] ?? '',
      authorName: json['commit']['author']['name'] ?? 'Unknown',
      authorEmail: json['commit']['author']['email'] ?? '',
      date: DateTime.parse(
          json['commit']['author']['date'] ?? DateTime.now().toIso8601String()),
      url: json['html_url'] ?? '',
    );
  }

  String get shortSha => sha.length > 7 ? sha.substring(0, 7) : sha;

  String get shortMessage {
    final firstLine = message.split('\n').first;
    return firstLine.length > 50
        ? '${firstLine.substring(0, 47)}...'
        : firstLine;
  }

  String get formattedDate =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
