import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/record_provider.dart';
import '../services/analytics_service.dart';
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

  // 入力モード: 0 = 直接入力, 1 = 計算入力
  int _inputMode = 0;

  // 計算入力用のコントローラー
  final _baseGramController = TextEditingController(text: '100');
  final _baseCaloriesController = TextEditingController();
  final _actualGramController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');

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

  // 計算入力用のプリセット（100gあたりのカロリー）
  final _calcPresets = [
    {'name': 'ご飯', 'baseGram': 100, 'baseCal': 168},
    {'name': '食パン', 'baseGram': 100, 'baseCal': 260},
    {'name': 'チョコレート', 'baseGram': 100, 'baseCal': 558},
    {'name': 'ポテトチップス', 'baseGram': 100, 'baseCal': 554},
    {'name': 'アイスクリーム', 'baseGram': 100, 'baseCal': 180},
    {'name': 'クッキー', 'baseGram': 100, 'baseCal': 480},
    {'name': 'ドーナツ', 'baseGram': 100, 'baseCal': 375},
    {'name': 'ケーキ', 'baseGram': 100, 'baseCal': 350},
  ];

  @override
  void initState() {
    super.initState();
    // 計算入力の値が変更されたらカロリーを再計算
    _baseGramController.addListener(_calculateCalories);
    _baseCaloriesController.addListener(_calculateCalories);
    _actualGramController.addListener(_calculateCalories);
    _quantityController.addListener(_calculateCalories);
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _memoController.dispose();
    _baseGramController.dispose();
    _baseCaloriesController.dispose();
    _actualGramController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _calculateCalories() {
    if (_inputMode != 1) return;

    final baseGram = double.tryParse(_baseGramController.text) ?? 0;
    final baseCal = double.tryParse(_baseCaloriesController.text) ?? 0;
    final actualGram = double.tryParse(_actualGramController.text) ?? 0;
    final quantity = double.tryParse(_quantityController.text) ?? 1;

    if (baseGram > 0 && baseCal > 0 && actualGram > 0) {
      // カロリー計算: (実際のグラム数 / 基準グラム数) × 基準カロリー × 個数
      final totalCalories = (actualGram / baseGram) * baseCal * quantity;
      _caloriesController.text = totalCalories.round().toString();
    }
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

  void _selectCalcPreset(Map<String, dynamic> preset) {
    setState(() {
      _baseGramController.text = preset['baseGram'].toString();
      _baseCaloriesController.text = preset['baseCal'].toString();
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

      // アナリティクスにログ
      if (Platform.isAndroid || Platform.isIOS) {
        AnalyticsService().logCalorieRecord(
          calories: calories,
          memo: memo,
        );
      }

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
              // 入力モード切替
              const Text(
                '入力方法',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(
                    value: 0,
                    label: Text('直接入力'),
                    icon: Icon(Icons.edit),
                  ),
                  ButtonSegment(
                    value: 1,
                    label: Text('計算して入力'),
                    icon: Icon(Icons.calculate),
                  ),
                ],
                selected: {_inputMode},
                onSelectionChanged: (value) {
                  setState(() {
                    _inputMode = value.first;
                    // モード切替時にカロリーをクリア
                    _caloriesController.clear();
                  });
                },
              ),
              const SizedBox(height: 24),

              // 直接入力モード
              if (_inputMode == 0) ...[
                _buildDirectInputSection(),
              ],

              // 計算入力モード
              if (_inputMode == 1) ...[
                _buildCalculatorSection(),
              ],

              const SizedBox(height: 24),

              // 計算結果のカロリー表示（計算モードの場合）
              if (_inputMode == 1) ...[
                const Text(
                  '計算結果',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGreen1.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryGreen),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_fire_department, color: AppTheme.primaryGreen),
                      const SizedBox(width: 8),
                      Text(
                        _caloriesController.text.isNotEmpty
                            ? '${NumberFormat('#,###').format(int.tryParse(_caloriesController.text) ?? 0)} kcal'
                            : '-- kcal',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // カロリー入力フィールド（直接入力モードの場合のみバリデーション用に必要）
              if (_inputMode == 0) ...[
                // 直接入力モードでは上で表示済み
              ] else ...[
                // 計算モードでは非表示だがバリデーション用に保持
                Visibility(
                  visible: false,
                  maintainState: true,
                  child: TextFormField(
                    controller: _caloriesController,
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
                ),
              ],

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

  Widget _buildDirectInputSection() {
    return Column(
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
      ],
    );
  }

  Widget _buildCalculatorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 説明
        Card(
          color: Colors.blue[50],
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '栄養成分表示を見ながら計算できます',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 食品プリセット
        const Text(
          '食品を選択（100gあたりのカロリー）',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _calcPresets.map((preset) {
            return ActionChip(
              label: Text('${preset['name']} (${preset['baseCal']}kcal)'),
              onPressed: () => _selectCalcPreset(preset),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // 基準値入力
        const Text(
          '栄養成分表示の基準値',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _baseGramController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                decoration: const InputDecoration(
                  labelText: '基準量',
                  suffixText: 'g',
                  hintText: '100',
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'あたり',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            Expanded(
              child: TextFormField(
                controller: _baseCaloriesController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'カロリー',
                  suffixText: 'kcal',
                  hintText: '350',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 実際の摂取量入力
        const Text(
          '回避した量',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _actualGramController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                decoration: const InputDecoration(
                  labelText: '1個あたりの量',
                  suffixText: 'g',
                  hintText: '50',
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '×',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: TextFormField(
                controller: _quantityController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                decoration: const InputDecoration(
                  labelText: '個数',
                  suffixText: '個',
                  hintText: '1',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 計算式の表示
        if (_baseGramController.text.isNotEmpty &&
            _baseCaloriesController.text.isNotEmpty &&
            _actualGramController.text.isNotEmpty) ...[
          Card(
            color: Colors.grey[100],
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '計算式:',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '(${_actualGramController.text}g ÷ ${_baseGramController.text}g) × ${_baseCaloriesController.text}kcal × ${_quantityController.text}個',
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
