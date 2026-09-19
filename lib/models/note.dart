class Note {
  final int? id;
  final String titre;
  final String contenu;
  final DateTime dateCreation;
  final DateTime dateModification;

  const Note({
    this.id,
    required this.titre,
    required this.contenu,
    required this.dateCreation,
    required this.dateModification,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'contenu': contenu,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int,
      titre: map['titre'] as String,
      contenu: map['contenu'] as String,
      dateCreation: DateTime.parse(
        map['date_creation'] as String,
      ),
      dateModification: DateTime.parse(
        map['date_modification'] as String,
      ),
    );
  }

  Note copyWith({
    int? id,
    String? titre,
    String? contenu,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return Note(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      contenu: contenu ?? this.contenu,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification:
          dateModification ?? this.dateModification,
    );
  }
}
