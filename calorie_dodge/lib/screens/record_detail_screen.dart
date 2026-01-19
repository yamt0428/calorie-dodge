import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/record.dart';
import '../providers/record_provider.dart';
import '../theme/app_theme.dart';

class RecordDetailScreen extends StatefulWidget {
  final CalorieRecord record;

  const RecordDetailScreen({super.key, required this.record});

  @override
  State<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends State<RecordDetailScreen> {
  late TextEditingController _caloriesController;
  late TextEditingController _memoController;
  late DateTime _selectedDateTime;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _caloriesController = TextEditingController(
      text: widget.record.calories.toString(),
    );
    _memoController = TextEditingController(text: widget.record.memo ?? '');
    _selectedDateTime = widget.record.timestamp;
  }

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

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final calories = int.parse(_caloriesController.text);
      final memo = _memoController.text.isNotEmpty ? _memoController.text : null;

      final updatedRecord = widget.record.copyWith(
        calories: calories,
        memo: memo,
        timestamp: _selectedDateTime,
      );

      await context.read<RecordProvider>().updateRecord(updatedRecord);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('更新しました'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _deleteRecord() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('記録を削除'),
        content: const Text('この記録を削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<RecordProvider>().deleteRecord(widget.record.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('削除しました')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '記録を編集' : '記録の詳細'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteRecord,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // カロリー
              const Text(
                'カロリー',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _caloriesController,
                enabled: _isEditing,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
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
              const SizedBox(height: 24),

              // メモ
              const Text(
                '商品名/メモ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _memoController,
                enabled: _isEditing,
                decoration: const InputDecoration(
                  hintText: 'メモなし',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // 日時
              const Text(
                '日時',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _isEditing ? _selectDateTime : null,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.borderColor),
                    borderRadius: BorderRadius.circular(8),
                    color: _isEditing ? null : Colors.grey[50],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: AppTheme.textSecondary),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('yyyy年M月d日 HH:mm').format(_selectedDateTime),
                        style: const TextStyle(fontSize: 16),
                      ),
                      if (_isEditing) ...[
                        const Spacer(),
                        const Icon(Icons.edit, color: AppTheme.textSecondary, size: 20),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 作成日時・更新日時
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            '作成日時: ',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                          Text(
                            DateFormat('yyyy/M/d HH:mm').format(widget.record.createdAt),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text(
                            '更新日時: ',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                          Text(
                            DateFormat('yyyy/M/d HH:mm').format(widget.record.updatedAt),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              if (_isEditing) ...[
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _isEditing = false),
                        child: const Text('キャンセル'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveChanges,
                        child: const Text('保存'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
