import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/note.dart';
import '../theme/app_theme.dart';
import '../widgets/delete_note_dialog.dart';

class NoteFormScreen
    extends StatefulWidget {
  final Note? note;

  const NoteFormScreen({
    super.key,
    this.note,
  });

  @override
  State<NoteFormScreen> createState() =>
      _NoteFormScreenState();
}

class _NoteFormScreenState
    extends State<NoteFormScreen> {
  final GlobalKey<FormState>
      _formKey =
      GlobalKey<FormState>();

  final DatabaseHelper
      _databaseHelper =
      DatabaseHelper.instance;

  late final TextEditingController
      _titleController;

  late final TextEditingController
      _contentController;

  bool _isProcessing = false;

  bool get _isEditing =>
      widget.note != null;

  @override
  void initState() {
    super.initState();

    _titleController =
        TextEditingController(
      text:
          widget.note?.titre ?? '',
    );

    _contentController =
        TextEditingController(
      text:
          widget.note?.contenu ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();

    super.dispose();
  }

  Future<void> _saveNote() async {
    FocusScope.of(context)
        .unfocus();

    final bool isValid =
        _formKey.currentState
                ?.validate() ??
            false;

    if (!isValid) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final DateTime now =
          DateTime.now();

      if (_isEditing) {
        final Note updatedNote =
            widget.note!.copyWith(
          titre:
              _titleController
                  .text
                  .trim(),
          contenu:
              _contentController
                  .text
                  .trim(),
          dateModification: now,
        );

        await _databaseHelper
            .updateNote(
          updatedNote,
        );
      } else {
        final Note newNote =
            Note(
          titre:
              _titleController
                  .text
                  .trim(),
          contenu:
              _contentController
                  .text
                  .trim(),
          dateCreation: now,
          dateModification: now,
        );

        await _databaseHelper
            .insertNote(
          newNote,
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      debugPrint(
        "Erreur pendant l'enregistrement "
        'de la note : $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Impossible de modifier '
                    'la note. Veuillez réessayer.'
                : "Impossible d'enregistrer "
                    'la note. Veuillez réessayer.',
          ),
        ),
      );
    }
  }

  Future<void> _deleteNote() async {
    final Note? note =
        widget.note;

    if (note == null ||
        note.id == null) {
      return;
    }

    final bool confirmed =
        await showDeleteNoteDialog(
      context,
    );

    if (!confirmed || !mounted) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await _databaseHelper
          .deleteNote(
        note.id!,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      debugPrint(
        'Erreur pendant la suppression '
        'de la note : $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible de supprimer la note. '
            'Veuillez réessayer.',
          ),
        ),
      );
    }
  }

  void _cancel() {
    Navigator.pop(
      context,
      false,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed:
              _isProcessing
                  ? null
                  : _cancel,
          icon: const Icon(
            Icons.arrow_back,
            color:
                AppColors.textPrimary,
          ),
        ),
        title: Text(
          _isEditing
              ? 'Modifier la note'
              : 'Nouvelle note',
          style: const TextStyle(
            fontSize: 20,
            fontWeight:
                FontWeight.w700,
            color:
                AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child:
              SingleChildScrollView(
            padding:
                const EdgeInsets
                    .fromLTRB(
              24,
              44,
              24,
              32,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .stretch,
              children: [
                const Text(
                  'Titre',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w500,
                    color:
                        AppColors
                            .textPrimary,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                TextFormField(
                  controller:
                      _titleController,
                  enabled:
                      !_isProcessing,
                  textInputAction:
                      TextInputAction
                          .next,
                  decoration:
                      const InputDecoration(
                    hintText:
                        'Titre de la note',
                  ),
                  validator:
                      (value) {
                    if (value ==
                            null ||
                        value
                            .trim()
                            .isEmpty) {
                      return 'Veuillez saisir un titre';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 30,
                ),

                const Text(
                  'Contenu',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w500,
                    color:
                        AppColors
                            .textPrimary,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                TextFormField(
                  controller:
                      _contentController,
                  enabled:
                      !_isProcessing,
                  minLines: 9,
                  maxLines: 12,
                  keyboardType:
                      TextInputType
                          .multiline,
                  textInputAction:
                      TextInputAction
                          .newline,
                  decoration:
                      const InputDecoration(
                    hintText:
                        'Écrivez votre note...',
                  ),
                  validator:
                      (value) {
                    if (value ==
                            null ||
                        value
                            .trim()
                            .isEmpty) {
                      return 'Veuillez saisir un contenu';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 48,
                ),

                ElevatedButton(
                  onPressed:
                      _isProcessing
                          ? null
                          : _saveNote,
                  child:
                      _isProcessing
                          ? const SizedBox(
                              width:
                                  22,
                              height:
                                  22,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2,
                                color:
                                    AppColors
                                        .white,
                              ),
                            )
                          : Text(
                              _isEditing
                                  ? 'Enregistrer les modifications'
                                  : 'Enregistrer',
                            ),
                ),

                const SizedBox(
                  height: 24,
                ),

                SizedBox(
                  height: 52,
                  child:
                      OutlinedButton(
                    onPressed:
                        _isProcessing
                            ? null
                            : _cancel,
                    style:
                        OutlinedButton
                            .styleFrom(
                      foregroundColor:
                          AppColors
                              .primary,
                      side:
                          const BorderSide(
                        color:
                            AppColors
                                .primary,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          11,
                        ),
                      ),
                    ),
                    child:
                        const Text(
                      'Annuler',
                      style:
                          TextStyle(
                        fontSize:
                            16,
                        fontWeight:
                            FontWeight
                                .w600,
                      ),
                    ),
                  ),
                ),

                if (_isEditing) ...[
                  const SizedBox(
                    height: 24,
                  ),

                  SizedBox(
                    height: 52,
                    child:
                        OutlinedButton(
                      onPressed:
                          _isProcessing
                              ? null
                              : _deleteNote,
                      style:
                          OutlinedButton
                              .styleFrom(
                        foregroundColor:
                            AppColors
                                .error,
                        side:
                            const BorderSide(
                          color:
                              AppColors
                                  .error,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            11,
                          ),
                        ),
                      ),
                      child:
                          const Text(
                        'Supprimer cette note',
                        style:
                            TextStyle(
                          fontSize:
                              15,
                          fontWeight:
                              FontWeight
                                  .w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
