import 'package:flutter/material.dart';
import '../../services/community_service.dart';
import '../../models/post_model.dart';
import '../../services/session_service.dart';
import '../../services/storage_service.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/constants.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class CommunityHomeScreen extends StatefulWidget {
  const CommunityHomeScreen({super.key});

  @override
  State<CommunityHomeScreen> createState() => _CommunityHomeScreenState();
}

class _CommunityHomeScreenState extends State<CommunityHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CommunityService _communityService = CommunityService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Support'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Note Board'),
            Tab(text: 'Help Desk'),
            Tab(text: 'Land Posting'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPostList('Notes'),
          _buildPostList('Help Desk'),
          _buildPostList('Land Posting'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        child: const Icon(Icons.add_comment),
      ),
    );
  }

  Widget _buildPostList(String category) {
    return StreamBuilder<List<PostModel>>(
      stream: _communityService.streamPostsByCategory(category),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.forum_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No posts in $category yet.',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final post = snapshot.data![index];
            return _buildPostCard(post);
          },
        );
      },
    );
  }

  Widget _buildPostCard(PostModel post) {
    final user = SessionService().user;
    final isLiked = user != null && post.likes.contains(user.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(
                AppConstants.primaryColorValue,
              ).withOpacity(0.1),
              child: Text(post.authorName[0].toUpperCase()),
            ),
            title: Text(post.authorName),
            subtitle: Text(DateFormat('MMM d, h:mm a').format(post.createdAt)),
            trailing: categoryIcon(post.category),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(post.content),
                if (post.imageUrl != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      post.imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
          const Divider(height: 0),
          Row(
            children: [
              TextButton.icon(
                onPressed: () =>
                    _communityService.toggleLike(post.id, user?.id ?? ''),
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : null,
                ),
                label: Text('${post.likes.length}'),
              ),
              TextButton.icon(
                onPressed: () {}, // Show replies
                icon: const Icon(Icons.comment_outlined),
                label: Text('${post.replies.length}'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget categoryIcon(String category) {
    IconData icon;
    Color color;
    switch (category) {
      case 'Help Desk':
        icon = Icons.help_outline;
        color = Colors.orange;
        break;
      case 'Land Posting':
        icon = Icons.landscape;
        color = Colors.green;
        break;
      default:
        icon = Icons.note;
        color = Colors.blue;
    }
    return Icon(icon, color: color, size: 20);
  }

  void _showCreatePostDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    File? selectedImage;
    bool isUploading = false;
    String category = _tabController.index == 0
        ? 'Notes'
        : (_tabController.index == 1 ? 'Help Desk' : 'Land Posting');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create New Post'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Content'),
                ),
                const SizedBox(height: 16),
                if (selectedImage != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          selectedImage!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          radius: 12,
                          child: IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 12,
                            ),
                            onPressed: () =>
                                setDialogState(() => selectedImage = null),
                          ),
                        ),
                      ),
                    ],
                  ),
                if (selectedImage == null)
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final img = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (img != null) {
                        setDialogState(() => selectedImage = File(img.path));
                      }
                    },
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Add Image'),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isUploading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isUploading
                  ? null
                  : () async {
                      final user = SessionService().user;
                      if (user != null && titleController.text.isNotEmpty) {
                        setDialogState(() => isUploading = true);
                        String? imageUrl;
                        if (selectedImage != null) {
                          final bytes = await selectedImage!.readAsBytes();
                          imageUrl = await StorageService().uploadImage(
                            imageBytes: bytes,
                            path:
                                'community/${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg',
                          );
                        }

                        final post = PostModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          authorId: user.id,
                          authorName: user.name,
                          title: titleController.text,
                          content: contentController.text,
                          category: category,
                          imageUrl: imageUrl,
                          createdAt: DateTime.now(),
                        );
                        await _communityService.createPost(post);
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
              child: isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}
