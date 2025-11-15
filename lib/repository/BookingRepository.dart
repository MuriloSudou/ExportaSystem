
import 'package:exportasystem/models/BookingModel.dart';
import 'package:exportasystem/helper/databaseHelper.dart';
import 'package:sqflite/sqflite.dart';

class BookingRepository {
  final _dbHelper = DatabaseHelper.instance;

  Future<int> create(Booking booking) async {
    final db = await _dbHelper.database;
    
    return await db.insert(
      'bookings',
      booking.copyWith(dirty: true).toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<Booking>> getAll({String? q}) async {
    final db = await _dbHelper.database;
    final where = <String>['deleted = 0'];
    final args = <Object?>[];


    if ((q ?? '').trim().isNotEmpty) {
      where.add('(numeroBooking LIKE ? OR armador LIKE ? OR navio LIKE ?)');
      args.addAll(['%$q%', '%$q%', '%$q%']);
    }

    final rows = await db.query(
      'bookings',
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: 'updatedAt DESC',
    );
    return rows.map(Booking.fromMap).toList();
  }

  Future<Booking?> getById(int id) async {
    final db = await _dbHelper.database;
    final rows = await db.query('bookings', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Booking.fromMap(rows.first);
  }

  Future<Booking?> getByRemoteId(String remoteId) async {
    final db = await _dbHelper.database;
    final rows = await db.query('bookings', where: 'remoteId = ?', whereArgs: [remoteId]);
    if (rows.isEmpty) return null;
    return Booking.fromMap(rows.first);
  }

  Future<int> update(Booking booking) async {
    if (booking.id == null) throw ArgumentError('Booking sem ID para update.');
    final db = await _dbHelper.database;
    
    final updated = booking.copyWith(updatedAt: DateTime.now(), dirty: true);
    return await db.update(
      'bookings',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [booking.id],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;
 
    return await db.update(
      'bookings',
      {'deleted': 1, 'dirty': 1, 'updatedAt': now},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===== Helpers de sincronização (usados pelo remoto) =====
  Future<void> upsertFromRemote(Booking remote) async {
    final db = await _dbHelper.database;
    
    final existing = await getByRemoteId(remote.remoteId!);
    
    final data = remote.copyWith(dirty: false).toMap();
    
    if (existing == null) {
      await db.insert('bookings', data, conflictAlgorithm: ConflictAlgorithm.ignore);
    } else {
      await db.update('bookings', data, where: 'id = ?', whereArgs: [existing.id]);
    }
  }

  Future<List<Booking>> getDirty() async {
    final db = await _dbHelper.database;
    final rows = await db.query('bookings', where: 'dirty = 1');
    return rows.map(Booking.fromMap).toList();
  }

  Future<void> markSynced(int id) async {
    final db = await _dbHelper.database;
    await db.update('bookings', {'dirty': 0}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> setRemoteId(int id, String remoteId) async {
    final db = await _dbHelper.database;
    
    await db.update('bookings', {'remoteId': remoteId, 'dirty': 0}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> hardDelete(int id) async {
    final db = await _dbHelper.database;
    await db.delete('bookings', where: 'id = ?', whereArgs: [id]);
  }

  
  Future<int> adjustContainerCount({required int id, required int delta}) async {
    final db = await _dbHelper.database;
    final updatedAt = DateTime.now().millisecondsSinceEpoch;
    return await db.rawUpdate(
      '''
      UPDATE bookings
      SET quantidadeContainers = quantidadeContainers + ?, updatedAt = ?, dirty = 1
      WHERE id = ?
      ''',
      [delta, updatedAt, id],
    );
  }
}