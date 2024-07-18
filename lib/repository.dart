import 'commit.dart';

class Repository {
  final String name;
  final String description;
  final int stargazersCount;
  final int forksCount;
  Commit? lastCommit;
  final String url;

  Repository({
    required this.name,
    required this.description,
    required this.stargazersCount,
    required this.forksCount,
    this.lastCommit,
    required this.url,
  });

  factory Repository.fromJson(Map<String, dynamic> json) {
    return Repository(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      stargazersCount: json['stargazers_count'] ?? 0,
      forksCount: json['forks_count'] ?? 0,
      url: json['html_url'] ?? '',
    );
  }
}
