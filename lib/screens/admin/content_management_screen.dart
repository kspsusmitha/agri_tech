import 'package:flutter/material.dart';
import '../../services/content_service.dart';
import '../../utils/constants.dart';
import '../../widgets/glass_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class ContentManagementScreen extends StatefulWidget {
  const ContentManagementScreen({super.key});

  @override
  State<ContentManagementScreen> createState() =>
      _ContentManagementScreenState();
}

class _ContentManagementScreenState extends State<ContentManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ContentService _contentService = ContentService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Library Control',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.purpleAccent,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 13),
          tabs: const [
            Tab(text: 'FERTILIZERS'),
            Tab(text: 'LIFECYCLES'),
          ],
        ),
      ),
      body: GradientBackground(
        colors: AppConstants.purpleGradient,
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight + 80),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildFertilizersTab(), _buildLifecyclesTab()],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.purpleAccent,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildFertilizersTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _contentService.streamFertilizers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white24),
          );
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) return _buildEmptyState('No fertilizers found');

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildContentItem(
              title: item['name'] ?? 'Unknown',
              subtitle: item['description'] ?? '',
              onDelete: () => _contentService.deleteFertilizer(item['id']),
              icon: Icons.eco_rounded,
            );
          },
        );
      },
    );
  }

  Widget _buildLifecyclesTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _contentService.streamCropLifecycles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white24),
          );
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) return _buildEmptyState('No lifecycles recorded');

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildContentItem(
              title: item['cropName'] ?? 'Unknown',
              subtitle: '${item['stage']} • ${item['duration']} days',
              onDelete: () {}, // Delete logic
              icon: Icons.grass_rounded,
            );
          },
        );
      },
    );
  }

  Widget _buildContentItem({
    required String title,
    required String subtitle,
    required VoidCallback onDelete,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: 20,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.purpleAccent, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.redAccent,
                size: 20,
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books_outlined, size: 64, color: Colors.white10),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.inter(color: Colors.white24, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    final isFertilizer = _tabController.index == 0;
    final nameController = TextEditingController(); // Name or Crop Name
    final descController = TextEditingController(); // Description or Stage
    final durationController =
        TextEditingController(); // Duration (Lifecycle only)
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff1a0b2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          isFertilizer ? 'Add Fertilizer' : 'Add Lifecycle',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: isFertilizer ? 'Fertilizer Name' : 'Crop Name',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white24),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.purpleAccent),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              if (isFertilizer)
                TextFormField(
                  controller: descController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white24),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.purpleAccent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 3,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                )
              else ...[
                TextFormField(
                  controller: descController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Stage (e.g. Seedling)',
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white24),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.purpleAccent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: durationController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Duration (Days)',
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white24),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.purpleAccent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.white38),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                if (isFertilizer) {
                  await _contentService.saveFertilizer({
                    'name': nameController.text,
                    'description': descController.text,
                  });
                } else {
                  await _contentService.saveCropLifecycle({
                    'cropName': nameController.text,
                    'stage': descController.text,
                    'duration': int.parse(durationController.text),
                  });
                }
                if (context.mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purpleAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }
}
