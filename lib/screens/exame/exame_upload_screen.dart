import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/exame.dart';
import '../../services/exame_service.dart';
import '../login/paciente_controller.dart';
import 'exame_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

class ExameUploadScreen extends StatefulWidget {
  const ExameUploadScreen({super.key});

  @override
  State<ExameUploadScreen> createState() => _ExameUploadScreenState();
}

class _ExameUploadScreenState extends State<ExameUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _categoriaController = TextEditingController();
  DateTime? _data = DateTime.now();
  PlatformFile? _selectedFile;
  bool _isSaving = false;

  final ExameService _exameService = Get.put(ExameService());
  final PacienteController _pacienteController = Get.find<PacienteController>();
  final ExameController _exameController = Get.put(ExameController());

  @override
  void dispose() {
    _nomeController.dispose();
    _categoriaController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'heic'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<String> _persistFileLocally(PlatformFile file) async {
    // Salva uma cópia local do arquivo nos documentos do app e retorna o caminho
    final appDir = await getApplicationDocumentsDirectory();
    final examesDir = Directory('${appDir.path}/exames');
    if (!await examesDir.exists()) {
      await examesDir.create(recursive: true);
    }
    final targetPath = '${examesDir.path}/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    final sourcePath = file.path!;
    final savedFile = await File(sourcePath).copy(targetPath);
    return savedFile.path;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _data == null || _selectedFile == null) {
      Get.snackbar('Campos obrigatórios', 'Preencha os campos e selecione um arquivo');
      return;
    }
    try {
      setState(() {
        _isSaving = true;
      });

      final localPath = await _persistFileLocally(_selectedFile!);

      final exame = Exame(
        nome: _nomeController.text.trim(),
        categoria: _categoriaController.text.trim(),
        data: _data!,
        filePath: localPath,
        paciente: _pacienteController.pacienteId.value,
      );

      await _exameController.adicionarExame(exame);
      if (mounted) {
        Get.back(result: true);
        Get.snackbar('Sucesso', 'Exame salvo com sucesso');
      }
    } catch (e) {
      Get.snackbar('Erro', e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlue,
      appBar: AppBar(
        title: const Text('Anexar Exame'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility),
            tooltip: 'Visualizar exames',
            onPressed: () {
              Get.toNamed(Routes.EXAME_LIST);
            },
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome do exame'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categoriaController,
                decoration: const InputDecoration(labelText: 'Categoria'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe a categoria' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(_data == null
                        ? 'Data: não selecionada'
                        : 'Data: ${_data!.toLocal().toString().split(' ').first}'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: now,
                        firstDate: DateTime(now.year - 5),
                        lastDate: DateTime(now.year + 1),
                      );
                      if (picked != null) {
                        setState(() {
                          _data = picked;
                        });
                      }
                    },
                    child: const Text('Selecionar data'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(_selectedFile == null
                        ? 'Nenhum arquivo selecionado'
                        : _selectedFile!.name),
                  ),
                  TextButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Escolher arquivo'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.toNamed(Routes.EXAME_LIST);
                  },
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Visualizar exames'),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_upload),
                  label: Text(_isSaving ? 'Salvando...' : 'Salvar'),
                ),
              )
              ],
            ),
          ),
        ),
      ),
    );
  }
}


