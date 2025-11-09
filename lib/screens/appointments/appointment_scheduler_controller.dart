import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../services/database_service.dart';

class SpecialtyInfo {
  final String id;
  final String name;
  final Color color;
  final String description;

  SpecialtyInfo({
    required this.id,
    required this.name,
    required this.color,
    required this.description,
  });
}

class DoctorInfo {
  final String id;
  final String name;
  final String specialtyId;
  final String specialtyName;
  final String crm;
  final String experience;
  final Map<int, List<String>> weeklySlots;

  DoctorInfo({
    required this.id,
    required this.name,
    required this.specialtyId,
    required this.specialtyName,
    required this.crm,
    required this.experience,
    required this.weeklySlots,
  });
}

class AppointmentBooking {
  final String id;
  final String doctorId;
  final String doctorName;
  final String specialtyId;
  final String specialtyName;
  final DateTime startTime;
  final Duration duration;

  AppointmentBooking({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.specialtyId,
    required this.specialtyName,
    required this.startTime,
    this.duration = const Duration(minutes: 30),
  });
}

const List<Color> _specialtyColors = [
  Color(0xFF2563EB),
  Color(0xFF10B981),
  Color(0xFFF97316),
  Color(0xFFEC4899),
  Color(0xFF7C3AED),
  Color(0xFF14B8A6),
  Color(0xFFEF4444),
  Color(0xFF0EA5E9),
];

const List<Map<int, List<String>>> _slotTemplates = [
  {
    DateTime.monday: ['09:00', '09:30', '10:00', '10:30', '14:00', '14:30'],
    DateTime.wednesday: ['09:00', '09:30', '10:00', '10:30', '16:00'],
    DateTime.friday: ['08:30', '09:00', '09:30', '10:00'],
  },
  {
    DateTime.tuesday: ['08:00', '08:30', '09:00', '09:30', '13:00', '13:30'],
    DateTime.thursday: ['10:00', '10:30', '11:00', '11:30', '15:00', '15:30'],
  },
  {
    DateTime.monday: ['11:00', '11:30', '14:00', '14:30'],
    DateTime.thursday: ['09:00', '09:30', '10:00', '10:30', '16:00'],
    DateTime.saturday: ['09:00', '09:30', '10:00'],
  },
  {
    DateTime.tuesday: ['14:00', '14:30', '15:00', '15:30'],
    DateTime.wednesday: ['08:30', '09:00', '09:30', '10:00'],
  },
  {
    DateTime.monday: ['08:00', '08:30', '09:00', '09:30', '10:00'],
    DateTime.friday: ['13:00', '13:30', '14:00', '14:30'],
  },
];

class AppointmentSchedulerController extends GetxController {
  final RxList<SpecialtyInfo> specialties = <SpecialtyInfo>[].obs;
  final RxList<DoctorInfo> doctors = <DoctorInfo>[].obs;
  final RxList<AppointmentBooking> appointments = <AppointmentBooking>[].obs;

  final RxnString selectedSpecialtyId = RxnString();
  final RxnString selectedDoctorId = RxnString();
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxnString selectedSlot = RxnString();
  final RxString specialtyQuery = ''.obs;
  final RxString doctorQuery = ''.obs;
  final TextEditingController specialtySearchController = TextEditingController();
  final TextEditingController doctorSearchController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxString loadError = ''.obs;

  bool _hasLoaded = false;

  List<DateTime> get availableDates => List.generate(
        14,
        (index) => DateTime.now().add(Duration(days: index))._copyWithTime(0, 0),
      );

  SpecialtyInfo? get selectedSpecialty => specialties.firstWhereOrNull((s) => s.id == selectedSpecialtyId.value);

  DoctorInfo? get selectedDoctor => doctors.firstWhereOrNull((d) => d.id == selectedDoctorId.value);

  @override
  void onInit() {
    super.onInit();
    ensureDataLoaded();
  }

