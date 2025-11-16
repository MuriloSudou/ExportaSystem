import 'package:exportasystem/controllers/bookingController.dart';
import 'package:exportasystem/models/BookingModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BookingFormScreen extends StatefulWidget {
  final Booking? booking;
  const BookingFormScreen({super.key, this.booking});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormStateFields {
  final numeroBookingCtrl = TextEditingController();
  final armadorCtrl = TextEditingController(); 
  final navioCtrl = TextEditingController();
  final portoEmbarqueCtrl = TextEditingController();
  final portoDesembarqueCtrl = TextEditingController();
  final previsaoEmbarqueCtrl = TextEditingController();
  final previsaoDesembarqueCtrl = TextEditingController();
  final quantidadeContainersCtrl = TextEditingController();
  final freetimeOrigemCtrl = TextEditingController();
  final freetimeDestinoCtrl = TextEditingController();
  final deadlineDraftCtrl = TextEditingController();
  final deadlineVgmCtrl = TextEditingController();
  final deadlineCargaCtrl = TextEditingController();

  void dispose() {
    numeroBookingCtrl.dispose();
    armadorCtrl.dispose();
    navioCtrl.dispose();
    portoEmbarqueCtrl.dispose();
    portoDesembarqueCtrl.dispose();
    previsaoEmbarqueCtrl.dispose();
    previsaoDesembarqueCtrl.dispose();
    quantidadeContainersCtrl.dispose();
    freetimeOrigemCtrl.dispose();
    freetimeDestinoCtrl.dispose();
    deadlineDraftCtrl.dispose();
    deadlineVgmCtrl.dispose();
    deadlineCargaCtrl.dispose();
  }
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final c = Get.find<BookingController>();
  final f = _BookingFormStateFields();
  final _dateFormat = DateFormat('dd/MM/yyyy');

 
  String? _selectedArmador; 

  
  final Map<String, String> _armadoresDisponiveis = {
    'PIL': 'assets/images/armadores/Pill.png',
    'Yang Ming': 'assets/images/armadores/yangming.png', 
    'Cosco Shipping': 'assets/images/armadores/coscoshipping.png',       
    'ONE': 'assets/images/armadores/one.png',  
    'Evergreen': 'assets/images/armadores/evergreen.png', 
  };
 

  @override
  void initState() {
    super.initState();
    final b = widget.booking;
    if (b != null) {
      f.numeroBookingCtrl.text = b.numeroBooking;
      f.armadorCtrl.text = b.armador;
      f.navioCtrl.text = b.navio ?? '';
      f.portoEmbarqueCtrl.text = b.portoEmbarque;
      f.portoDesembarqueCtrl.text = b.portoDesembarque;
      f.previsaoEmbarqueCtrl.text = _dateFormat.format(b.previsaoEmbarque);
      f.previsaoDesembarqueCtrl.text =
          _dateFormat.format(b.previsaoDesembarque);
      f.quantidadeContainersCtrl.text = b.quantidadeContainers.toString();
      f.freetimeOrigemCtrl.text = b.freetimeOrigem ?? '';
      f.freetimeDestinoCtrl.text = b.freetimeDestino ?? '';
      f.deadlineDraftCtrl.text =
          b.deadlineDraft != null ? _dateFormat.format(b.deadlineDraft!) : '';
      f.deadlineVgmCtrl.text =
          b.deadlineVgm != null ? _dateFormat.format(b.deadlineVgm!) : '';
      f.deadlineCargaCtrl.text =
          b.deadlineCarga != null ? _dateFormat.format(b.deadlineCarga!) : '';
      
   
      _selectedArmador = b.armador;
      
    }
  }

  @override
  void dispose() {
    f.dispose();
    super.dispose();
  }

  DateTime? _parseDate(String dateStr) {
    if (dateStr.trim().isEmpty) return null;
    try {
      return _dateFormat.parse(dateStr.trim());
    } catch (e) {
      return null;
    }
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime initialDate = _parseDate(controller.text) ?? DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        controller.text = _dateFormat.format(pickedDate);
      });
    }
  }

  
  Widget _buildArmadorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        Text(
          'Armador *',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodySmall?.color,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        
        
        SizedBox(
          height: 80, 
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _armadoresDisponiveis.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final armadorName = _armadoresDisponiveis.keys.elementAt(index);
              final logoPath = _armadoresDisponiveis[armadorName]!;
              final isSelected = _selectedArmador == armadorName;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedArmador = armadorName;
                    f.armadorCtrl.text = armadorName; 
                    print("Armador selecionado: ${f.armadorCtrl.text}");
                  });
                },
                child: Container(
                  width: 120, 
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey.shade300,
                      width: isSelected ? 2.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: Image.asset(
                    logoPath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => 
                      Center(child: Icon(Icons.error, color: Colors.red)),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  // =================================================================

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.booking != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar Booking' : 'Novo Booking')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: f.numeroBookingCtrl,
              decoration: const InputDecoration(labelText: 'Nº do Booking *'),
            ),
            const SizedBox(height: 12),

            
            _buildArmadorSelector(),
            

            const SizedBox(height: 12),
            TextField(
              controller: f.navioCtrl,
              decoration: const InputDecoration(labelText: 'Navio'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: f.portoEmbarqueCtrl,
              decoration: const InputDecoration(labelText: 'Porto de Embarque *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: f.portoDesembarqueCtrl,
              decoration:
                  const InputDecoration(labelText: 'Porto de Desembarque *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: f.previsaoEmbarqueCtrl,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Previsão de Embarque (ETD) *',
                hintText: 'Selecione a data',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () => _selectDate(context, f.previsaoEmbarqueCtrl),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: f.previsaoDesembarqueCtrl,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Previsão de Desembarque (ETA) *',
                hintText: 'Selecione a data',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () => _selectDate(context, f.previsaoDesembarqueCtrl),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: f.quantidadeContainersCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Qtd. Contêineres *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: f.freetimeOrigemCtrl,
              decoration: const InputDecoration(labelText: 'Freetime Origem'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: f.freetimeDestinoCtrl,
              decoration: const InputDecoration(labelText: 'Freetime Destino'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: f.deadlineDraftCtrl,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Deadline Draft',
                hintText: 'Selecione a data',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () => _selectDate(context, f.deadlineDraftCtrl),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: f.deadlineVgmCtrl,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Deadline VGM',
                hintText: 'Selecione a data',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () => _selectDate(context, f.deadlineVgmCtrl),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: f.deadlineCargaCtrl,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Deadline Carga (Cut-off)',
                hintText: 'Selecione a data',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () => _selectDate(context, f.deadlineCargaCtrl),
            ),
            const SizedBox(height: 24),
            Obx(() => ElevatedButton.icon(
                  icon: c.isLoading.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save),
                  label: Text(isEdit ? 'Salvar alterações' : 'Cadastrar'),
                  
                  onPressed: c.isLoading.value
                      ? null
                      : () async {
                          final error = c.validate(
                            numeroBooking: f.numeroBookingCtrl.text,
                            armador: f.armadorCtrl.text, // <- Já está correto
                            portoEmbarque: f.portoEmbarqueCtrl.text,
                            portoDesembarque: f.portoDesembarqueCtrl.text,
                            previsaoEmbarqueStr: f.previsaoEmbarqueCtrl.text,
                            previsaoDesembarqueStr:
                                f.previsaoDesembarqueCtrl.text,
                            quantidadeContainersStr:
                                f.quantidadeContainersCtrl.text,
                          );
                          if (error != null) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text(error)));
                            return;
                          }

                          
                          final numeroBooking = f.numeroBookingCtrl.text.trim();
                          final armador = f.armadorCtrl.text.trim(); 
                          final navio = f.navioCtrl.text.trim().isEmpty
                              ? null
                              : f.navioCtrl.text.trim();
                          final portoEmbarque = f.portoEmbarqueCtrl.text.trim();
                          final portoDesembarque =
                              f.portoDesembarqueCtrl.text.trim();
                          final previsaoEmbarque =
                              _parseDate(f.previsaoEmbarqueCtrl.text)!;
                          final previsaoDesembarque =
                              _parseDate(f.previsaoDesembarqueCtrl.text)!;
                          final quantidadeContainers =
                              int.parse(f.quantidadeContainersCtrl.text);
                          final freetimeOrigem =
                              f.freetimeOrigemCtrl.text.trim().isEmpty
                                  ? null
                                  : f.freetimeOrigemCtrl.text.trim();
                          final freetimeDestino =
                              f.freetimeDestinoCtrl.text.trim().isEmpty
                                  ? null
                                  : f.freetimeDestinoCtrl.text.trim();
                          final deadlineDraft =
                              _parseDate(f.deadlineDraftCtrl.text);
                          final deadlineVgm =
                              _parseDate(f.deadlineVgmCtrl.text);
                          final deadlineCarga =
                              _parseDate(f.deadlineCargaCtrl.text);

                          if (isEdit) {
                            final updated = widget.booking!.copyWith(
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
                              updatedAt: DateTime.now(),
                            );
                            final ok = await c.updateBooking(updated);
                            if (ok && mounted) Navigator.pop(context, true);
                          } else {
                            final ok = await c.create(
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
                            if (ok && mounted) Navigator.pop(context, true);
                          }
                        },
                )),
          ],
        ),
      ),
    );
  }
}