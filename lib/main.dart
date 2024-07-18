import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'repository.dart';
import 'commit.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final _logger = Logger('GitHubReposApp');

final String _githubToken = dotenv.env['GITHUB_TOKEN'] ?? '';

void main() async {
  await dotenv.load(fileName: ".env");
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitHub Repos',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF58A6FF),
          brightness: Brightness.dark,
        ).copyWith(
          secondary: const Color(0xFF39D353),
          surface: const Color(0xFF161B22),
          // background: const Color(0xFF0D1117),
          surfaceContainerHighest: const Color(0xFF0D1117),
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      home: const RepositoryListPage(),
    );
  }
}

class RepositoryListPage extends StatefulWidget {
  const RepositoryListPage({super.key});

  @override
  State<RepositoryListPage> createState() => _RepositoryListPageState();
}

class _RepositoryListPageState extends State<RepositoryListPage> {
  final List<Repository> _repositories = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchRepositories();
  }

  Future<void> _fetchRepositories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/users/freeCodeCamp/repos'),
        headers: {
          'Authorization': 'token $_githubToken',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _repositories.clear();
          _repositories.addAll(data.map((json) => Repository.fromJson(json)));
          _isLoading = false;
        });
        _fetchLastCommits();
      } else {
        throw HttpException(
            'Failed to load repositories. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _logger.severe('Error fetching repositories', e);
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Failed to load repositories. Please check your internet connection and try again.';
      });
    }
  }

  Future<void> _fetchLastCommits() async {
    for (var repo in _repositories) {
      try {
        final response = await http.get(
          Uri.parse(
              'https://api.github.com/repos/freeCodeCamp/${repo.name}/commits'),
          headers: {
            'Authorization': 'token $_githubToken',
            'Accept': 'application/vnd.github.v3+json',
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          if (data.isNotEmpty) {
            final commit = Commit.fromJson(data[0]);
            setState(() {
              repo.lastCommit = commit;
            });
          }
        } else {
          throw HttpException(
              'Failed to load commits. Status code: ${response.statusCode}');
        }
      } catch (e) {
        _logger.warning('Error fetching commits for ${repo.name}', e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GitHub Repositories',
            style: Theme.of(context).textTheme.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchRepositories,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? _buildErrorWidget()
              : _repositories.isEmpty
                  ? _buildEmptyWidget()
                  : _buildRepositoryList(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _fetchRepositories,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Text(
        'No repositories found.\nTap the refresh button to try again.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  Widget _buildRepositoryList() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return MasonryGridView.count(
            crossAxisCount: constraints.maxWidth > 900 ? 3 : 2,
            itemCount: _repositories.length,
            itemBuilder: (context, index) =>
                _buildRepositoryCard(context, index),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          );
        } else {
          return ListView.builder(
            itemCount: _repositories.length,
            itemBuilder: (context, index) =>
                _buildRepositoryCard(context, index),
          );
        }
      },
    );
  }

  Widget _buildRepositoryCard(BuildContext context, int index) {
    final repo = _repositories[index];
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _launchUrl(repo.url),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withOpacity(0.8),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        repo.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        _buildStatChip(
                          context,
                          Icons.star,
                          repo.stargazersCount.toString(),
                          Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 8),
                        _buildStatChip(
                          context,
                          Icons.call_split,
                          repo.forksCount.toString(),
                          Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  repo.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                if (repo.lastCommit != null) ...[
                  Text(
                    'Last Commit',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  _buildCommitInfo(
                    icon: Icons.comment,
                    label: 'Message',
                    value: repo.lastCommit!.shortMessage,
                  ),
                  _buildCommitInfo(
                    icon: Icons.person,
                    label: 'Author',
                    value: repo.lastCommit!.authorName,
                  ),
                  _buildCommitInfo(
                    icon: Icons.calendar_today,
                    label: 'Date',
                    value: repo.lastCommit!.formattedDate,
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: () => _launchUrl(repo.lastCommit!.url),
                    child: const Text('View on GitHub'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(
      BuildContext context, IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCommitInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        _showErrorDialog('Could not launch $url');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  @override
  String toString() => message;
}
