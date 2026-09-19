import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/note.dart';
import '../theme/app_theme.dart';
import '../widgets/delete_note_dialog.dart';
import 'note_form_screen.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  List<Note> _notes = [];

  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final List<Note> notes = await _databaseHelper.getAllNotes();

      if (!mounted) {
        return;
      }

      setState(() {
        _notes = notes;
      });
    } catch (e) {
      debugPrint('Erreur pendant le chargement des notes : $e');

      if (!mounted) {
        return;
      }

      setState(() {
        _hasError = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openAddNoteScreen() async {
    final bool? noteCreated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const NoteFormScreen()),
    );

    if (noteCreated == true) {
      await _loadNotes();
    }
  }

  Future<void> _openEditNoteScreen(Note note) async {
    final bool? noteChanged = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => NoteFormScreen(note: note)),
    );

    if (noteChanged == true) {
      await _loadNotes();
    }
  }

  Future<void> _deleteNote(Note note) async {
    if (note.id == null) {
      return;
    }

    final bool confirmed = await showDeleteNoteDialog(context);

    if (!confirmed || !mounted) {
      return;
    }

    try {
      await _databaseHelper.deleteNote(note.id!);

      if (!mounted) {
        return;
      }

      await _loadNotes();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Note supprimée.')));
    } catch (e) {
      debugPrint(
        'Erreur pendant la suppression '
        'de la note : $e',
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible de supprimer la note. '
            'Veuillez réessayer.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Mes Notes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vos notes',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),

            if (!_isLoading && !_hasError)
              Text(
                _notesCountText(),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),

            if (_hasError)
              const Text(
                'Chargement impossible',
                style: TextStyle(fontSize: 13, color: AppColors.error),
              ),

            const SizedBox(height: 24),

            Expanded(child: _buildContent()),
          ],
        ),
      ),
      floatingActionButton: _hasError || _isLoading
          ? null
          : FloatingActionButton(
              onPressed: _openAddNoteScreen,
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 0,
              child: const Icon(Icons.add, size: 32),
            ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return _ErrorState(onRetry: _loadNotes);
    }

    if (_notes.isEmpty) {
      return const _EmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadNotes,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: _notes.length,
        separatorBuilder: (context, index) => const SizedBox(height: 20),
        itemBuilder: (context, index) {
          final Note note = _notes[index];

          return _NoteCard(
            note: note,
            dateText: _formatDate(note.dateModification),

            // Clic sur toute la carte
            onTap: () {
              _openEditNoteScreen(note);
            },

            // Bouton Modifier
            onEdit: () {
              _openEditNoteScreen(note);
            },

            // Bouton Supprimer
            onDelete: () {
              _deleteNote(note);
            },
          );
        },
      ),
    );
  }

  String _notesCountText() {
    if (_notes.isEmpty) {
      return '0 note enregistrée';
    }

    if (_notes.length == 1) {
      return '1 note enregistrée';
    }

    return '${_notes.length} notes enregistrées';
  }

  String _formatDate(DateTime date) {
    final DateTime now = DateTime.now();

    final DateTime today = DateTime(now.year, now.month, now.day);

    final DateTime noteDay = DateTime(date.year, date.month, date.day);

    final int difference = today.difference(noteDay).inDays;

    final String hour = date.hour.toString().padLeft(2, '0');

    final String minute = date.minute.toString().padLeft(2, '0');

    final String time = '$hour:$minute';

    if (difference == 0) {
      return "Aujourd'hui • $time";
    }

    if (difference == 1) {
      return 'Hier • $time';
    }

    final String day = date.day.toString().padLeft(2, '0');

    final String month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year} • $time';
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  final String dateText;

  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _NoteCard({
    required this.note,
    required this.dateText,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.titre,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                note.contenu,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                dateText,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.placeholder,
                ),
              ),

              const SizedBox(height: 4),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: onEdit, child: const Text('Modifier')),

                  const SizedBox(width: 4),

                  TextButton(
                    onPressed: onDelete,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                    child: const Text('Supprimer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.translate(
        offset: const Offset(0, -40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(17),
              ),
              child: const Text(
                'N',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Aucune note pour le moment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Créez votre première note pour commencer.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final Future<void> Function() onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.translate(
        offset: const Offset(0, -30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(17),
              ),
              child: const Text(
                '!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Impossible de charger vos notes',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Une erreur est survenue lors du chargement.\n'
              'Veuillez réessayer.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),

            const SizedBox(height: 58),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onRetry,
                child: const Text('Réessayer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
