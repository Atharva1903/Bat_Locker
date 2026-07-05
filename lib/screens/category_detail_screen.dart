import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../db/database_helper.dart';
import '../models/category.dart';
import '../models/password_entry.dart';
import '../utils/encryption_helper.dart';
import '../utils/theme.dart';
import '../utils/responsive.dart';
import '../widgets/password_entry_card.dart';

class CategoryDetailScreen extends StatefulWidget {
  final Category category;
  const CategoryDetailScreen({super.key, required this.category});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  List<PasswordEntry> _entries = [];
  bool _loading = true;

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
    } else if (lowerName.contains('finance') ||
        lowerName.contains('bank') ||
        lowerName.contains('money') ||
        lowerName.contains('wallet') ||
        lowerName.contains('card')) {
      return {
        'icon': Icons.account_balance_wallet_outlined,
        'color': const Color(0xFF81C784), // Light Green
        'bgColor': const Color(0xFF81C784).withAlpha(20),
      };
    } else if (lowerName.contains('social') ||
        lowerName.contains('chat') ||
        lowerName.contains('message') ||
        lowerName.contains('instagram') ||
        lowerName.contains('facebook') ||
        lowerName.contains('twitter') ||
        lowerName.contains('discord') ||
        lowerName.contains('reddit')) {
      return {
        'icon': Icons.chat_bubble_outline,
        'color': const Color(0xFF2979FF), // Bright Blue
        'bgColor': const Color(0xFF2979FF).withAlpha(20),
      };
    } else if (lowerName.contains('work') ||
        lowerName.contains('job') ||
        lowerName.contains('office') ||
        lowerName.contains('portfolio') ||
        lowerName.contains('company')) {
      return {
        'icon': Icons.business_center_outlined,
        'color': const Color(0xFFBA68C8), // Light Purple
        'bgColor': const Color(0xFFBA68C8).withAlpha(20),
      };
    }

    final colors = [
      const Color(0xFFFFA79A),
      const Color(0xFFD4AF37),
      const Color(0xFF81C784),
      const Color(0xFF2979FF),
      const Color(0xFFBA68C8),
    ];
    final icons = [
      Icons.vpn_key_outlined,
      Icons.lock_outline,
      Icons.fingerprint,
      Icons.security_outlined,
      Icons.shield_outlined,
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

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries =
        await DatabaseHelper().getPasswordsByCategory(widget.category.id!);
    final decryptedEntries = <PasswordEntry>[];
    for (final entry in entries) {
      final decryptedTitle = await EncryptionHelper.decryptText(entry.title);
      final decryptedUsername = await EncryptionHelper.decryptText(entry.username);
      final decryptedPassword = await EncryptionHelper.decryptText(entry.password);
      final decryptedNotes = await EncryptionHelper.decryptText(entry.notes ?? '');
      decryptedEntries.add(entry.copyWith(
        title: decryptedTitle.isEmpty ? entry.title : decryptedTitle,
        username: decryptedUsername.isEmpty ? entry.username : decryptedUsername,
        password: decryptedPassword.isEmpty ? entry.password : decryptedPassword,
        notes: decryptedNotes,
      ));
    }
    setState(() {
      _entries = decryptedEntries;
      _loading = false;
    });
  }

  void _showAddPasswordDialog() {
    _showPasswordFormDialog();
  }

  void _showEditPasswordDialog(PasswordEntry entry) {
    _showPasswordFormDialog(entry: entry);
  }

  void _showPasswordFormDialog({PasswordEntry? entry}) {
    final titleController = TextEditingController(text: entry?.title ?? '');
    final usernameController =
        TextEditingController(text: entry?.username ?? '');
    final passwordController =
        TextEditingController(text: entry?.password ?? '');

    // Dynamic ID calculation
    final int secId = 100 + (widget.category.id ?? 7) * 13 + (entry?.id ?? 5);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF151515), // Dark gray background
              border: Border.all(
                  color: const Color(0xFFFFA79A), width: 1.5), // Peach border
            ),
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Title / Header Row
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
                             entry == null ? 'ADD PASSWORD' : 'EDIT PASSWORD',
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
                  // Thin divider line
                  Container(
                    height: 1,
                    color: const Color(0xFF333333),
                  ),
                  const SizedBox(height: 24),
                  // Form Inputs
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
                      // ADD / SAVE Button (with dark 3D shadow offset)
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

                            if (entry == null) {
                              await DatabaseHelper().insertPassword(
                                PasswordEntry(
                                  categoryId: widget.category.id!,
                                  title: encryptedTitle,
                                  username: encryptedUsername,
                                  password: encryptedPassword,
                                  notes: '',
                                  imagePath: null,
                                ),
                              );
                            } else {
                              await DatabaseHelper().updatePassword(
                                PasswordEntry(
                                  id: entry.id,
                                  categoryId: widget.category.id!,
                                  title: encryptedTitle,
                                  username: encryptedUsername,
                                  password: encryptedPassword,
                                  notes: '',
                                  imagePath: null,
                                ),
                              );
                            }
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                            _loadEntries();
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
                              entry == null ? 'ADD' : 'SAVE',
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
                  const SizedBox(height: 24),
                  // Footer Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Three colored blocks decoration
                      Row(
                        children: [
                          Container(
                              width: 12,
                              height: 12,
                              color: const Color(0xFF6E4A3B)), // Brownish
                          const SizedBox(width: 4),
                          Container(
                              width: 12,
                              height: 12,
                              color: const Color(0xFFD4AF37)), // Goldish
                          const SizedBox(width: 4),
                          Container(
                              width: 12,
                              height: 12,
                              color: const Color(0xFFA0A0A0)), // Grayish
                        ],
                      ),
                      Text(
                        'ENCRYPTED BY BATLOCK_KERN_V4.2',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: context.sp(9),
                          color: kColorNeutral,
                          letterSpacing: 0.8,
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
                  // Thin divider line
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
                  // Warning Alert Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0x11FF0000), // Faint red
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
                      // DELETE Button
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            await DatabaseHelper().deletePassword(entry.id!);
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                            _loadEntries();
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
                color: kColorPrimary,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('BATLOCKER'),
        automaticallyImplyLeading: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kColorPrimary))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.category.name,
                    style: GoogleFonts.anton(
                      fontSize: 24,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: _entries.isEmpty
                        ? Center(
                            child: Text(
                              'No passwords yet. Tap edit to add one.',
                              style: GoogleFonts.jetBrainsMono(
                                  fontSize: 16, color: kColorNeutral),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _entries.length,
                            itemBuilder: (context, index) {
                              final entry = _entries[index];
                              // Resolve color dynamically based on category styling
                              final style = _getCategoryStyle(widget.category.name);
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
                                    _loadEntries();
                                  }
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 12.0, bottom: 12.0),
        child: _buildCustomFAB(onTap: _showAddPasswordDialog),
      ),
    );
  }
}
