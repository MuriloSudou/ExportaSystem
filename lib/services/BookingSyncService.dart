import 'dart:async';


import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:exportasystem/models/BookingModel.dart';
import 'package:exportasystem/repository/BookingRemoteRepository.dart';
import 'package:exportasystem/repository/bookingRepository.dart';
import 'package:googleapis/mybusinesslodging/v1.dart' hide Connectivity;

class BookingSyncService {
  final BookingRepository local;
  final BookingRemoteRepository remote;
  StreamSubscription? _connSub;
  StreamSubscription? _remoteSub;

  BookingSyncService({required this.local, required this.remote});

  Future<void> init() async {
    await pullFromRemote();

    _remoteSub = remote.watchAll().listen((snap) async {
      for (final change in snap.docChanges) {
        final data = change.doc.data();
        if (data == null) continue;
        final b = Booking.fromFirestore(data, remoteId: change.doc.id);
        final current =
            b.remoteId == null ? null : await local.getByRemoteId(b.remoteId!);

        if (current == null || b.updatedAt.isAfter(current.updatedAt)) {
          if (b.deleted) {
            if (current?.id != null) {
              await local.hardDelete(current!.id!);
            }
          } else {
            await local.upsertFromRemote(b);
          }
        }
      }
    });

    _connSub = Connectivity().onConnectivityChanged.listen((status) async {
      if (status != ConnectivityResult.none) {
        await pushDirty();
      }
    });

    final now = await Connectivity().checkConnectivity();
    if (now != ConnectivityResult.none) {
      await pushDirty();
    }
  }

  Future<void> dispose() async {
    await _connSub?.cancel();
    await _remoteSub?.cancel();
  }

  Future<void> pullFromRemote() async {
    final all = await remote.fetchAllOnce();
    for (final b in all) {
      final current =
          b.remoteId == null ? null : await local.getByRemoteId(b.remoteId!);
      if (current == null || b.updatedAt.isAfter(current.updatedAt)) {
        if (b.deleted) {
          if (current?.id != null) await local.hardDelete(current!.id!);
        } else {
          await local.upsertFromRemote(b);
        }
      }
    }
  }

  Future<void> pushDirty() async {
    final dirty = await local.getDirty();
    for (final b in dirty) {
      if (b.deleted) {
        if (b.remoteId != null) {
          await remote.deleteRemote(b.remoteId!);
          if (b.id != null) await local.hardDelete(b.id!);
        } else {
          if (b.id != null) await local.hardDelete(b.id!);
        }
        continue;
      }

      await remote.upsert(b);
      await pullFromRemote();

      if (b.id != null && b.remoteId != null) {
        await local.markSynced(b.id!);
      }
    }
  }
}