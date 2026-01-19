import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/record_provider.dart';
import '../theme/app_theme.dart';

class RecordInputScreen extends StatefulWidget {
  const RecordInputScreen({super.key});

  @override
  State<RecordInputScreen> createState() => _RecordInputScreenState();
}

class _RecordInputScreenState extends State<RecordInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _caloriesController = TextEditingController();
  final _memoController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();

  // プリセットカロリー
  final _presets = [
    {'name': 'おにぎり', 'calories': 180},
    {'name': 'コンビニスイーツ', 'calories': 300},
    {'name': 'ポテトチップス', 'calories': 350},
    {'name': '菓子パン', 'calories': 400},
    {'name': 'カップラーメン', 'calories': 450},
    {'name': 'ケーキ', 'calories': 500},
    {'name': 'ファストフードセット', 'calories': 800},
  ];

  @override
  void dispose() {
    _caloriesController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null && mounted) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _selectPreset(Map<String, dynamic> preset) {
    setState(() {
      _caloriesController.text = preset['calories'].toString();
      if (_memoController.text.isEmpty) {
        _memoController.text = preset['name'] as String;
      }
    });
  }

  Future<void> _saveRecord() async {
    if (_formKey.currentState!.validate()) {
      final calories = int.parse(_caloriesController.text);
      final memo = _memoController.text.isNotEmpty ? _memoController.text : null;

      await context.read<RecordProvider>().addRecord(
            calories: calories,
            memo: memo,
            timestamp: _selectedDateTime,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('記録しました！'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('カロリーを記録'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // カロリー入力
              const Text(
                'カロリー（必須）',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _caloriesController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  hintText: 'カロリーを入力',
                  suffixText: 'kcal',
                ),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'カロリーを入力してください';
                  }
                  final calories = int.tryParse(value);
                  if (calories == null || calories <= 0) {
                    return '正しいカロリーを入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // プリセット
              const Text(
                'プリセット',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _presets.map((preset) {
                  return ActionChip(
                    label: Text('${preset['name']} (${preset['calories']}kcal)'),
                    onPressed: () => _selectPreset(preset),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // メモ入力
              const Text(
                '商品名/メモ（任意）',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _memoController,
                decoration: const InputDecoration(
                  hintText: '例：コンビニのシュークリーム',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // 日時選択
              const Text(
                '日時',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDateTime,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.borderColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: AppTheme.textSecondary),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('yyyy年M月d日 HH:mm').format(_selectedDateTime),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      const Icon(Icons.edit, color: AppTheme.textSecondary, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 保存ボタン
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveRecord,
                  child: const Text(
                    '記録する',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
