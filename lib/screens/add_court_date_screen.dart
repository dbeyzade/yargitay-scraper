import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_text_field.dart';
import '../widgets/glassmorphic_container.dart';
import '../widgets/neon_button.dart';

class AddCourtDateScreen extends StatefulWidget {
  const AddCourtDateScreen({super.key});

  @override
  State<AddCourtDateScreen> createState() => _AddCourtDateScreenState();
}

class _AddCourtDateScreenState extends State<AddCourtDateScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _mahkemeController = TextEditingController();
  final _iddaMakamiController = TextEditingController();
  final _tarihController = TextEditingController();
  final _hakimController = TextEditingController();
  final _esasNoController = TextEditingController();
  final _kararNoController = TextEditingController();
  
  // Taraflar listesi - başlangıçta 2 taraf
  List<TextEditingController> _tarafControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  
  String? _selectedFilePath;
  String? _selectedFileName;

  @override
  void dispose() {
    _mahkemeController.dispose();
    _iddaMakamiController.dispose();
    _tarihController.dispose();
    _hakimController.dispose();
    _esasNoController.dispose();
    _kararNoController.dispose();
    for (var controller in _tarafControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addTaraf() {
    setState(() {
      _tarafControllers.add(TextEditingController());
    });
  }

  void _removeTaraf(int index) {
    if (_tarafControllers.length > 1) {
      setState(() {
        _tarafControllers[index].dispose();
        _tarafControllers.removeAt(index);
      });
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() {
          _selectedFilePath = result.files.single.path;
          _selectedFileName = result.files.single.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dosya seçilirken hata oluştu: $e')),
      );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.goldColor,
              onPrimary: Colors.white,
              surface: const Color(0xFF1A1A2E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _tarihController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _saveCourtDate() {
    if (_formKey.currentState!.validate()) {
      // TODO: Veritabanına kaydet
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Duruşma kaydedildi!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Yeni Duruşma Ekle',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0A0E21),
              const Color(0xFF1A237E).withValues(alpha: 0.3),
              const Color(0xFF0A0E21),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTaraflarSection(),
                  const SizedBox(height: 20),
                  _buildCourtInfoSection(),
                  const SizedBox(height: 30),
                  _buildSaveButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaraflarSection() {
    return FadeInUp(
      delay: const Duration(milliseconds: 100),
      child: GlassmorphicContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.people, color: AppTheme.neonPurple, size: 24),
                    const SizedBox(width: 10),
                    const Text(
                      'Taraflar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _addTaraf,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.neonGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.neonGreen, width: 1),
                    ),
                    child: Icon(
                      Icons.add,
                      color: AppTheme.neonGreen,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _tarafControllers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Expanded(
                      child: AnimatedTextField(
                        controller: _tarafControllers[index],
                        label: 'Taraf ${index + 1} - Ad Soyad',
                        icon: Icons.person,
                      ),
                    ),
                    if (_tarafControllers.length > 1) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _removeTaraf(index),
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.red, width: 1),
                          ),
                          child: const Icon(
                            Icons.remove,
                            color: Colors.red,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourtInfoSection() {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: GlassmorphicContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.gavel, color: AppTheme.goldColor, size: 24),
                const SizedBox(width: 10),
                const Text(
                  'Duruşma Bilgileri',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedTextField(
              controller: _mahkemeController,
              label: 'Mahkeme',
              icon: Icons.account_balance,
            ),
            const SizedBox(height: 12),
            AnimatedTextField(
              controller: _iddaMakamiController,
              label: 'İddia Makamı',
              icon: Icons.location_city,
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _selectDate,
              child: AbsorbPointer(
                child: AnimatedTextField(
                  controller: _tarihController,
                  label: 'Tarih',
                  icon: Icons.calendar_today,
                ),
              ),
            ),
            const SizedBox(height: 12),
            AnimatedTextField(
              controller: _hakimController,
              label: 'Hakim',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AnimatedTextField(
                    controller: _esasNoController,
                    label: 'Esas No',
                    icon: Icons.numbers,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AnimatedTextField(
                    controller: _kararNoController,
                    label: 'Karar No',
                    icon: Icons.tag,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFileUploadSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildFileUploadSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.neonBlue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description, color: AppTheme.neonBlue, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Gerekçeli Karar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickFile,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.goldColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.goldColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _selectedFileName != null
                        ? Icons.check_circle
                        : Icons.upload_file,
                    color: _selectedFileName != null
                        ? AppTheme.neonGreen
                        : AppTheme.goldColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedFileName ?? 'Dosya Seç',
                      style: TextStyle(
                        color: _selectedFileName != null
                            ? Colors.white
                            : Colors.white70,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_selectedFileName != null)
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red, size: 18),
                      onPressed: () {
                        setState(() {
                          _selectedFilePath = null;
                          _selectedFileName = null;
                        });
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: Center(
        child: NeonButton(
          label: 'KAYDET',
          onPressed: _saveCourtDate,
          icon: Icons.save,
        ),
      ),
    );
  }
}
