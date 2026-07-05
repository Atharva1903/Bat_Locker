import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'auth_screen.dart';
import '../db/database_helper.dart';
import '../models/category.dart';
import '../models/password_entry.dart';
import '../models/note.dart';
import '../utils/theme.dart';
import '../utils/responsive.dart';
import '../utils/encryption_helper.dart';
import '../widgets/grid_background_painter.dart';
import '../widgets/password_entry_card.dart';
import 'category_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Category> _categories = [];
  Map<int, int> _categoryCounts = {};
  List<Note> _notes = [];
  bool _loading = true;
  bool _biometricEnabled = false;
  List<PasswordEntry> _favoriteEntries = [];
  int? _selectedFavoriteCategoryId;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadNotes();
    _loadFavorites();
  }

  Future<void> _loadCategories() async {
    final cats = await DatabaseHelper().getCategories();
    final Map<int, int> counts = {};
    for (final cat in cats) {
      if (cat.id != null) {
        final entries = await DatabaseHelper().getPasswordsByCategory(cat.id!);
        counts[cat.id!] = entries.length;
      }
    }
    setState(() {
      _categories = cats;
      _categoryCounts = counts;
      _loading = false;
    });
  }

  Future<void> _loadNotes() async {
    final notes = await DatabaseHelper().getNotes();
    final decryptedNotes = <Note>[];
    for (final note in notes) {
      final decryptedTitle = await EncryptionHelper.decryptText(note.title);
      final decryptedContent = await EncryptionHelper.decryptText(note.content);
      decryptedNotes.add(Note(
        id: note.id,
        title: decryptedTitle.isEmpty ? note.title : decryptedTitle,
        content: decryptedContent.isEmpty ? note.content : decryptedContent,
        createdAt: note.createdAt,
      ));
    }
    setState(() {
      _notes = decryptedNotes;
    });
  }

  Future<void> _loadFavorites() async {
    final favorites = await DatabaseHelper().getFavoritePasswords();
    final decryptedFavorites = <PasswordEntry>[];
    for (final entry in favorites) {
      final decryptedTitle = await EncryptionHelper.decryptText(entry.title);
      final decryptedUsername = await EncryptionHelper.decryptText(entry.username);
      final decryptedPassword = await EncryptionHelper.decryptText(entry.password);
      final decryptedNotes = await EncryptionHelper.decryptText(entry.notes ?? '');
      decryptedFavorites.add(entry.copyWith(
        title: decryptedTitle.isEmpty ? entry.title : decryptedTitle,
        username: decryptedUsername.isEmpty ? entry.username : decryptedUsername,
        password: decryptedPassword.isEmpty ? entry.password : decryptedPassword,
        notes: decryptedNotes,
      ));
    }
    setState(() {
      _favoriteEntries = decryptedFavorites;
    });
  }

  Map<String, dynamic> _getCategoryStyle(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('mail') ||
        lowerName.contains('gmail') ||
        lowerName.contains('email')) {
      return {
        'icon': Icons.mail_outline,
        'color': const Color(0xFFFFA79A), // Peach
        'bgColor': const Color(0xFFFFA79A).withAlpha(20),
      };
    } else if (lowerName.contains('study') ||
        lowerName.contains('school') ||
        lowerName.contains('education') ||
        lowerName.contains('learn')) {
      return {
        'icon': Icons.school_outlined,
        'color': const Color(0xFFD4AF37), // Gold
        'bgColor': const Color(0xFFD4AF37).withAlpha(20),
      };
    } else if (lowerName.contains('shop') ||
        lowerName.contains('buy') ||
        lowerName.contains('store') ||
        lowerName.contains('cart')) {
      return {
        'icon': Icons.shopping_cart_outlined,
        'color': const Color(0xFFA0A0A0), // Gray
        'bgColor': const Color(0xFFA0A0A0).withAlpha(20),
      };
    } else if (lowerName.contains('social') ||
        lowerName.contains('media') ||
        lowerName.contains('network') ||
        lowerName.contains('web')) {
      return {
        'icon': Icons.public,
        'color': const Color(0xFFFFA79A), // Peach
        'bgColor': const Color(0xFFFFA79A).withAlpha(20),
      };
    } else if (lowerName.contains('game') ||
        lowerName.contains('play') ||
        lowerName.contains('gaming')) {
      return {
        'icon': Icons.sports_esports_outlined,
        'color': const Color(0xFFD4AF37), // Gold
        'bgColor': const Color(0xFFD4AF37).withAlpha(20),
      };
    }

    // Default fallback based on index or hash, or a default style
    final colors = [
      const Color(0xFFFFA79A), // Peach
      const Color(0xFFD4AF37), // Gold
      const Color(0xFFA0A0A0), // Gray
    ];
    final icons = [
      Icons.folder_open_outlined,
      Icons.star_outline,
      Icons.label_outline,
    ];
    final hash = name.hashCode;
    final color = colors[hash.abs() % colors.length];
    final icon = icons[hash.abs() % icons.length];
    return {
      'icon': icon,
      'color': color,
      'bgColor': color.withAlpha(20),
    };
  }

  Widget _buildCategoryCard(Category cat) {
    final style = _getCategoryStyle(cat.name);
    final Color catColor = style['color'] as Color;
    final IconData catIcon = style['icon'] as IconData;
    final Color catBgColor = style['bgColor'] as Color;

    final int count = _categoryCounts[cat.id] ?? 0;
    final String countStr = count.toString().padLeft(2, '0');

    const Color peachColor = Color(0xFFFFA79A);

    return GestureDetector(
      onTap: () => _openCategoryDetail(cat),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        height: 80,
        decoration: BoxDecoration(
          color: kColorTertiary,
          border: Border.all(color: const Color(0xFF2C2C2C), width: 1),
        ),
        child: Stack(
          children: [
            // Top-Left corner bracket
            Positioned(
              top: 2,
              left: 2,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: peachColor, width: 1.5),
                    left: BorderSide(color: peachColor, width: 1.5),
                  ),
                ),
              ),
            ),
            // Bottom-Right corner bracket
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: peachColor, width: 1.5),
                    right: BorderSide(color: peachColor, width: 1.5),
                  ),
                ),
              ),
            ),
            // Left vertical color bar
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 5,
                color: catColor,
              ),
            ),
            // Content Row
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 16),
              child: Row(
                children: [
                  // Icon box
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: catBgColor,
                      border:
                          Border.all(color: catColor.withAlpha(77), width: 1.5),
                    ),
                    child: Icon(
                      catIcon,
                      color: catColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Title & entries
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat.name,
                          style: GoogleFonts.jetBrainsMono(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: context.sp(16),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ENTRIES: $countStr',
                          style: GoogleFonts.jetBrainsMono(
                            color: kColorNeutral,
                            fontSize: context.sp(11),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Edit & Delete Buttons
                  GestureDetector(
                    onTap: () => _showRenameCategoryDialog(cat),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.edit_outlined,
                          color: peachColor, size: 22),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showDeleteCategoryDialog(cat),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.delete_outline,
                          color: peachColor, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomAddCategoryDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E), // Dark gray background
              border: Border.all(
                  color: const Color(0xFF8B0000), width: 1.5), // Crimson border
            ),
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'ADD CATEGORY',
                          style: GoogleFonts.anton(
                            fontSize: context.sp(22),
                            color: const Color.fromARGB(
                                255, 255, 255, 255), // white color
                            letterSpacing: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'SYSTEM_INTERRUPT // 04',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: context.sp(9),
                          color: kColorNeutral,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Thin divider line
                  Container(
                    height: 1,
                    color: const Color(0xFF333333),
                  ),
                  const SizedBox(height: 24),
                  LockerTextField(
                    controller: nameController,
                    labelText: 'Category Title',
                    autofocus: true,
                  ),
                  const SizedBox(height: 8),
                  // Hint
                  Text(
                    'Assign unique tag for tactical organization.',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: context.sp(10),
                      color: kColorNeutral,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Buttons Row
                  Row(
                    children: [
                      // CANCEL Button
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(
                                  color: const Color(0xFFFFA79A), width: 1.5),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'CANCEL',
                              style: GoogleFonts.jetBrainsMono(
                                color: Colors.white,
                                fontSize: context.sp(14),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // ADD Button (with dark 3D shadow offset)
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            if (nameController.text.isEmpty) return;
                            await DatabaseHelper().insertCategory(
                                Category(name: nameController.text));
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                            _loadCategories();
                          },
                          child: Container(
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Color(0xFF8B0000), // Crimson Background
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black, // Dark shifted shadow
                                  offset: Offset(4, 4),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'ADD',
                              style: GoogleFonts.jetBrainsMono(
                                color: Colors.white,
                                fontSize: context.sp(14),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Footer Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '...',
                        style: GoogleFonts.jetBrainsMono(
                          color: kColorNeutral,
                          fontSize: context.sp(16),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        'SECURE_TUNNEL_ESTABLISHED',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: context.sp(9),
                          color: kColorNeutral,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showRenameCategoryDialog(Category category) {
    final nameController = TextEditingController(text: category.name);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E), // Dark gray background
              border: Border.all(
                  color: const Color(0xFF8B0000), width: 1.5), // Crimson border
            ),
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'RENAME CATEGORY',
                          style: GoogleFonts.anton(
                            fontSize: context.sp(22),
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'SYSTEM_INTERRUPT // 05',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: context.sp(9),
                          color: kColorNeutral,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Thin divider line
                  Container(
                    height: 1,
                    color: const Color(0xFF333333),
                  ),
                  const SizedBox(height: 24),
                  LockerTextField(
                    controller: nameController,
                    labelText: 'New Category Name',
                    autofocus: true,
                  ),
                  const SizedBox(height: 8),
                  // Hint
                  Text(
                    'Modify tag for tactical reorganization.',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: context.sp(10),
                      color: kColorNeutral,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Buttons Row
                  Row(
                    children: [
                      // CANCEL Button
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(
                                  color: const Color(0xFFFFA79A), width: 1.5),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'CANCEL',
                              style: GoogleFonts.jetBrainsMono(
                                color: Colors.white,
                                fontSize: context.sp(14),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // RENAME Button
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            if (nameController.text.isEmpty) return;
                            await DatabaseHelper().updateCategory(Category(
                              id: category.id,
                              name: nameController.text,
                              imagePath: category.imagePath,
                            ));
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                            _loadCategories();
                          },
                          child: Container(
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Color(0xFF8B0000), // Crimson Background
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black, // Dark shifted shadow
                                  offset: Offset(4, 4),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'RENAME',
                              style: GoogleFonts.jetBrainsMono(
                                color: Colors.white,
                                fontSize: context.sp(14),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteCategoryDialog(Category category) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E), // Dark gray background
                border: Border.all(
                    color: const Color(0xFF8B0000), width: 1.5), // Crimson border
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'DELETE CATEGORY',
                          style: GoogleFonts.anton(
                            fontSize: context.sp(22),
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'SECURITY_ALERT // 07',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: context.sp(9),
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(height: 1, color: const Color(0xFF333333)),
                  const SizedBox(height: 24),
                  Text(
                    'Are you sure you want to delete this category?',
                    style: GoogleFonts.jetBrainsMono(
                      color: Colors.white,
                      fontSize: context.sp(14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Custom styled Red alert panel
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0x11FF0000), // Very light red
                      border: Border.all(
                          color: Colors.redAccent.withAlpha(51), width: 1),
                    ),
                    child: Text(
                      'WARNING: This action is permanent. All passwords saved under this category will be lost.',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: context.sp(11),
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Confirmation Buttons Row
                  Row(
                    children: [
                      // CANCEL Button
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(
                                  color: const Color(0xFFFFA79A), width: 1.5),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'CANCEL',
                              style: GoogleFonts.jetBrainsMono(
                                color: Colors.white,
                                fontSize: context.sp(14),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // DELETE Button
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            await DatabaseHelper().deleteCategory(category.id!);
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                            _loadCategories();
                          },
                          child: Container(
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Color(0xFF8B0000), // Crimson Background
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black, // Dark shifted shadow
                                  offset: Offset(4, 4),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'DELETE',
                              style: GoogleFonts.jetBrainsMono(
                                color: Colors.white,
                                fontSize: context.sp(14),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openCategoryDetail(Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDetailScreen(category: category),
      ),
    ).then((_) {
      _loadCategories();
      _loadFavorites();
    });
  }

  Widget _buildVaultTab() {
    return _loading
        ? const Center(child: CircularProgressIndicator(color: kColorPrimary))
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: _categories.isEmpty
                ? Center(
                    child: Text(
                      'No categories yet. Tap + to add one.',
                      style: GoogleFonts.jetBrainsMono(
                          fontSize: context.sp(15), color: kColorNeutral),
                    ),
                  )
                : ListView.builder(
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      return _buildCategoryCard(_categories[index]);
                    },
                  ),
          );
  }

  Widget _buildHotkeysTab() {
    final filteredFavorites = _favoriteEntries.where((entry) {
      if (_selectedFavoriteCategoryId == null) return true;
      return entry.categoryId == _selectedFavoriteCategoryId;
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '[FAVOURITE_CREDENTIALS]',
                  style: GoogleFonts.anton(
                    fontSize: context.sp(18),
                    color: const Color(0xFFFFA79A), // Peach
                    letterSpacing: 1.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'FAV_KEY_001',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: context.sp(10),
                  color: kColorNeutral.withAlpha(120),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildRectChip(
                  label: 'ALL',
                  active: _selectedFavoriteCategoryId == null,
                  activeColor: const Color(0xFFFFA79A), // Peach
                  onTap: () {
                    setState(() {
                      _selectedFavoriteCategoryId = null;
                    });
                  },
                ),
                ..._categories.map((cat) {
                  final style = _getCategoryStyle(cat.name);
                  final Color catColor = style['color'] as Color;
                  return _buildRectChip(
                    label: cat.name,
                    active: _selectedFavoriteCategoryId == cat.id,
                    activeColor: catColor,
                    onTap: () {
                      setState(() {
                        _selectedFavoriteCategoryId = cat.id;
                      });
                    },
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: filteredFavorites.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star_outline_rounded,
                          size: context.sp(64),
                          color: kColorNeutral.withAlpha(100),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'NO FAVOURITE KEYS LOCKED',
                          style: GoogleFonts.anton(
                            fontSize: context.sp(18),
                            color: Colors.white70,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add credentials to favourites to display them here.',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: context.sp(11),
                            color: kColorNeutral,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredFavorites.length,
                    itemBuilder: (context, index) {
                      final entry = filteredFavorites[index];
                      final cat = _categories.firstWhere(
                        (c) => c.id == entry.categoryId,
                        orElse: () => Category(id: 0, name: 'Unknown'),
                      );
                      final style = _getCategoryStyle(cat.name);
                      final Color catColor = style['color'] as Color;
                      final IconData catIcon = style['icon'] as IconData;

                      return PasswordEntryCard(
                        entry: entry,
                        categoryColor: catColor,
                        categoryIcon: catIcon,
                        onEdit: () => _showEditPasswordDialog(entry),
                        onDelete: () => _showDeletePasswordDialog(entry),
                        onToggleFavorite: () async {
                          if (entry.id != null) {
                            await DatabaseHelper().toggleFavoritePassword(entry.id!, !entry.isFavorite);
                            _loadFavorites();
                            _loadCategories();
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRectChip({
    required String label,
    required bool active,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? activeColor.withAlpha(40) : Colors.transparent,
          border: Border.all(
            color: active ? activeColor : const Color(0xFF2C2C2C),
            width: 1.5,
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.jetBrainsMono(
            color: active ? Colors.white : kColorNeutral,
            fontSize: context.sp(11),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildNotesTab() {
    return _notes.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.article_outlined,
                  size: context.sp(64),
                  color: kColorNeutral.withAlpha(100),
                ),
                const SizedBox(height: 16),
                Text(
                  'NO SECURE RECORDS FOUND',
                  style: GoogleFonts.anton(
                    fontSize: context.sp(18),
                    color: Colors.white70,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the terminal FAB to initialize a new entry.',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: context.sp(12),
                    color: kColorNeutral,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            itemCount: _notes.length,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemBuilder: (context, index) {
              final note = _notes[index];
              final preview = note.content.length > 80
                  ? '${note.content.substring(0, 80)}...'
                  : note.content;

              return GestureDetector(
                onTap: () => _showNoteViewDialog(note),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151515),
                    border: Border.all(color: kColorPrimary, width: 1.2),
                  ),
                  child: Stack(
                    children: [
                      // Top-Left corner bracket
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: kColorPrimary, width: 1.5),
                              left: BorderSide(color: kColorPrimary, width: 1.5),
                            ),
                          ),
                        ),
                      ),
                      // Bottom-Right corner bracket
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: kColorPrimary, width: 1.5),
                              right: BorderSide(color: kColorPrimary, width: 1.5),
                            ),
                          ),
                        ),
                      ),
                      // Card Content
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    note.title.toUpperCase(),
                                    style: GoogleFonts.jetBrainsMono(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.sp(15),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined,
                                          color: Colors.white70, size: 20),
                                      onPressed: () => _showNoteFormDialog(note: note),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 12),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: kColorPrimary, size: 20),
                                      onPressed: () => _showDeleteNoteDialog(note),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'RECORDED: ${note.createdAt}',
                              style: GoogleFonts.jetBrainsMono(
                                color: const Color(0xFFFFA79A),
                                fontSize: context.sp(9),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              preview,
                              style: GoogleFonts.jetBrainsMono(
                                color: Colors.white70,
                                fontSize: context.sp(12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  void _showEditPasswordDialog(PasswordEntry entry) {
    _showPasswordFormDialog(entry: entry);
  }

  void _showPasswordFormDialog({required PasswordEntry entry}) {
    final titleController = TextEditingController(text: entry.title);
    final usernameController = TextEditingController(text: entry.username);
    final passwordController = TextEditingController(text: entry.password);

    final int secId = 100 + (entry.categoryId) * 13 + (entry.id ?? 5);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                border: Border.all(color: const Color(0xFFFFA79A), width: 1.5),
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SYSTEM PROTOCOL',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: context.sp(10),
                              color: const Color(0xFFFFA79A),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'EDIT PASSWORD',
                            style: GoogleFonts.anton(
                              fontSize: context.sp(26),
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'ID: SEC_$secId',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: context.sp(11),
                          color: const Color(0xFFFFA79A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(height: 1, color: const Color(0xFF333333)),
                  const SizedBox(height: 24),
                  LockerTextField(
                    controller: titleController,
                    labelText: 'Credential Name',
                    hintText: '[ Title ]',
                  ),
                  const SizedBox(height: 20),
                  LockerTextField(
                    controller: usernameController,
                    labelText: 'Identity Record',
                    hintText: '[ Username/Email ]',
                  ),
                  const SizedBox(height: 20),
                  LockerTextField(
                    controller: passwordController,
                    labelText: 'Security Key',
                    hintText: '[ Password ]',
                    obscureText: true,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(color: const Color(0xFFFFA79A), width: 1.5),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'CANCEL',
                              style: GoogleFonts.jetBrainsMono(
                                color: Colors.white,
                                fontSize: context.sp(14),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            if (titleController.text.isEmpty ||
                                usernameController.text.isEmpty ||
                                passwordController.text.isEmpty) {
                              return;
                            }
                            final encryptedTitle = await EncryptionHelper.encryptText(titleController.text);
                            final encryptedUsername = await EncryptionHelper.encryptText(usernameController.text);
                            final encryptedPassword = await EncryptionHelper.encryptText(passwordController.text);

                            await DatabaseHelper().updatePassword(
                              entry.copyWith(
                                title: encryptedTitle,
                                username: encryptedUsername,
                                password: encryptedPassword,
                              ),
                            );
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                            _loadFavorites();
                            _loadCategories();
                          },
                          child: Container(
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Color(0xFF8B0000),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black,
                                  offset: Offset(4, 4),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'SAVE',
                              style: GoogleFonts.jetBrainsMono(
                                color: Colors.white,
                                fontSize: context.sp(14),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeletePasswordDialog(PasswordEntry entry) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                border: Border.all(color: const Color(0xFF8B0000), width: 1.5),
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'DELETE PASSWORD',
                          style: GoogleFonts.anton(
                            fontSize: context.sp(22),
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'SECURITY_ALERT // 09',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: context.sp(9),
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 1,
                    color: const Color(0xFF333333),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Do you really want to delete this password entry?',
                    style: GoogleFonts.jetBrainsMono(
                        color: Colors.white, fontSize: context.sp(14)),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0x11FF0000),
                      border: Border.all(color: Colors.redAccent.withAlpha(51), width: 1),
                    ),
                    child: Text(
                      'WARNING: This action is permanent and cannot be undone.',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: context.sp(11),
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(color: const Color(0xFFFFA79A), width: 1.5),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'CANCEL',
                              style: GoogleFonts.jetBrainsMono(
                                color: Colors.white,
                                fontSize: context.sp(14),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            await DatabaseHelper().deletePassword(entry.id!);
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                            _loadFavorites();
                            _loadCategories();
                          },
                          child: Container(
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Color(0xFF8B0000),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black,
                                  offset: Offset(4, 4),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'DELETE',
                              style: GoogleFonts.jetBrainsMono(
                                color: Colors.white,
                                fontSize: context.sp(14),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showNoteFormDialog({Note? note}) {
    final titleController = TextEditingController(text: note?.title ?? '');
    final contentController = TextEditingController(text: note?.content ?? '');

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final int secId = 500 + (note?.id ?? 7) * 11;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF151515),
              border: Border.all(color: const Color(0xFFFFA79A), width: 1.5),
            ),
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ENCRYPTED RECORDS DATABASE',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: context.sp(9),
                              color: const Color(0xFFFFA79A),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            note == null ? 'CREATE RECORD' : 'EDIT RECORD',
                            style: GoogleFonts.anton(
                              fontSize: context.sp(22),
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'ID: REC_$secId',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: context.sp(10),
                          color: const Color(0xFFFFA79A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(height: 1, color: const Color(0xFF333333)),
                  const SizedBox(height: 24),
                  LockerTextField(
                    controller: titleController,
                    labelText: 'Record Subject',
                    hintText: '[ Subject Title ]',
                    autofocus: true,
                    showBrackets: false,
                  ),
                  const SizedBox(height: 20),
                  LockerTextField(
                    controller: contentController,
                    labelText: 'Secure Content',
                    hintText: '[ Content Data ]',
                    maxLines: 8,
                    showBrackets: false,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(color: const Color(0xFFFFA79A), width: 1.5),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'CANCEL',
                              style: GoogleFonts.jetBrainsMono(
                                color: Colors.white,
                                fontSize: context.sp(14),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            if (titleController.text.isEmpty || contentController.text.isEmpty) {
                              return;
                            }

                            final DateTime now = DateTime.now();
                            final String formattedDate =
                                "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} "
                                "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

                            final encryptedTitle = await EncryptionHelper.encryptText(titleController.text);
                            final encryptedContent = await EncryptionHelper.encryptText(contentController.text);

                            if (note == null) {
                              await DatabaseHelper().insertNote(
                                Note(
                                  title: encryptedTitle,
                                  content: encryptedContent,
                                  createdAt: formattedDate,
                                ),
                              );
                            } else {
                              await DatabaseHelper().updateNote(
                                Note(
                                  id: note.id,
                                  title: encryptedTitle,
                                  content: encryptedContent,
                                  createdAt: formattedDate,
                                ),
                              );
                            }

                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                            _loadNotes();
                          },
                          child: Container(
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Color(0xFF8B0000),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black,
                                  offset: Offset(4, 4),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              note == null ? 'INITIALIZE' : 'COMMIT',
                              style: GoogleFonts.jetBrainsMono(
                                color: Colors.white,
                                fontSize: context.sp(14),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showNoteViewDialog(Note note) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              border: Border.all(color: kColorPrimary, width: 1.5),
            ),
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RESTRICTED DOCUMENT ACCESS',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: context.sp(9),
                                color: const Color(0xFFFFA79A),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              note.title.toUpperCase(),
                              style: GoogleFonts.anton(
                                fontSize: context.sp(22),
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'DOC // CLASSIFIED',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: context.sp(9),
                          color: kColorPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(height: 1, color: const Color(0xFF333333)),
                  const SizedBox(height: 16),
                  Text(
                    'TIMESTAMP: ${note.createdAt}',
                    style: GoogleFonts.jetBrainsMono(
                      color: const Color(0xFFFFA79A),
                      fontSize: context.sp(10),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF070707),
                      border: Border.all(color: const Color(0xFF2C2C2C), width: 1),
                    ),
                    constraints: BoxConstraints(maxHeight: context.hp(40)),
                    child: SingleChildScrollView(
                      child: Text(
                        note.content,
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.white70,
                          fontSize: context.sp(13),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(color: const Color(0xFFFFA79A), width: 1.5),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'CLOSE',
                              style: GoogleFonts.jetBrainsMono(
                                color: Colors.white,
                                fontSize: context.sp(13),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _showNoteFormDialog(note: note);
                          },
                          child: Container(
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Color(0xFF8B0000),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black,
                                  offset: Offset(3, 3),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'EDIT',
                              style: GoogleFonts.jetBrainsMono(
                                color: Colors.white,
                                fontSize: context.sp(13),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteNoteDialog(Note note) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                border: Border.all(color: const Color(0xFF8B0000), width: 1.5),
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'DELETE FILE',
                          style: GoogleFonts.anton(
                            fontSize: context.sp(22),
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'SEC_FILE // 12',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: context.sp(9),
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(height: 1, color: const Color(0xFF333333)),
                  const SizedBox(height: 24),
                  Text(
                    'Are you sure you want to permanently delete this file entry?',
                    style: GoogleFonts.jetBrainsMono(
                      color: Colors.white,
                      fontSize: context.sp(14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0x11FF0000),
                      border: Border.all(color: Colors.redAccent.withAlpha(51), width: 1),
                    ),
                    child: Text(
                      'WARNING: This action is permanent. The classified files cannot be recovered.',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: context.sp(11),
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(color: const Color(0xFFFFA79A), width: 1.5),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'CANCEL',
                              style: GoogleFonts.jetBrainsMono(
                                color: Colors.white,
                                fontSize: context.sp(14),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            if (note.id != null) {
                              await DatabaseHelper().deleteNote(note.id!);
                            }
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                            _loadNotes();
                          },
                          child: Container(
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Color(0xFF8B0000),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black,
                                  offset: Offset(4, 4),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'DELETE',
                              style: GoogleFonts.jetBrainsMono(
                                color: Colors.white,
                                fontSize: context.sp(14),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget _buildPlaceholderTab(String title, IconData icon) {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Icon(
  //           icon,
  //           size: 64,
  //           color: kColorSecondary.withAlpha(120),
  //         ),
  //         const SizedBox(height: 16),
  //         Text(
  //           title,
  //           style: GoogleFonts.anton(
  //             fontSize: 28,
  //             color: Colors.white,
  //             letterSpacing: 2,
  //           ),
  //         ),
  //         const SizedBox(height: 8),
  //         Text(
  //           'MODULE DEACTIVATED // SECURE LOCKER',
  //           style: GoogleFonts.jetBrainsMono(
  //             fontSize: 12,
  //             color: kColorNeutral,
  //             letterSpacing: 1.5,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildCustomNavBar() {
    final List<Map<String, dynamic>> items = [
      {
        'label': 'VAULT',
        'icon': Icons.shield_outlined,
        'index': 0,
      },
      {
        'label': 'HOTKEYS',
        'icon': Icons.bolt_outlined,
        'index': 1,
      },
      {
        'label': 'FILES',
        'icon': Icons.article_outlined,
        'index': 2,
      },
      {
        'label': 'SETTINGS',
        'icon': Icons.settings_outlined,
        'index': 3,
      },
    ];

    const Color activeColor = Color(0xFFEF5350);
    const Color activeBgColor = Color(0xFF2C1E1E);

    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: kColorTertiary,
        border: Border(
          top: BorderSide(color: Color(0xFF2C2C2C), width: 1),
        ),
      ),
      child: Row(
        children: items.map((item) {
          final int idx = item['index'];
          final bool isSelected = _currentIndex == idx;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _currentIndex = idx;
                });
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: isSelected ? activeBgColor : Colors.transparent,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isSelected)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 3,
                          color: activeColor,
                        ),
                      ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item['icon'],
                          color: isSelected ? activeColor : kColorNeutral,
                          size: context.sp(22),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item['label'],
                          style: GoogleFonts.jetBrainsMono(
                            color: isSelected ? activeColor : kColorNeutral,
                            fontSize: context.sp(10),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCustomFAB({required VoidCallback onTap}) {
    const double buttonSize = 52.0;
    const double outerSize = 64.0;
    const Color peachColor = Color(0xFFFFA79A);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: outerSize,
        height: outerSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Top-Left corner bracket
            Positioned(
              top: 2,
              left: 2,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: peachColor, width: 1.5),
                    left: BorderSide(color: peachColor, width: 1.5),
                  ),
                ),
              ),
            ),
            // Bottom-Right corner bracket
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: peachColor, width: 1.5),
                    right: BorderSide(color: peachColor, width: 1.5),
                  ),
                ),
              ),
            ),
            // Center square button
            Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                color: kColorPrimary, // Solid Crimson background
                border: Border.all(color: peachColor, width: 1.5),
              ),
              child: const Icon(
                Icons.add,
                color: peachColor,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;
    switch (_currentIndex) {
      case 0:
        bodyContent = _buildVaultTab();
        break;
      case 1:
        bodyContent = _buildHotkeysTab();
        break;
      case 2:
        bodyContent = _buildNotesTab();
        break;
      case 3:
        bodyContent = _buildSettingsTab();
        break;
      default:
        bodyContent = _buildVaultTab();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('BATLOCKER'),
        automaticallyImplyLeading: false,
      ),
      body: bodyContent,
      bottomNavigationBar: _buildCustomNavBar(),
      floatingActionButton: _currentIndex == 0
          ? Padding(
              padding: const EdgeInsets.only(right: 12.0, bottom: 12.0),
              child: _buildCustomFAB(onTap: _showCustomAddCategoryDialog),
            )
          : (_currentIndex == 2
              ? Padding(
                  padding: const EdgeInsets.only(right: 12.0, bottom: 12.0),
                  child: _buildCustomFAB(onTap: () => _showNoteFormDialog()),
                )
              : null),
    );
  }

  // ----------------------------------------------------
  // SETTINGS METHODS & VIEWS
  // ----------------------------------------------------

  Widget _buildSettingsTab() {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: GridBackgroundPainter(),
          ),
        ),
        SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SECURITY PROTOCOLS Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '[SECURITY_PROTOCOLS]',
                      style: GoogleFonts.anton(
                        fontSize: context.sp(18),
                        color: const Color(0xFFFFA79A), // Orange/peach
                        letterSpacing: 1.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'SEC_FLT_882',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: context.sp(10),
                      color: kColorNeutral.withAlpha(120),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Card 1: Master Access Key
              _buildSettingsCard(
                title: 'Master Access Key',
                subtitle: 'PRIMARY CRYPT-GATE CREDENTIAL',
                trailing: GestureDetector(
                  onTap: _showChangeMasterPasswordDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B0000), // Crimson red fill
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    child: Text(
                      'CHANGE_KEY',
                      style: GoogleFonts.jetBrainsMono(
                        color: Colors.white,
                        fontSize: context.sp(12),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Card 2: Biometric Authentication
              _buildSettingsCard(
                title: 'Biometric Authentication',
                subtitle: 'FACE / FINGERPRINT INTEGRATION',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _biometricEnabled = !_biometricEnabled;
                        });
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _biometricEnabled ? const Color(0xFF2979FF) : Colors.transparent,
                          border: Border.all(color: Colors.white30, width: 1.5),
                        ),
                        alignment: Alignment.center,
                        child: _biometricEnabled
                            ? const Icon(Icons.check, color: Colors.white, size: 16)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _biometricEnabled ? const Color(0xFFFFA79A) : const Color(0xFF333333),
                        border: Border.all(color: Colors.white10, width: 1),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // DATA MANAGEMENT Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '[DATA_MANAGEMENT]',
                      style: GoogleFonts.anton(
                        fontSize: context.sp(18),
                        color: const Color(0xFFFFA79A), // Orange/peach
                        letterSpacing: 1.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'MGM_DAT_411',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: context.sp(10),
                      color: kColorNeutral.withAlpha(120),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Side-by-side Backup row
              Row(
                children: [
                  Expanded(
                    child: _buildSquareActionCard(
                      label: 'EXPORT_BACKUP',
                      icon: Icons.file_upload_outlined,
                      onTap: _exportPasswordsToPDF,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSquareActionCard(
                      label: 'IMPORT_BACKUP',
                      icon: Icons.file_download_outlined,
                      onTap: () {
                        // Do nothing for now
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Wipe all data button
              GestureDetector(
                onTap: _showWipeDataConfirmationDialog,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: const Color(0xFFFF8A80), width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF8B0000),
                        spreadRadius: 1,
                        blurRadius: 1,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF8A80), size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'WIPE_ALL_DATA',
                        style: GoogleFonts.anton(
                          color: const Color(0xFFFF8A80),
                          fontSize: context.sp(18),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Warning footer
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'CRITICAL: THIS ACTION INITIATES TOTAL SYSTEM PURGE AND IS IRREVERSIBLE.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: context.sp(10),
                      color: kColorNeutral.withAlpha(150),
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        border: Border.all(color: const Color(0xFF2C2C2C), width: 1),
      ),
      child: Stack(
        children: [
          // Top-Left corner bracket
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white60, width: 1.5),
                  left: BorderSide(color: Colors.white60, width: 1.5),
                ),
              ),
            ),
          ),
          // Bottom-Right corner bracket
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.white60, width: 1.5),
                  right: BorderSide(color: Colors.white60, width: 1.5),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.white,
                          fontSize: context.sp(15),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: GoogleFonts.jetBrainsMono(
                          color: kColorNeutral,
                          fontSize: context.sp(11),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                trailing,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSquareActionCard({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 100),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          border: Border.all(color: const Color(0xFF2C2C2C), width: 1),
        ),
        child: Stack(
          children: [
            // Top-Left corner bracket
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.white60, width: 1.5),
                    left: BorderSide(color: Colors.white60, width: 1.5),
                  ),
                ),
              ),
            ),
            // Bottom-Right corner bracket
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white60, width: 1.5),
                    right: BorderSide(color: Colors.white60, width: 1.5),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: const Color(0xFFFFA79A), // Peach icon
                    size: 24,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    label,
                    style: GoogleFonts.jetBrainsMono(
                      color: Colors.white,
                      fontSize: context.sp(12),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeMasterPasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                border: Border.all(color: const Color(0xFFFFA79A), width: 1.5),
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'MASTER SECURITY CREDENTIAL',
                          style: GoogleFonts.anton(
                            fontSize: 18,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'AUTH // 14',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          color: const Color(0xFFFFA79A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(height: 1, color: const Color(0xFF333333)),
                  const SizedBox(height: 24),
                  LockerTextField(
                    controller: currentPasswordController,
                    labelText: 'Current Master Key',
                    hintText: '[ Enter Current Key ]',
                    obscureText: true,
                    showBrackets: false,
                  ),
                  const SizedBox(height: 20),
                  LockerTextField(
                    controller: newPasswordController,
                    labelText: 'New Master Key',
                    hintText: '[ Enter New Key ]',
                    obscureText: true,
                    showBrackets: false,
                  ),
                  const SizedBox(height: 20),
                  LockerTextField(
                    controller: confirmPasswordController,
                    labelText: 'Confirm New Key',
                    hintText: '[ Re-enter New Key ]',
                    obscureText: true,
                    showBrackets: false,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(color: const Color(0xFFFFA79A), width: 1.5),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'CANCEL',
                              style: GoogleFonts.jetBrainsMono(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final currentText = currentPasswordController.text;
                            final newText = newPasswordController.text;
                            final confirmText = confirmPasswordController.text;

                            if (currentText.isEmpty || newText.isEmpty || confirmText.isEmpty) {
                              return;
                            }

                            const secureStorage = FlutterSecureStorage();
                            final storedPassword = await secureStorage.read(key: 'master_password');

                            if (storedPassword != currentText) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: const Color(0xFF1E1E1E),
                                    content: Text(
                                      '[ ERROR: INCORRECT CURRENT KEY ]',
                                      style: GoogleFonts.jetBrainsMono(color: kColorPrimary, fontWeight: FontWeight.bold),
                                    ),
                                    shape: Border.all(color: kColorPrimary),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                              return;
                            }

                            if (newText != confirmText) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: const Color(0xFF1E1E1E),
                                    content: Text(
                                      '[ ERROR: NEW KEYS DO NOT MATCH ]',
                                      style: GoogleFonts.jetBrainsMono(color: kColorPrimary, fontWeight: FontWeight.bold),
                                    ),
                                    shape: Border.all(color: kColorPrimary),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                              return;
                            }

                            await secureStorage.write(key: 'master_password', value: newText);

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFF1E1E1E),
                                  content: Text(
                                    '[ SUCCESS: MASTER ACCESS KEY UPDATED ]',
                                    style: GoogleFonts.jetBrainsMono(color: const Color(0xFFFFA79A), fontWeight: FontWeight.bold),
                                  ),
                                  shape: Border.all(color: const Color(0xFFFFA79A)),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          child: Container(
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Color(0xFF8B0000),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black,
                                  offset: Offset(4, 4),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'UPDATE',
                              style: GoogleFonts.jetBrainsMono(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _exportPasswordsToPDF() async {
    try {
      final pdf = pw.Document();
      final db = DatabaseHelper();
      final categories = await db.getCategories();

      final List<pw.TableRow> rows = [];
      rows.add(pw.TableRow(
        children: [
          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Category', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Title', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Username', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Password', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
        ],
      ));

      int entryCount = 0;
      for (final cat in categories) {
        if (cat.id != null) {
          final entries = await db.getPasswordsByCategory(cat.id!);
          for (final entry in entries) {
            entryCount++;
            final decryptedTitle = await EncryptionHelper.decryptText(entry.title);
            final decryptedUsername = await EncryptionHelper.decryptText(entry.username);
            final decryptedPassword = await EncryptionHelper.decryptText(entry.password);

            rows.add(pw.TableRow(
              children: [
                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(cat.name)),
                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(decryptedTitle.isEmpty ? entry.title : decryptedTitle)),
                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(decryptedUsername.isEmpty ? entry.username : decryptedUsername)),
                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(decryptedPassword.isEmpty ? entry.password : decryptedPassword)),
              ],
            ));
          }
        }
      }

      if (entryCount == 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF1E1E1E),
              content: Text(
                '[ SYSTEM: EXPORT FAILED - NO DATA PRESENT ]',
                style: GoogleFonts.jetBrainsMono(color: kColorPrimary, fontWeight: FontWeight.bold),
              ),
              shape: Border.all(color: kColorPrimary),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Text('BATLOCKER - PASSWORDS EXPORT BACKUP',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
              ),
              pw.SizedBox(height: 12),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: rows,
              ),
            ];
          },
        ),
      );

      String? downloadsPath;
      if (Platform.isWindows) {
        final String? home = Platform.environment['USERPROFILE'];
        if (home != null) {
          downloadsPath = "${home.replaceAll('\\', '/')}/Downloads";
        }
      } else if (Platform.isAndroid) {
        final Directory androidDir = Directory('/storage/emulated/0/Download');
        if (await androidDir.exists()) {
          downloadsPath = androidDir.path;
        }
      }

      if (downloadsPath == null) {
        final Directory appDocDir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
        downloadsPath = appDocDir.path;
      }

      final String filePath = "$downloadsPath/batlocker_passwords_backup.pdf";
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF151515),
                  border: Border.all(color: const Color(0xFFFFA79A), width: 1.5),
                ),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BACKUP COMPLETED',
                      style: GoogleFonts.anton(
                        fontSize: 22,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(height: 1, color: const Color(0xFF333333)),
                    const SizedBox(height: 16),
                    Text(
                      'PDF backup successfully compiled and written to local record system:',
                      style: GoogleFonts.jetBrainsMono(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.black,
                      width: double.infinity,
                      child: SelectableText(
                        filePath,
                        style: GoogleFonts.jetBrainsMono(
                          color: const Color(0xFFFFA79A),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: const BoxDecoration(
                            color: Color(0xFF8B0000),
                          ),
                          child: Text(
                            'CONFIRM',
                            style: GoogleFonts.jetBrainsMono(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1E1E1E),
            content: Text(
              '[ SYSTEM: EXPORT ERROR - ${e.toString().toUpperCase()} ]',
              style: GoogleFonts.jetBrainsMono(color: kColorPrimary, fontWeight: FontWeight.bold),
            ),
            shape: Border.all(color: kColorPrimary),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showWipeDataConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              border: Border.all(color: const Color(0xFF8B0000), width: 1.5),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'TOTAL SYSTEM PURGE',
                        style: GoogleFonts.anton(
                          fontSize: 22,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'PURGE // 99',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(height: 1, color: const Color(0xFF333333)),
                const SizedBox(height: 24),
                Text(
                  'Are you absolutely sure you want to WIPE all vault categories, credentials, secure files, and databases from this node?',
                  style: GoogleFonts.jetBrainsMono(color: Colors.white, fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0x15FF0000),
                    border: Border.all(color: Colors.redAccent.withAlpha(51), width: 1),
                  ),
                  child: Text(
                    'CRITICAL WARNING: This process deletes all SQLite tables and clears secure storage credentials. The action is irreversible.',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(color: const Color(0xFFFFA79A), width: 1.5),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'ABORT',
                            style: GoogleFonts.jetBrainsMono(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          Navigator.pop(context);
                          await _performWipeAllData();
                        },
                        child: Container(
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Color(0xFF8B0000),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(4, 4),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'CONFIRM_PURGE',
                            style: GoogleFonts.jetBrainsMono(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _performWipeAllData() async {
    setState(() {
      _loading = true;
    });

    try {
      // 1. Wipe database tables
      await DatabaseHelper().wipeDatabase();

      // 2. Wipe secure storage master password
      const secureStorage = FlutterSecureStorage();
      await secureStorage.delete(key: 'master_password');

      // 3. Reset local variables
      setState(() {
        _categories = [];
        _categoryCounts = {};
        _notes = [];
        _loading = false;
      });

      // 4. Redirect to AuthScreen setup
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1E1E1E),
            content: Text(
              '[ SYSTEM: PURGE ERROR - ${e.toString().toUpperCase()} ]',
              style: GoogleFonts.jetBrainsMono(color: kColorPrimary, fontWeight: FontWeight.bold),
            ),
            shape: Border.all(color: kColorPrimary),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
