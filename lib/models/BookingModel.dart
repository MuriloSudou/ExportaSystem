class Booking {
 
  final int? id; 
  final String? remoteId; 
  final bool dirty; 
  final bool deleted; 
  final String numeroBooking;
  final String armador;
  final String? navio;
  final String portoEmbarque;
  final String portoDesembarque;
  final DateTime previsaoEmbarque; // ETD
  final DateTime previsaoDesembarque; // ETA
  final int quantidadeContainers;
  final String? freetimeOrigem;
  final String? freetimeDestino;
  final DateTime? deadlineDraft;
  final DateTime? deadlineVgm;
  final DateTime? deadlineCarga;

  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    this.id,
    this.remoteId,
    required this.numeroBooking,
    required this.armador,
    this.navio,
    required this.portoEmbarque,
    required this.portoDesembarque,
    required this.previsaoEmbarque,
    required this.previsaoDesembarque,
    required this.quantidadeContainers,
    this.freetimeOrigem,
    this.freetimeDestino,
    this.deadlineDraft,
    this.deadlineVgm,
    this.deadlineCarga,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.dirty = false,
    this.deleted = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Booking copyWith({
    int? id,
    String? remoteId,
    String? numeroBooking,
    String? armador,
    String? navio,
    String? portoEmbarque,
    String? portoDesembarque,
    DateTime? previsaoEmbarque,
    DateTime? previsaoDesembarque,
    int? quantidadeContainers,
    String? freetimeOrigem,
    String? freetimeDestino,
    DateTime? deadlineDraft,
    DateTime? deadlineVgm,
    DateTime? deadlineCarga,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? dirty,
    bool? deleted,
  }) {
    return Booking(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      numeroBooking: numeroBooking ?? this.numeroBooking,
      armador: armador ?? this.armador,
      navio: navio ?? this.navio,
      portoEmbarque: portoEmbarque ?? this.portoEmbarque,
      portoDesembarque: portoDesembarque ?? this.portoDesembarque,
      previsaoEmbarque: previsaoEmbarque ?? this.previsaoEmbarque,
      previsaoDesembarque: previsaoDesembarque ?? this.previsaoDesembarque,
      quantidadeContainers: quantidadeContainers ?? this.quantidadeContainers,
      freetimeOrigem: freetimeOrigem ?? this.freetimeOrigem,
      freetimeDestino: freetimeDestino ?? this.freetimeDestino,
      deadlineDraft: deadlineDraft ?? this.deadlineDraft,
      deadlineVgm: deadlineVgm ?? this.deadlineVgm,
      deadlineCarga: deadlineCarga ?? this.deadlineCarga,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dirty: dirty ?? this.dirty,
      deleted: deleted ?? this.deleted,
    );
  }

  
  Map<String, dynamic> toMap() => {
        'id': id,
        'remoteId': remoteId,
        'numeroBooking': numeroBooking,
        'armador': armador,
        'navio': navio,
        'portoEmbarque': portoEmbarque,
        'portoDesembarque': portoDesembarque,
        'previsaoEmbarque': previsaoEmbarque.millisecondsSinceEpoch,
        'previsaoDesembarque': previsaoDesembarque.millisecondsSinceEpoch,
        'quantidadeContainers': quantidadeContainers,
        'freetimeOrigem': freetimeOrigem,
        'freetimeDestino': freetimeDestino,
        'deadlineDraft': deadlineDraft?.millisecondsSinceEpoch,
        'deadlineVgm': deadlineVgm?.millisecondsSinceEpoch,
        'deadlineCarga': deadlineCarga?.millisecondsSinceEpoch,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
        'dirty': dirty ? 1 : 0,
        'deleted': deleted ? 1 : 0,
      };

  
  factory Booking.fromMap(Map<String, dynamic> m) {
    
    DateTime? _parseDate(int? millis) {
      return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
    }

    return Booking(
      id: m['id'] as int?,
      remoteId: m['remoteId'] as String?,
      numeroBooking: m['numeroBooking'] as String,
      armador: m['armador'] as String,
      navio: m['navio'] as String?,
      portoEmbarque: m['portoEmbarque'] as String,
      portoDesembarque: m['portoDesembarque'] as String,
      previsaoEmbarque:
          DateTime.fromMillisecondsSinceEpoch(m['previsaoEmbarque'] as int),
      previsaoDesembarque:
          DateTime.fromMillisecondsSinceEpoch(m['previsaoDesembarque'] as int),
      quantidadeContainers: (m['quantidadeContainers'] as num).toInt(),
      freetimeOrigem: m['freetimeOrigem'] as String?,
      freetimeDestino: m['freetimeDestino'] as String?,
      deadlineDraft: _parseDate(m['deadlineDraft'] as int?),
      deadlineVgm: _parseDate(m['deadlineVgm'] as int?),
      deadlineCarga: _parseDate(m['deadlineCarga'] as int?),
      createdAt: DateTime.fromMillisecondsSinceEpoch(m['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(m['updatedAt'] as int),
      dirty: (m['dirty'] ?? 0) == 1,
      deleted: (m['deleted'] ?? 0) == 1,
    );
  }

  Map<String, dynamic> toFirestore(String ownerUid) => {
        'ownerUid': ownerUid,
        'numeroBooking': numeroBooking,
        'armador': armador,
        'navio': navio,
        'portoEmbarque': portoEmbarque,
        'portoDesembarque': portoDesembarque,
        'previsaoEmbarque': previsaoEmbarque.millisecondsSinceEpoch,
        'previsaoDesembarque': previsaoDesembarque.millisecondsSinceEpoch,
        'quantidadeContainers': quantidadeContainers,
        'freetimeOrigem': freetimeOrigem,
        'freetimeDestino': freetimeDestino,
        'deadlineDraft': deadlineDraft?.millisecondsSinceEpoch,
        'deadlineVgm': deadlineVgm?.millisecondsSinceEpoch,
        'deadlineCarga': deadlineCarga?.millisecondsSinceEpoch,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
        'deleted': deleted,
      };

 
  static Booking fromFirestore(
    Map<String, dynamic> d, {
    String? remoteId,
  }) {
  
    DateTime? _parseDate(int? millis) {
      return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
    }

    return Booking(
      remoteId: remoteId,
      numeroBooking: d['numeroBooking'] as String,
      armador: d['armador'] as String,
      navio: d['navio'] as String?,
      portoEmbarque: d['portoEmbarque'] as String,
      portoDesembarque: d['portoDesembarque'] as String,
      previsaoEmbarque:
          DateTime.fromMillisecondsSinceEpoch(d['previsaoEmbarque'] as int),
      previsaoDesembarque:
          DateTime.fromMillisecondsSinceEpoch(d['previsaoDesembarque'] as int),
      quantidadeContainers: (d['quantidadeContainers'] as num).toInt(),
      freetimeOrigem: d['freetimeOrigem'] as String?,
      freetimeDestino: d['freetimeDestino'] as String?,
      deadlineDraft: _parseDate(d['deadlineDraft'] as int?),
      deadlineVgm: _parseDate(d['deadlineVgm'] as int?),
      deadlineCarga: _parseDate(d['deadlineCarga'] as int?),
      createdAt: DateTime.fromMillisecondsSinceEpoch(d['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(d['updatedAt'] as int),
      deleted: (d['deleted'] ?? false) as bool,
      dirty: false, 
    );
  }
}