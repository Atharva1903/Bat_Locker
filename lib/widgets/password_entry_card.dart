import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/password_entry.dart';
import '../utils/theme.dart';
import '../utils/responsive.dart';

class PasswordEntryCard extends StatefulWidget {
  final PasswordEntry entry;
  final Color categoryColor;
  final IconData categoryIcon;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleFavorite;

  const PasswordEntryCard({
    super.key,
    required this.entry,
    required this.categoryColor,
    required this.categoryIcon,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleFavorite,
  });

  @override
  State<PasswordEntryCard> createState() => _PasswordEntryCardState();
}

class _PasswordEntryCardState extends State<PasswordEntryCard> {
  bool _obscurePassword = true;

  String _getPasswordEntryId(PasswordEntry entry) {
    final String cleanTitle = entry.title.replaceAll(RegExp(r'[^a-zA-Z]'), '');
    String prefix = 'SEC';
    if (cleanTitle.length >= 4) {
      prefix = cleanTitle.substring(0, 4).toUpperCase();
    } else if (cleanTitle.isNotEmpty) {
      prefix = cleanTitle.padRight(4, 'X').toUpperCase();
    }
    final int idVal = entry.id ?? 9;
    final int codeNum = 8000 + idVal * 113 + (entry.categoryId * 23) % 1000;
    return '$prefix-$codeNum';
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E1E1E),
        content: Text(
          '[ SYSTEM: $label COPIED TO CLINICAL RECORD ]',
          style: GoogleFonts.jetBrainsMono(
            color: widget.categoryColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: Border.all(color: widget.categoryColor, width: 1),
      ),
    );
  }

  void _showPasswordDetailsDialog(BuildContext context) {
    final String entryId = _getPasswordEntryId(widget.entry);
    bool obscureDetailsPassword = true;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext dialogBuilderContext, StateSetter setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF151515), // Dark gray background matching theme
                      border: Border.all(color: widget.categoryColor, width: 1.5),
                    ),
                    padding: const EdgeInsets.all(20.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top subtitle and close button row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'SECURITY PROTOCOL // LOCKBOX',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: dialogBuilderContext.sp(10),
                                  color: widget.categoryColor,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pop(dialogContext),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white24, width: 1),
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Header details: Icon, Title, and ID
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: widget.categoryColor.withAlpha(20),
                                  border: Border.all(
                                    color: widget.categoryColor.withAlpha(80),
                                    width: 1,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  widget.categoryIcon,
                                  color: widget.categoryColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.entry.title,
                                      style: GoogleFonts.jetBrainsMono(
                                        color: Colors.white,
                                        fontSize: dialogBuilderContext.sp(18),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'ID: $entryId',
                                      style: GoogleFonts.jetBrainsMono(
                                        color: widget.categoryColor,
                                        fontSize: dialogBuilderContext.sp(11),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 1,
                            color: widget.categoryColor.withAlpha(50),
                          ),
                          const SizedBox(height: 16),

                          // Username block
                          Text(
                            'USERNAME / IDENTITY',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: dialogBuilderContext.sp(10),
                              color: const Color(0xFFFFA79A), // Peach color used for labels
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF070707),
                              border: Border.all(color: const Color(0xFF2E2E2E), width: 1),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: Row(
                              children: [
                                Text(
                                  '> ',
                                  style: GoogleFonts.jetBrainsMono(
                                    color: const Color(0xFFFFA79A),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Expanded(
                                  child: SelectableText(
                                    widget.entry.username,
                                    style: GoogleFonts.jetBrainsMono(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => _copyToClipboard(widget.entry.username, 'IDENTITY_RECORD'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: widget.categoryColor.withAlpha(20),
                                      border: Border.all(color: widget.categoryColor.withAlpha(102), width: 1),
                                    ),
                                    child: Text(
                                      'COPY',
                                      style: GoogleFonts.jetBrainsMono(
                                        color: widget.categoryColor,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Password block
                          Text(
                            'SECURITY KEY / PASSWORD',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: dialogBuilderContext.sp(10),
                              color: const Color(0xFFFFA79A),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF070707),
                              border: Border.all(color: const Color(0xFF2E2E2E), width: 1),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: Row(
                              children: [
                                Text(
                                  '> ',
                                  style: GoogleFonts.jetBrainsMono(
                                    color: const Color(0xFFFFA79A),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Expanded(
                                  child: obscureDetailsPassword
                                      ? Row(
                                          children: List.generate(
                                            8,
                                            (index) => Container(
                                              width: 8,
                                              height: 8,
                                              margin: const EdgeInsets.symmetric(horizontal: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFCCCCCC),
                                                border: Border.all(color: Colors.white70, width: 1),
                                              ),
                                            ),
                                          ),
                                        )
                                      : SelectableText(
                                          widget.entry.password,
                                          style: GoogleFonts.jetBrainsMono(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    setDialogState(() {
                                      obscureDetailsPassword = !obscureDetailsPassword;
                                    });
                                  },
                                  child: Icon(
                                    obscureDetailsPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: widget.categoryColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => _copyToClipboard(widget.entry.password, 'SECURITY_KEY'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: widget.categoryColor.withAlpha(20),
                                      border: Border.all(color: widget.categoryColor.withAlpha(102), width: 1),
                                    ),
                                    child: Text(
                                      'COPY',
                                      style: GoogleFonts.jetBrainsMono(
                                        color: widget.categoryColor,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Notes block (if not null or empty)
                          if (widget.entry.notes != null && widget.entry.notes!.trim().isNotEmpty) ...[
                            Text(
                              'SYSTEM NOTES / MEMO',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: dialogBuilderContext.sp(10),
                                color: const Color(0xFFFFA79A),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFF070707),
                                border: Border.all(color: const Color(0xFF2E2E2E), width: 1),
                              ),
                              padding: const EdgeInsets.all(14),
                              child: SelectableText(
                                widget.entry.notes!,
                                style: GoogleFonts.jetBrainsMono(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Dialog buttons (Edit, Delete, Close)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Edit button
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  foregroundColor: widget.categoryColor,
                                ),
                                icon: const Icon(Icons.edit_outlined, size: 16),
                                label: const Text('EDIT'),
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                  widget.onEdit();
                                },
                              ),
                              const SizedBox(width: 8),
                              // Delete button
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.redAccent,
                                ),
                                icon: const Icon(Icons.delete_outline, size: 16),
                                label: const Text('DELETE'),
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                  widget.onDelete();
                                },
                              ),
                              const SizedBox(width: 8),
                              // Close button
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: widget.categoryColor,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(dialogContext),
                                child: Text(
                                  'CLOSE',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Top-Left corner bracket
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.white, width: 2),
                          left: BorderSide(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ),
                  // Bottom-Right corner bracket
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.white, width: 2),
                          right: BorderSide(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String entryId = _getPasswordEntryId(widget.entry);

    return GestureDetector(
      onTap: () => _showPasswordDetailsDialog(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF151515), // Dark background matching design
          border: Border.all(color: kColorPrimary, width: 1),
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
            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: Icon, Title, ID, and Edit/Delete Actions
                  Row(
                    children: [
                      // Icon Container
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: widget.categoryColor.withAlpha(20),
                          border: Border.all(color: widget.categoryColor.withAlpha(51), width: 1),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          widget.categoryIcon,
                          color: widget.categoryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Title and ID
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.entry.title,
                              style: GoogleFonts.jetBrainsMono(
                                color: Colors.white,
                                fontSize: context.sp(15),
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'ID: $entryId',
                              style: GoogleFonts.jetBrainsMono(
                                color: widget.categoryColor,
                                fontSize: context.sp(10),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Action Button (3-dots Popup Menu)
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white70, size: 22),
                        color: const Color(0xFF1E1E1E), // Dark theme background
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onSelected: (value) {
                          if (value == 'edit') {
                            widget.onEdit();
                          } else if (value == 'favorite') {
                            widget.onToggleFavorite();
                          } else if (value == 'delete') {
                            widget.onDelete();
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit_outlined, color: Colors.white70, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'EDIT',
                                  style: GoogleFonts.jetBrainsMono(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'favorite',
                            child: Row(
                              children: [
                                Icon(
                                  widget.entry.isFavorite ? Icons.star : Icons.star_border,
                                  color: const Color(0xFFD4AF37), // Gold star
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.entry.isFavorite ? 'UNFAVOURITE' : 'FAVOURITE',
                                  style: GoogleFonts.jetBrainsMono(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'DELETE',
                                  style: GoogleFonts.jetBrainsMono(
                                    color: Colors.redAccent,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Username Row
                  Row(
                    children: [
                      Text(
                        'Username:',
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.white70,
                          fontSize: context.sp(13),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            widget.entry.username,
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.jetBrainsMono(
                              color: Colors.white,
                              fontSize: context.sp(13),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => _copyToClipboard(widget.entry.username, 'IDENTITY_RECORD'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.categoryColor.withAlpha(20),
                            border: Border.all(color: widget.categoryColor.withAlpha(102), width: 1),
                          ),
                          child: Text(
                            'COPY',
                            style: GoogleFonts.jetBrainsMono(
                              color: widget.categoryColor,
                              fontSize: context.sp(9),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Password Row
                  Row(
                    children: [
                      Text(
                        'Password:',
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.white70,
                          fontSize: context.sp(13),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: _obscurePassword
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(
                                    6,
                                    (index) => Container(
                                      width: 12,
                                      height: 12,
                                      margin: const EdgeInsets.symmetric(horizontal: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFCCCCCC),
                                        border: Border.all(color: Colors.white70, width: 1),
                                      ),
                                    ),
                                  ),
                                )
                              : Text(
                                  widget.entry.password,
                                  textAlign: TextAlign.end,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.jetBrainsMono(
                                    color: Colors.white,
                                    fontSize: context.sp(13),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        child: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: kColorPrimary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => _copyToClipboard(widget.entry.password, 'SECURITY_KEY'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.categoryColor.withAlpha(20),
                            border: Border.all(color: widget.categoryColor.withAlpha(102), width: 1),
                          ),
                          child: Text(
                            'COPY',
                            style: GoogleFonts.jetBrainsMono(
                              color: widget.categoryColor,
                              fontSize: context.sp(9),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