  Future<void> ensureDataLoaded({bool force = false}) async {
    if (isLoading.value) return;
    if (_hasLoaded && !force) return;
    await _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    isLoading.value = true;
    loadError.value = '';
    try {
      final database = DatabaseService();
      final rawDoctors = await database.getDoctors();

      final List<DoctorInfo> doctorList = [];
      final Map<String, SpecialtyInfo> specialtyMap = {};
      var specialtyIndex = 0;

      for (final raw in rawDoctors) {
        final id = (raw['id'] ?? raw['_id'] ?? '').toString();
        if (id.isEmpty) continue;

        final name = (raw['nome'] ?? 'Profissional de saúde').toString();
        final specialtyName = (raw['areaAtuacao'] ?? 'Especialidade não informada').toString();
        final specialtyId = _normalizeSpecialtyId(specialtyName);

        var specialty = specialtyMap[specialtyId];
        if (specialty == null) {
          final color = _specialtyColors[specialtyIndex % _specialtyColors.length];
          specialty = SpecialtyInfo(
            id: specialtyId,
            name: specialtyName,
            color: color,
            description: _buildSpecialtyDescription(specialtyName),
          );
          specialtyMap[specialtyId] = specialty;
          specialtyIndex++;
        }

        final crm = (raw['crm'] ?? 'CRM não informado').toString();
        final experience = _buildDoctorExperience(raw);
        final weeklySlots = _generateWeeklySlots(doctorList.length);

        doctorList.add(
          DoctorInfo(
            id: id,
            name: name,
            specialtyId: specialtyId,
            specialtyName: specialtyName,
            crm: crm,
            experience: experience,
            weeklySlots: weeklySlots,
          ),
        );
      }

      specialties.assignAll(specialtyMap.values.toList());
      doctors.assignAll(doctorList);
      _hasLoaded = true;
    } catch (e, stack) {
      loadError.value = 'Não foi possível carregar os médicos. Tente novamente mais tarde.';
      debugPrint('Erro ao carregar médicos: $e\n$stack');
    } finally {
      isLoading.value = false;
    }
  }

  void resetSelections() {
    specialtySearchController.clear();
    doctorSearchController.clear();
    specialtyQuery.value = '';
    doctorQuery.value = '';
    selectedSpecialtyId.value = null;
    selectedDoctorId.value = null;
    selectedSlot.value = null;
    selectedDate.value = DateTime.now();
  }

  String _normalizeSpecialtyId(String name) {
    return name.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  }

  String _buildSpecialtyDescription(String name) {
    return 'Atendimento especializado em $name.';
  }

  String _buildDoctorExperience(Map<String, dynamic> data) {
    final consultorio = (data['enderecoConsultorio'] ?? '').toString().trim();
    final cidade = (data['cidade'] ?? '').toString().trim();
    final estado = (data['estado'] ?? '').toString().trim();
    final telefoneConsultorio = (data['telefoneConsultorio'] ?? '').toString().trim();
    final telefonePessoal = (data['telefonePessoal'] ?? '').toString().trim();

    final detalhes = <String>[];
    final local = [consultorio, cidade, estado].where((part) => part.isNotEmpty).join(', ');
    if (local.isNotEmpty) {
      detalhes.add('Consultório em $local');
    }

    final contato = telefoneConsultorio.isNotEmpty ? telefoneConsultorio : telefonePessoal;
    if (contato.isNotEmpty) {
      detalhes.add('Contato: $contato');
    }

    if (detalhes.isEmpty) {
      return 'Toque para visualizar a agenda disponível.';
    }

    return detalhes.join(' • ');
  }

  Map<int, List<String>> _generateWeeklySlots(int index) {
    final template = _slotTemplates[index % _slotTemplates.length];
    return template.map((weekday, slots) => MapEntry(weekday, List<String>.from(slots)));
  }

