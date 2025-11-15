
import 'package:exportasystem/models/BookingModel.dart';
import 'package:exportasystem/repository/BookingRepository.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BookingController extends GetxController {
  final _repo = BookingRepository();
  final _dateFormat = DateFormat('dd/MM/yyyy');

  final bookings = <Booking>[].obs;
  final isLoading = false.obs;
  final error = RxnString();
  final query = ''.obs;

  Future<void> load([String? q]) async {
    try {
      isLoading.value = true;
      error.value = null;
      final list = await _repo.getAll(q: (q ?? query.value));
      bookings.assignAll(list);
    } catch (e) {
      error.value = 'Falha ao carregar: $e';
    } finally {
      isLoading.value = false;
    }
  }

  String? validate({
    required String numeroBooking,
    required String armador,
    required String portoEmbarque,
    required String portoDesembarque,
    required String previsaoEmbarqueStr,
    required String previsaoDesembarqueStr,
    required String quantidadeContainersStr,
  }) {
    if (numeroBooking.trim().isEmpty) return 'Nº do Booking é obrigatório.';
    if (armador.trim().isEmpty) return 'Armador é obrigatório.';
    if (portoEmbarque.trim().isEmpty) return 'Porto de Embarque é obrigatório.';
    if (portoDesembarque.trim().isEmpty)
      return 'Porto de Desembarque é obrigatório.';

    try {
      _dateFormat.parse(previsaoEmbarqueStr.trim());
    } catch (e) {
      return 'Previsão de Embarque inválida (dd/mm/aaaa).';
    }

    try {
      _dateFormat.parse(previsaoDesembarqueStr.trim());
    } catch (e) {
      return 'Previsão de Desembarque inválida (dd/mm/aaaa).';
    }

    final qtd = int.tryParse(quantidadeContainersStr);
    if (qtd == null || qtd <= 0) return 'Quantidade de Contêineres inválida.';

    return null;
  }

  Future<bool> create({
    required String numeroBooking,
    required String armador,
    String? navio,
    required String portoEmbarque,
    required String portoDesembarque,
    required DateTime previsaoEmbarque,
    required DateTime previsaoDesembarque,
    required int quantidadeContainers,
    String? freetimeOrigem,
    String? freetimeDestino,
    DateTime? deadlineDraft,
    DateTime? deadlineVgm,
    DateTime? deadlineCarga,
  }) async {
    try {
      isLoading.value = true;
      final b = Booking(
        numeroBooking: numeroBooking,
        armador: armador,
        navio: navio,
        portoEmbarque: portoEmbarque,
        portoDesembarque: portoDesembarque,
        previsaoEmbarque: previsaoEmbarque,
        previsaoDesembarque: previsaoDesembarque,
        quantidadeContainers: quantidadeContainers,
        freetimeOrigem: freetimeOrigem,
        freetimeDestino: freetimeDestino,
        deadlineDraft: deadlineDraft,
        deadlineVgm: deadlineVgm,
        deadlineCarga: deadlineCarga,
      );
      await _repo.create(b);
      await load();
      return true;
    } catch (e) {
      error.value = 'Falha ao salvar: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateBooking(Booking booking) async {
    try {
      isLoading.value = true;
      await _repo.update(booking);
      await load();
      return true;
    } catch (e) {
      error.value = 'Falha ao atualizar: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> remove(int id) async {
    try {
      isLoading.value = true;
      await _repo.delete(id);
      await load();
    } catch (e) {
      error.value = 'Falha ao excluir: $e';
    } finally {
      isLoading.value = false;
    }
  }
}