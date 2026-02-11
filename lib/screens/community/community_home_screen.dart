import 'package:flutter/material.dart';
import '../../services/community_service.dart';
import '../../models/post_model.dart';
import '../../services/session_service.dart';
import '../../services/storage_service.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/constants.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../../widgets/glass_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Community Support',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Note Board'),
            Tab(text: 'Help Desk'),
            Tab(text: 'Land Posting'),
          ],
        ),
      ),
      body: ScreenBackground(
        imagePath:
            'https://images.unsplash.com/photo-1531206715517-5c0ba140b2b8?auto=format&fit=crop&q=80&w=1920', // Community/Tech
        gradient: AppConstants.primaryGradient,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildPostList('Notes'),
            _buildPostList('Help Desk'),
            _buildPostList('Land Posting'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        backgroundColor: Colors.purpleAccent,
        child: const Icon(Icons.add_comment_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildPostList(String category) {
    return StreamBuilder<List<PostModel>>(
      stream: _communityService.streamPostsByCategory(category),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.forum_outlined, size: 64, color: Colors.white24),
                const SizedBox(height: 16),
                Text(
                  'No posts in $category yet.',
                  style: GoogleFonts.inter(color: Colors.white60),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 60, 16, 80),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  child: Text(
                    post.authorName.isNotEmpty ? post.authorName[0] : '?',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        DateFormat('MMM d, h:mm a').format(post.createdAt),
                        style: GoogleFonts.inter(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                categoryIcon(post.category),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              post.title,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              post.content,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            if (post.imageUrl != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Container(height: 1, color: Colors.white10),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () =>
                      _communityService.toggleLike(post.id, user?.id ?? ''),
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.redAccent : Colors.white60,
                    size: 20,
                  ),
                  label: Text(
                    '${post.likes.length}',
                    style: const TextStyle(color: Colors.white60),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {}, // Show replies - To be implemented
                  icon: const Icon(
                    Icons.comment_outlined,
                    color: Colors.white60,
                    size: 20,
                  ),
                  label: Text(
                    '${post.replies.length}',
                    style: const TextStyle(color: Colors.white60),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget categoryIcon(String category) {
    IconData icon;
    Color color;
    switch (category) {
      case 'Help Desk':
        icon = Icons.help_outline;
        color = Colors.orangeAccent;
        break;
      case 'Land Posting':
        icon = Icons.landscape_rounded;
        color = Colors.greenAccent;
        break;
      default:
        icon = Icons.note_alt_outlined;
        color = Colors.blueAccent;
    }
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 16),
    );
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
          backgroundColor: const Color(0xff1a0b2e),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Create New Post',
            style: GoogleFonts.outfit(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogTextField(titleController, 'Title'),
                const SizedBox(height: 12),
                _buildDialogTextField(
                  contentController,
                  'Content',
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                if (selectedImage != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
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
                              size: 14,
                            ),
                            padding: EdgeInsets.zero,
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
                    icon: const Icon(Icons.add_a_photo, color: Colors.white70),
                    label: const Text(
                      'Add Image',
                      style: TextStyle(color: Colors.white70),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isUploading ? null : () => Navigator.pop(context),
              child: const Text(
                'CANCEL',
                style: TextStyle(color: Colors.white38),
              ),
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
                          // Note: This needs StorageService to be implemented for actual upload
                          // For now assuming it works or mocking it
                          try {
                            final bytes = await selectedImage!.readAsBytes();
                            imageUrl = await StorageService().uploadImage(
                              imageBytes: bytes,
                              path:
                                  'community/${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg',
                            );
                          } catch (e) {
                            debugPrint('Upload failed: $e');
                          }
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                foregroundColor: Colors.white,
              ),
              child: isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('POST'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.purpleAccent),
        ),
      ),
    );
  }
}
