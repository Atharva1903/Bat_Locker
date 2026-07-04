import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../db/database_helper.dart';
import '../models/category.dart';
import '../utils/theme.dart';
import '../utils/responsive.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Category> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await DatabaseHelper().getCategories();
    setState(() {
      _categories = cats;
      _loading = false;
    });
  }

  void _showCategoryDialog({Category? category}) {
    final nameController = TextEditingController(text: category?.name ?? '');
    String? imagePath = category?.imagePath;
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
                          category == null ? 'ADD CATEGORY' : 'EDIT CATEGORY',
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
                    labelText: 'Category Name',
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
                      // Action Button (ADD/UPDATE)
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            if (nameController.text.isEmpty) return;
                            if (category == null) {
                              await DatabaseHelper().insertCategory(Category(name: nameController.text, imagePath: imagePath));
                            } else {
                              await DatabaseHelper().updateCategory(Category(id: category.id, name: nameController.text, imagePath: imagePath));
                            }
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
                              category == null ? 'ADD' : 'UPDATE',
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

  void _deleteCategory(int id) async {
    await DatabaseHelper().deleteCategory(id);
    _loadCategories();
  }

  void _showEditCategoryDialog(Category category) {
    final nameController = TextEditingController(text: category.name);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final buttonStyle = GoogleFonts.jetBrainsMono(
          color: Colors.white,
          fontSize: context.sp(14),
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        );

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
                          'MANAGE CATEGORY',
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
                        'SYSTEM_INTERRUPT // 06',
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
                    labelText: 'Rename Category',
                    autofocus: true,
                  ),
                  const SizedBox(height: 24),
                  // Buttons Area
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
                            child: Text('CANCEL', style: buttonStyle),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // RENAME Button
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            if (nameController.text.isEmpty) return;
                            await DatabaseHelper().updateCategory(Category(id: category.id, name: nameController.text, imagePath: category.imagePath));
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
                                  color: Colors.black,
                                  offset: Offset(4, 4),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text('RENAME', style: buttonStyle),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // DELETE Button (full width, red-bordered style)
                  GestureDetector(
                    onTap: () async {
                      await DatabaseHelper().deleteCategory(category.id!);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                      _loadCategories();
                    },
                    child: Container(
                      width: double.infinity,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: Colors.redAccent, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'DELETE CATEGORY',
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.redAccent,
                          fontSize: context.sp(13),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BATLOCKER'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kColorPrimary))
          : ListView.builder(
              itemCount: _categories.length,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: cat.imagePath != null
                        ? Image.asset(cat.imagePath!, width: 40, height: 40, fit: BoxFit.cover)
                        : const Icon(Icons.folder, color: kColorSecondary),
                    title: Text(
                      cat.name,
                      style: GoogleFonts.jetBrainsMono(color: Colors.white, fontSize: context.sp(15), fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: kColorNeutral),
                          onPressed: () => _showEditCategoryDialog(cat),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: kColorPrimary),
                          onPressed: () => _deleteCategory(cat.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kColorSecondary,
        foregroundColor: Colors.black,
        shape: const CircleBorder(),
        onPressed: () => _showCategoryDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}