  List<SpecialtyInfo> get filteredSpecialties {
    final query = specialtyQuery.value.trim().toLowerCase();
    if (query.isEmpty) return specialties;
    return specialties
        .where((s) =>
            s.name.toLowerCase().contains(query) ||
            s.description.toLowerCase().contains(query))
        .toList();
  }

  List<DoctorInfo> get filteredDoctors {
    final specialtyId = selectedSpecialtyId.value;
    if (specialtyId == null) {
      return const [];
    }
    final base = doctors.where((d) => d.specialtyId == specialtyId);
    final query = doctorQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      return base.toList();
    }
    return base
        .where((d) =>
            d.name.toLowerCase().contains(query) ||
            d.crm.toLowerCase().contains(query) ||
            d.experience.toLowerCase().contains(query))
        .toList();
  }

  void updateSpecialtySearch(String value) {
    specialtyQuery.value = value;
  }

  void updateDoctorSearch(String value) {
    doctorQuery.value = value;
  }

  void selectSpecialty(String specialtyId) {
    if (selectedSpecialtyId.value == specialtyId) return;
    selectedSpecialtyId.value = specialtyId;
    selectedDoctorId.value = null;
    selectedSlot.value = null;
    selectedDate.value = DateTime.now();
    final specialty = selectedSpecialty;
    if (specialty != null) {
      specialtySearchController.text = specialty.name;
      specialtySearchController.selection = TextSelection.collapsed(offset: specialty.name.length);
      specialtyQuery.value = specialty.name;
    }
    doctorQuery.value = '';
    doctorSearchController.clear();
  }

  void selectDoctor(String doctorId) {
    if (selectedDoctorId.value == doctorId) return;
    selectedDoctorId.value = doctorId;
    selectedSlot.value = null;
    selectedDate.value = DateTime.now();
    final doctor = selectedDoctor;
    if (doctor != null) {
      doctorSearchController.text = doctor.name;
      doctorSearchController.selection = TextSelection.collapsed(offset: doctor.name.length);
      doctorQuery.value = doctor.name;
    }
  }

  void selectDate(DateTime date) {
    final normalized = date._copyWithTime(0, 0);
    selectedDate.value = normalized;
    selectedSlot.value = null;
  }

  void selectSlot(String slot) {
    selectedSlot.value = slot;
  }

  List<String> getAvailableSlotsForSelectedDoctor() {
    selectedSlot.value = null;
    return const [];
  }

  bool _isSlotAvailable(String doctorId, DateTime date, String slot) {
    return !appointments.any((booking) {
      if (booking.doctorId != doctorId) return false;
      return booking.startTime.year == date.year &&
          booking.startTime.month == date.month &&
          booking.startTime.day == date.day &&
          DateFormat('HH:mm').format(booking.startTime) == slot;
    });
  }

  Future<bool> confirmAppointment() async {
    final doctor = selectedDoctor;
    final slot = selectedSlot.value;
    final specialty = selectedSpecialty;

    if (doctor == null || slot == null || specialty == null) {
      Get.snackbar(
        'Informações incompletas',
        'Selecione especialidade, médico, data e horário disponíveis.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: const Color(0xFF1E293B),
      );
      return false;
    }

    final startTime = combineDateAndSlot(selectedDate.value, slot);
    selectedSlot.value = null;

    Get.snackbar(
      'Consulta agendada',
      'Seu horário com ${doctor.name} foi reservado.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: const Color(0xFF1E293B),
    );
    return true;
  }

  List<AppointmentBooking> get upcomingAppointments {
    final now = DateTime.now().subtract(const Duration(minutes: 30));
    return appointments.where((booking) => booking.startTime.isAfter(now)).toList();
  }

  @override
  void onClose() {
    specialtySearchController.dispose();
    doctorSearchController.dispose();
    super.onClose();
  }

  static DateTime combineDateAndSlot(DateTime date, String slot) {
    final parts = slot.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }
}

extension on DateTime {
  DateTime _copyWithTime(int hour, int minute) {
    return DateTime(year, month, day, hour, minute);
  }
}
