import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/app_state.dart';
import '../../shared/models/order.dart';
import '../../shared/widgets/bazz_logo.dart';
import '../../theme/colors.dart';

// ── Data model ────────────────────────────────────────────────────────────────
class _OrderData {
  String name = '';
  String phone = '';
  String email = '';
  String governorate = '';
  String area = '';
  String streetDetails = '';
  String notes = '';
  String whatSending = '';
}

// ── Jordan governorates ───────────────────────────────────────────────────────
const _govsEn = [
  'Amman', 'Irbid', 'Zarqa', 'Balqa', 'Mafraq',
  'Jerash', 'Ajloun', 'Karak', 'Tafilah', "Ma'an", 'Aqaba', 'Madaba',
];
const _govsAr = [
  'عمان', 'إربد', 'الزرقاء', 'البلقاء', 'المفرق',
  'جرش', 'عجلون', 'الكرك', 'الطفيلة', 'معان', 'العقبة', 'مادبا',
];

// Keyed by English name for both languages
const _govHintsEn = {
  'Amman':   'e.g. Khalda, Dabouq, Sweifieh, Abdoun',
  'Irbid':   'e.g. Aydoun, Ramtha, Kufr Soum',
  'Zarqa':   'e.g. Rusaifa, Hashimiyya, Zarqa City',
  'Balqa':   'e.g. Salt, Fuheis, Mahis',
  'Mafraq':  'e.g. Rhab, Safawi, North Badia',
  'Jerash':  'e.g. Jerash City, Sakib',
  'Ajloun':  'e.g. Anjara, Orjan, Ajloun City',
  'Karak':   "e.g. Karak City, Mu'ta, Mazar",
  'Tafilah': 'e.g. Tafilah City, Busayra',
  "Ma'an":   "e.g. Ma'an City, Wadi Musa (Petra)",
  'Aqaba':   'e.g. Aqaba City, Tala Bay',
  'Madaba':  'e.g. Madaba City, Libb, Dhiban',
};
const _govHintsAr = {
  'Amman':   'مثال: خلدا، دابوق، الصويفية، عبدون',
  'Irbid':   'مثال: عيدون، الرمثا، كفر سوم',
  'Zarqa':   'مثال: الرصيفة، الهاشمية، مدينة الزرقاء',
  'Balqa':   'مثال: السلط، فحيص، ماحص',
  'Mafraq':  'مثال: رحاب، الصفاوي، البادية الشمالية',
  'Jerash':  'مثال: مدينة جرش، ساكب',
  'Ajloun':  'مثال: عنجرة، عرجان، مدينة عجلون',
  'Karak':   'مثال: مدينة الكرك، مؤتة، مزار',
  'Tafilah': 'مثال: مدينة الطفيلة، بصيرة',
  "Ma'an":   'مثال: مدينة معان، وادي موسى (البتراء)',
  'Aqaba':   'مثال: مدينة العقبة، تالا باي',
  'Madaba':  'مثال: مدينة مادبا، لبب، ذيبان',
};

// ── Main screen ───────────────────────────────────────────────────────────────
class AddOrderScreen extends StatefulWidget {
  const AddOrderScreen({super.key});

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  int _step = 0; // 0=quantity, 1=order forms, 2=review, 3=all-set
  final _pageCtrl = PageController();

  // Step 1
  int _count = 1;
  int? _selectedPreset;
  static const _presets = [1, 2, 3, 5, 10, 15, 20];

  // Step 2
  List<_OrderData> _orders = [_OrderData()];
  int _currentOrder = 0;

  // Step 3 -> Step 4
  Map<String, int> _govPins = {};

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageCtrl.animateToPage(page, duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
  }

  void _goToStep(int step) {
    setState(() => _step = step);
    _goToPage(step);
  }

  void _startForms() {
    setState(() {
      _orders = List.generate(_count, (_) => _OrderData());
      _currentOrder = 0;
      _step = 1;
    });
    _goToPage(1);
  }

  void _nextOrder() {
    if (_currentOrder < _count - 1) {
      setState(() => _currentOrder++);
    } else {
      _goToStep(2);
    }
  }

  void _confirm() {
    final rng = math.Random();
    final pins = <String, int>{};
    for (final order in _orders) {
      if (order.governorate.isNotEmpty && !pins.containsKey(order.governorate)) {
        pins[order.governorate] = 1000 + rng.nextInt(9000);
      }
    }
    setState(() => _govPins = pins);

    final now = DateTime.now();
    final dateStr = '${now.day} ${_monthName(now.month)}, ${now.hour}:${now.minute.toString().padLeft(2, '0')} ${now.hour < 12 ? 'AM' : 'PM'}';
    final createdAt = '${_monthName(now.month)} ${now.day}, ${now.year} · ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final orderModels = _orders.asMap().entries.map((e) {
      final i = e.key;
      final o = e.value;
      final govIdx = _govsEn.indexOf(o.governorate);
      final govAr = govIdx >= 0 ? _govsAr[govIdx] : o.governorate;
      return OrderModel(
        id: '#BZ-NEW-${now.millisecondsSinceEpoch}-$i',
        status: OrderStatus.pending,
        items: 1,
        recipientName: o.name,
        recipientPhone: o.phone,
        address: '${o.area}, ${o.governorate} — ${o.streetDetails}',
        customerName: o.name,
        customerNameAr: o.name,
        phone: o.phone,
        area: o.area,
        areaAr: o.area,
        governorate: o.governorate,
        governorateAr: govAr,
        date: dateStr,
        dateAr: dateStr,
        createdAt: createdAt,
        notes: o.notes.isEmpty ? null : o.notes,
      );
    }).toList();

    context.read<AppState>().addOrders(orderModels);
    _goToStep(3);
  }

  String _monthName(int month) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[month - 1];
  }

  void _back() {
    if (_step == 0) {
      context.canPop() ? context.pop() : context.go('/home');
    } else if (_step == 1) {
      if (_currentOrder > 0) {
        setState(() => _currentOrder--);
      } else {
        _goToStep(0);
      }
    } else if (_step == 2) {
      setState(() {
        _step = 1;
        _currentOrder = _count - 1;
      });
      _goToPage(1);
    }
    // step 3: no back (hide leading)
  }

  void _addMoreOrders() {
    if (_orders.length >= 50) return;
    setState(() {
      _orders.add(_OrderData());
      _count = _orders.length;
      _currentOrder = _orders.length - 1;
      _step = 1;
    });
    _goToPage(1);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isAr = appState.isArabic;
    final font = isAr ? GoogleFonts.cairo : GoogleFonts.inter;

    final bool inFormStep = _step == 1;
    final bool inAllSet = _step == 3;

    String title;
    String subtitle;
    if (inFormStep) {
      title = isAr ? 'الطلب ${_currentOrder + 1} من $_count' : 'Order ${_currentOrder + 1} of $_count';
      subtitle = '';
    } else if (_step == 2) {
      title = isAr ? 'مراجعة طلباتك' : 'Review Your Orders';
      subtitle = isAr ? 'الخطوة 3 من 3' : 'Step 3 of 3';
    } else if (inAllSet) {
      title = '';
      subtitle = '';
    } else {
      title = isAr ? 'طلب جديد' : 'New Order';
      subtitle = isAr ? 'الخطوة 1 من 3' : 'Step 1 of 3';
    }

    final int remaining = _count - _currentOrder - 1;

    if (inAllSet) {
      return _Step4(
        orders: _orders,
        govPins: _govPins,
        isAr: isAr,
        font: font,
        onTrackOrders: () => context.go('/orders/current'),
      );
    }

    return Scaffold(
      backgroundColor: BazzColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _step == 3
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: BazzColors.textPrimary),
                onPressed: _back,
              ),
        title: title.isNotEmpty
            ? Column(
                children: [
                  Text(title, style: font(fontSize: 17.0, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
                  if (subtitle.isNotEmpty)
                    Text(subtitle, style: font(fontSize: 12.0, color: BazzColors.textSecondary)),
                ],
              )
            : null,
        centerTitle: true,
        actions: inFormStep
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$remaining ${isAr ? 'متبقية' : 'remaining'}',
                        style: font(fontSize: 12.0, fontWeight: FontWeight.w600, color: BazzColors.textSecondary),
                      ),
                    ),
                  ),
                ),
              ]
            : null,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(inFormStep ? 30.0 : 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: Row(
                  children: List.generate(
                    3,
                    (i) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: i < 2 ? 4 : 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 4,
                          decoration: BoxDecoration(
                            color: i <= _step ? BazzColors.accent : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (inFormStep) ...[
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: const BoxDecoration(color: BazzColors.success, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Text('Auto-saved', style: font(fontSize: 11.0, color: BazzColors.success)),
                  ],
                ),
                const SizedBox(height: 5),
              ] else
                const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: PageView(
        controller: _pageCtrl,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _Step1(
            count: _count,
            selectedPreset: _selectedPreset,
            presets: _presets,
            isAr: isAr,
            font: font,
            onIncrement: () {
              if (_count < 50) setState(() { _count++; _selectedPreset = null; });
            },
            onDecrement: () {
              if (_count > 1) setState(() { _count--; _selectedPreset = null; });
            },
            onSelectPreset: (p) => setState(() { _count = p; _selectedPreset = p; }),
            onNext: _startForms,
          ),
          _Step2(
            key: ValueKey('order_$_currentOrder'),
            orderData: _orders[_currentOrder],
            orderIndex: _currentOrder,
            totalOrders: _count,
            isAr: isAr,
            font: font,
            onNext: _nextOrder,
          ),
          _Step3(
            orders: _orders,
            isAr: isAr,
            font: font,
            onConfirm: _confirm,
            onAddMore: _addMoreOrders,
          ),
          // Step 4 placeholder in PageView (actual step 4 is rendered above via early return)
          const SizedBox.shrink(),
        ],
      ),
    );
  }
}

// ── Step 1: Quantity ──────────────────────────────────────────────────────────
class _Step1 extends StatefulWidget {
  final int count;
  final int? selectedPreset;
  final List<int> presets;
  final bool isAr;
  final dynamic font;
  final VoidCallback onIncrement, onDecrement, onNext;
  final void Function(int) onSelectPreset;

  const _Step1({
    required this.count,
    required this.selectedPreset,
    required this.presets,
    required this.isAr,
    required this.font,
    required this.onIncrement,
    required this.onDecrement,
    required this.onSelectPreset,
    required this.onNext,
  });

  @override
  State<_Step1> createState() => _Step1State();
}

class _Step1State extends State<_Step1> {
  bool _showCustomInput = false;
  final _customCtrl = TextEditingController();

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  void _applyCustom(String v) {
    final n = int.tryParse(v);
    if (n != null && n >= 1 && n <= 50) widget.onSelectPreset(n);
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isAr;
    final font = widget.font;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: BazzColors.primary, borderRadius: BorderRadius.circular(16)),
            child: Stack(children: [
              const Center(child: Icon(Icons.inventory_2_rounded, color: Colors.white, size: 42)),
              Positioned(
                top: 6, right: 6,
                child: Container(
                  width: 14, height: 14,
                  decoration: const BoxDecoration(color: BazzColors.accent, shape: BoxShape.circle),
                ),
              ),
            ]),
          )
            .animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.85, 0.85))
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(begin: 0, end: -10, duration: 900.ms, curve: Curves.easeInOut),

          const SizedBox(height: 28),
          Text(
            isAr ? 'كم طلباً اليوم؟' : 'How many orders today?',
            style: font(fontSize: 22.0, fontWeight: FontWeight.w800, color: BazzColors.textPrimary),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 300.ms, delay: 80.ms),
          const SizedBox(height: 8),
          Text(
            isAr ? 'اختر عدد الطلبات التي تريد إضافتها' : 'Select the number of orders you want to add',
            style: font(fontSize: 14.0, color: BazzColors.textSecondary),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 300.ms, delay: 120.ms),
          const SizedBox(height: 40),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: widget.onDecrement,
                style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                child: Text('−', style: font(fontSize: 32.0, fontWeight: FontWeight.w300,
                    color: widget.count > 1 ? BazzColors.textPrimary : BazzColors.textHint)),
              ),
              const SizedBox(width: 24),
              Text('${widget.count}', style: font(fontSize: 56.0, fontWeight: FontWeight.w800, color: BazzColors.primary)),
              const SizedBox(width: 24),
              GestureDetector(
                onTap: widget.onIncrement,
                child: Container(
                  width: 48, height: 48,
                  decoration: const BoxDecoration(color: BazzColors.accent, shape: BoxShape.circle),
                  child: const Icon(Icons.add_rounded, color: BazzColors.primary, size: 28),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 300.ms, delay: 160.ms),

          const SizedBox(height: 4),
          Text(isAr ? 'طلبات' : 'orders', style: font(fontSize: 14.0, color: BazzColors.textSecondary)),
          const SizedBox(height: 28),

          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: widget.presets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final p = widget.presets[i];
                final sel = widget.selectedPreset == p;
                return GestureDetector(
                  onTap: () {
                    widget.onSelectPreset(p);
                    if (_showCustomInput) setState(() => _showCustomInput = false);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? BazzColors.accent : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sel ? BazzColors.accent : BazzColors.divider),
                      boxShadow: sel
                          ? [BoxShadow(color: BazzColors.accent.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))]
                          : [],
                    ),
                    child: Text('$p', style: font(fontSize: 13.0, fontWeight: FontWeight.w700,
                        color: sel ? BazzColors.primary : BazzColors.textSecondary)),
                  ),
                );
              },
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 200.ms),

          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => setState(() => _showCustomInput = !_showCustomInput),
            child: Text(
              isAr ? 'أو اكتب عدداً' : 'Or type a number',
              style: font(fontSize: 13.0, fontWeight: FontWeight.w600, color: BazzColors.primary)
                  .copyWith(decoration: TextDecoration.underline, decorationColor: BazzColors.primary),
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 220.ms),

          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _showCustomInput
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: SizedBox(
                      width: 160,
                      child: TextField(
                        controller: _customCtrl,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        textAlign: TextAlign.center,
                        style: font(fontSize: 18.0, fontWeight: FontWeight.w700, color: BazzColors.primary),
                        decoration: InputDecoration(
                          hintText: '1 – 50',
                          hintStyle: font(fontSize: 14.0, color: BazzColors.textHint),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: BazzColors.primary, width: 1.5)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: BazzColors.primary.withOpacity(0.3))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: BazzColors.primary, width: 1.8)),
                        ),
                        onChanged: _applyCustom,
                        onSubmitted: (v) {
                          _applyCustom(v);
                          setState(() => _showCustomInput = false);
                        },
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline_rounded, size: 14, color: BazzColors.textHint),
              const SizedBox(width: 6),
              Text(
                isAr ? 'الحد الأقصى 50 طلباً في الدفعة' : 'Maximum 50 orders per batch',
                style: font(fontSize: 12.0, color: BazzColors.textSecondary),
              ),
            ],
          ).animate().fadeIn(duration: 300.ms, delay: 240.ms),

          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity, height: 54,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: BazzColors.accent,
                foregroundColor: BazzColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: widget.onNext,
              child: Text(isAr ? 'التالي ›' : 'Next ›',
                  style: font(fontSize: 16.0, fontWeight: FontWeight.w800)),
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 280.ms),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Step 2: Order details form (one order at a time) ──────────────────────────
class _Step2 extends StatefulWidget {
  final _OrderData orderData;
  final int orderIndex;
  final int totalOrders;
  final bool isAr;
  final dynamic font;
  final VoidCallback onNext;

  const _Step2({
    super.key,
    required this.orderData,
    required this.orderIndex,
    required this.totalOrders,
    required this.isAr,
    required this.font,
    required this.onNext,
  });

  @override
  State<_Step2> createState() => _Step2State();
}

class _Step2State extends State<_Step2> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _areaCtrl;
  late final TextEditingController _streetCtrl;
  late final TextEditingController _notesCtrl;
  String? _selectedGov;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    final d = widget.orderData;
    _nameCtrl = TextEditingController(text: d.name);
    _phoneCtrl = TextEditingController(
      text: d.phone.startsWith('+962') ? d.phone.substring(4) : d.phone,
    );
    _emailCtrl = TextEditingController(text: d.email);
    _areaCtrl = TextEditingController(text: d.area);
    _streetCtrl = TextEditingController(text: d.streetDetails);
    _notesCtrl = TextEditingController(text: d.notes);
    _selectedGov = d.governorate.isEmpty ? null : d.governorate;
    _selectedCategory = d.whatSending.isEmpty ? null : d.whatSending;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _areaCtrl.dispose();
    _streetCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final d = widget.orderData;
    d.name = _nameCtrl.text.trim();
    final raw = _phoneCtrl.text.trim();
    final stripped = raw.startsWith('0') ? raw.substring(1) : raw;
    d.phone = stripped.isEmpty ? '' : '+962$stripped';
    d.email = _emailCtrl.text.trim();
    d.governorate = _selectedGov ?? '';
    d.area = _areaCtrl.text.trim();
    d.streetDetails = _streetCtrl.text.trim();
    d.notes = _notesCtrl.text.trim();
    d.whatSending = _selectedCategory ?? '';
  }

  void _handlePhoneChange(String v) {
    if (v.startsWith('0')) {
      final trimmed = v.substring(1);
      _phoneCtrl.value = TextEditingValue(
        text: trimmed,
        selection: TextSelection.collapsed(offset: trimmed.length),
      );
    }
    _save();
  }

  void _pickGov() {
    final isAr = widget.isAr;
    final font = widget.font;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        expand: false,
        builder: (_, sc) => Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                isAr ? 'اختر المحافظة' : 'Select Governorate',
                style: font(fontSize: 17.0, fontWeight: FontWeight.w800, color: BazzColors.textPrimary),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: sc,
                itemCount: _govsEn.length,
                itemBuilder: (_, i) {
                  final govEn = _govsEn[i];
                  final govAr = _govsAr[i];
                  final sel = _selectedGov == govEn;
                  return Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        title: Text(
                          isAr ? govAr : govEn,
                          style: font(fontSize: 15.0, fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                              color: sel ? BazzColors.primary : BazzColors.textPrimary),
                        ),
                        trailing: sel
                            ? const Icon(Icons.check_circle_rounded, color: BazzColors.primary)
                            : null,
                        onTap: () {
                          setState(() => _selectedGov = govEn);
                          _save();
                          Navigator.pop(ctx);
                        },
                      ),
                      const Divider(height: 1, indent: 20),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _deco({required String hint, required IconData icon}) => InputDecoration(
    hintText: hint,
    hintStyle: widget.font(fontSize: 13.0, color: BazzColors.textHint),
    prefixIcon: Icon(icon, color: BazzColors.primary, size: 20),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: BazzColors.primary.withOpacity(0.15))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: BazzColors.primary.withOpacity(0.15))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: BazzColors.primary, width: 1.8)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: BazzColors.error)),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: BazzColors.error, width: 1.8)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isAr;
    final font = widget.font;
    final govIdx = _selectedGov != null ? _govsEn.indexOf(_selectedGov!) : -1;
    final govDisplay = govIdx >= 0 ? (isAr ? _govsAr[govIdx] : _selectedGov!) : null;
    final areaHint = _selectedGov != null
        ? (isAr ? _govHintsAr[_selectedGov!] : _govHintsEn[_selectedGov!])
        : null;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Order number badge
              Center(
                child: Container(
                  width: 52, height: 52,
                  decoration: const BoxDecoration(color: BazzColors.accent, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text('${widget.orderIndex + 1}',
                      style: font(fontSize: 24.0, fontWeight: FontWeight.w800, color: BazzColors.primary)),
                ),
              ),
              const SizedBox(height: 24),

              // ── Customer Details ──────────────────────────────────────────
              _SecHeader(icon: Icons.person_outline_rounded, label: isAr ? 'بيانات العميل' : 'Customer Details', font: font),
              const SizedBox(height: 14),

              Text(isAr ? 'الاسم الكامل *' : 'Full Name *', style: font(fontSize: 13.0, fontWeight: FontWeight.w600, color: BazzColors.textPrimary)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameCtrl,
                onChanged: (_) => _save(),
                decoration: _deco(hint: isAr ? 'مثال: أحمد محمد' : 'e.g. Ahmad Mohammad', icon: Icons.person_outline_rounded),
                validator: (v) => (v == null || v.trim().isEmpty) ? (isAr ? 'الاسم مطلوب' : 'Name is required') : null,
              ),
              const SizedBox(height: 14),

              Text(isAr ? 'رقم الهاتف *' : 'Phone Number *', style: font(fontSize: 13.0, fontWeight: FontWeight.w600, color: BazzColors.textPrimary)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)],
                onChanged: _handlePhoneChange,
                decoration: InputDecoration(
                  hintText: '7XXXXXXXX',
                  hintStyle: font(fontSize: 13.0, color: BazzColors.textHint),
                  prefixIcon: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🇯🇴', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 6),
                        Text('+962', style: font(fontSize: 14.0, fontWeight: FontWeight.w600, color: BazzColors.textPrimary)),
                        const SizedBox(width: 8),
                        Container(width: 1, height: 22, color: const Color(0xFFE0E0E0)),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: BazzColors.primary.withOpacity(0.15))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: BazzColors.primary.withOpacity(0.15))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: BazzColors.primary, width: 1.8)),
                  errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: BazzColors.error)),
                  focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: BazzColors.error, width: 1.8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                validator: (v) {
                  final s = (v ?? '').startsWith('0') ? v!.substring(1) : (v ?? '');
                  return s.length != 9 ? (isAr ? 'رقم الهاتف يجب أن يكون 9 أرقام' : 'Phone must be 9 digits') : null;
                },
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Text(isAr ? 'البريد الإلكتروني' : 'Email', style: font(fontSize: 13.0, fontWeight: FontWeight.w600, color: BazzColors.textPrimary)),
                  const SizedBox(width: 8),
                  _OptionalChip(font: font, isAr: isAr),
                ],
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => _save(),
                decoration: _deco(hint: 'example@email.com', icon: Icons.email_outlined),
              ),
              const SizedBox(height: 28),

              // ── Delivery Location ─────────────────────────────────────────
              _SecHeader(icon: Icons.location_on_rounded, label: isAr ? 'موقع التوصيل' : 'Delivery Location', font: font, iconColor: BazzColors.error),
              const SizedBox(height: 14),

              Text(isAr ? 'المحافظة *' : 'Governorate *', style: font(fontSize: 13.0, fontWeight: FontWeight.w600, color: BazzColors.textPrimary)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _pickGov,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: govDisplay != null ? BazzColors.accent.withOpacity(0.07) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: govDisplay != null ? BazzColors.accent : BazzColors.primary.withOpacity(0.15),
                      width: govDisplay != null ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text('🏙️', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          govDisplay ?? (isAr ? 'اختر المحافظة' : 'Select Governorate'),
                          style: font(fontSize: 14.0,
                              fontWeight: govDisplay != null ? FontWeight.w600 : FontWeight.w400,
                              color: govDisplay != null ? BazzColors.primary : BazzColors.textHint),
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down_rounded,
                          color: govDisplay != null ? BazzColors.primary : BazzColors.textHint),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Text(isAr ? 'المنطقة / الحي *' : 'Area / District *',
                  style: font(fontSize: 13.0, fontWeight: FontWeight.w600, color: BazzColors.textPrimary)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _areaCtrl,
                onChanged: (_) => _save(),
                decoration: InputDecoration(
                  hintText: areaHint ?? (isAr ? 'اكتب اسم المنطقة أو الحي' : 'Type your area or district'),
                  hintStyle: font(fontSize: 13.0, color: BazzColors.textHint),
                  prefixIcon: Icon(Icons.map_outlined, color: BazzColors.primary, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: BazzColors.primary.withOpacity(0.15))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: BazzColors.primary.withOpacity(0.15))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: BazzColors.primary, width: 1.8)),
                  errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: BazzColors.error)),
                  focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: BazzColors.error, width: 1.8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? (isAr ? 'المنطقة مطلوبة' : 'Area is required') : null,
              ),
              const SizedBox(height: 14),

              Text(isAr ? 'تفاصيل الموقع *' : 'More Location Details *',
                  style: font(fontSize: 13.0, fontWeight: FontWeight.w600, color: BazzColors.textPrimary)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _streetCtrl,
                maxLines: 3,
                maxLength: 200,
                onChanged: (_) => _save(),
                decoration: InputDecoration(
                  hintText: isAr
                      ? 'اسم الشارع، رقم المبنى، الطابق، الشقة، معلم مميز...'
                      : 'Street name, building number, floor, apartment, landmark...',
                  hintStyle: font(fontSize: 13.0, color: BazzColors.textHint),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8, top: 14),
                    child: Icon(Icons.description_outlined, color: BazzColors.primary, size: 20),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: BazzColors.primary.withOpacity(0.15))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: BazzColors.primary.withOpacity(0.15))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: BazzColors.primary, width: 1.8)),
                  errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: BazzColors.error)),
                  focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: BazzColors.error, width: 1.8)),
                  contentPadding: const EdgeInsets.all(14),
                  alignLabelWithHint: true,
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? (isAr ? 'تفاصيل العنوان مطلوبة' : 'Address details required') : null,
              ),
              const SizedBox(height: 20),

              // ── Order Notes ───────────────────────────────────────────────
              Row(
                children: [
                  Text(isAr ? 'ملاحظات الطلب' : 'Order Notes',
                      style: font(fontSize: 13.0, fontWeight: FontWeight.w600, color: BazzColors.textPrimary)),
                  const SizedBox(width: 8),
                  _OptionalChip(font: font, isAr: isAr),
                ],
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 2,
                onChanged: (_) => _save(),
                decoration: InputDecoration(
                  hintText: isAr ? 'هش؟ اتصل قبل التسليم؟ تعامل بحذر؟' : 'Fragile? Call before delivery? Handle with care?',
                  hintStyle: font(fontSize: 13.0, color: BazzColors.textHint),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: BazzColors.primary.withOpacity(0.15))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: BazzColors.primary.withOpacity(0.15))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: BazzColors.primary, width: 1.8)),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 14),

              // ── What are you sending? ─────────────────────────────────────
              Row(
                children: [
                  const Text('📦', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(isAr ? 'ماذا ترسل؟' : 'What are you sending?',
                      style: font(fontSize: 13.0, fontWeight: FontWeight.w600, color: BazzColors.textPrimary)),
                  const SizedBox(width: 8),
                  _OptionalChip(font: font, isAr: isAr),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories(isAr).map((cat) {
                  final sel = _selectedCategory == cat.key;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedCategory = sel ? null : cat.key;
                      _save();
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: sel ? BazzColors.accent : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: sel ? BazzColors.accent : BazzColors.divider,
                          width: sel ? 1.5 : 1.0,
                        ),
                        boxShadow: sel
                            ? [BoxShadow(color: BazzColors.accent.withOpacity(0.35), blurRadius: 6, offset: const Offset(0, 2))]
                            : [],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(cat.emoji, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(cat.label,
                              style: font(fontSize: 13.0, fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                                  color: sel ? BazzColors.primary : BazzColors.textSecondary)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 36),

              SizedBox(
                height: 54,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: BazzColors.accent,
                    foregroundColor: BazzColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    if (_selectedGov == null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(isAr ? 'الرجاء اختيار المحافظة' : 'Please select a governorate'),
                        backgroundColor: BazzColors.error,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ));
                      return;
                    }
                    if (_formKey.currentState!.validate()) {
                      _save();
                      widget.onNext();
                    }
                  },
                  child: Text(
                    widget.orderIndex < widget.totalOrders - 1
                        ? (isAr ? 'حفظ ومتابعة ›' : 'Save & Continue ›')
                        : (isAr ? 'مراجعة الطلبات ›' : 'Review Orders ›'),
                    style: font(fontSize: 16.0, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

// ── Step 3: Review all orders (grouped by governorate) ────────────────────────
class _Step3 extends StatefulWidget {
  final List<_OrderData> orders;
  final bool isAr;
  final dynamic font;
  final VoidCallback onConfirm;
  final VoidCallback onAddMore;

  const _Step3({
    required this.orders,
    required this.isAr,
    required this.font,
    required this.onConfirm,
    required this.onAddMore,
  });

  @override
  State<_Step3> createState() => _Step3State();
}

class _Step3State extends State<_Step3> {
  late Set<String> _expandedGovs;

  @override
  void initState() {
    super.initState();
    // All expanded by default
    _expandedGovs = widget.orders.map((o) => o.governorate).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final orders = widget.orders;
    final isAr = widget.isAr;
    final font = widget.font;

    // Build grouped map: gov -> list of (globalIndex, order)
    final Map<String, List<(int, _OrderData)>> grouped = {};
    for (var i = 0; i < orders.length; i++) {
      final gov = orders[i].governorate.isEmpty ? (isAr ? 'غير محدد' : 'Unknown') : orders[i].governorate;
      grouped.putIfAbsent(gov, () => []).add((i, orders[i]));
    }

    final govCount = grouped.keys.length;
    const goldenColor = Color(0xFFFFD600);
    const navyColor = BazzColors.primary;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Summary card ──────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: navyColor,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('${orders.length}',
                            style: font(fontSize: 36.0, fontWeight: FontWeight.w800, color: goldenColor)),
                        Text(isAr ? 'طلبات' : 'Orders',
                            style: font(fontSize: 13.0, color: Colors.white70)),
                      ],
                    ),
                  ),
                  const Text('🚚', style: TextStyle(fontSize: 28)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('$govCount',
                            style: font(fontSize: 36.0, fontWeight: FontWeight.w800, color: goldenColor)),
                        Text(isAr ? 'محافظات' : 'Governorates',
                            style: font(fontSize: 13.0, color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Section header ────────────────────────────────────────────
            Row(
              children: [
                const Text('📍', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  isAr ? 'الطلبات مجمّعة حسب المنطقة' : 'Orders grouped by area',
                  style: font(fontSize: 15.0, fontWeight: FontWeight.w700, color: BazzColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Grouped collapsible cards ─────────────────────────────────
            ...grouped.entries.map((entry) {
              final govEn = entry.key;
              final govOrders = entry.value;
              final govIdx = _govsEn.indexOf(govEn);
              final govDisplay = isAr && govIdx >= 0 ? _govsAr[govIdx] : govEn;
              final isExpanded = _expandedGovs.contains(govEn);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Column(
                    children: [
                      // Header row
                      InkWell(
                        onTap: () => setState(() {
                          if (isExpanded) {
                            _expandedGovs.remove(govEn);
                          } else {
                            _expandedGovs.add(govEn);
                          }
                        }),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              const Text('📍', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(govDisplay,
                                    style: font(fontSize: 14.0, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: goldenColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${govOrders.length} ${isAr ? 'طلبات' : 'orders'}',
                                  style: font(fontSize: 11.0, fontWeight: FontWeight.w700, color: navyColor),
                                ),
                              ),
                              const SizedBox(width: 8),
                              AnimatedRotation(
                                turns: isExpanded ? 0.5 : 0.0,
                                duration: const Duration(milliseconds: 200),
                                child: const Icon(Icons.keyboard_arrow_down_rounded,
                                    color: BazzColors.textSecondary, size: 22),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Expanded orders list
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: isExpanded
                            ? Column(
                                children: [
                                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                                  ...govOrders.map((tuple) {
                                    final globalIndex = tuple.$1;
                                    final o = tuple.$2;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 32, height: 32,
                                            decoration: const BoxDecoration(color: goldenColor, shape: BoxShape.circle),
                                            alignment: Alignment.center,
                                            child: Text('${globalIndex + 1}',
                                                style: font(fontSize: 13.0, fontWeight: FontWeight.w800, color: navyColor)),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(o.name.isEmpty ? '-' : o.name,
                                                    style: font(fontSize: 13.0, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${o.area.isEmpty ? '-' : o.area} • ${o.phone.isEmpty ? '-' : o.phone}',
                                                  style: font(fontSize: 12.0, color: BazzColors.textSecondary),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(Icons.edit_outlined, color: BazzColors.primary, size: 18),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 8),

            // ── Add More Orders button ────────────────────────────────────
            if (orders.length < 50)
              GestureDetector(
                onTap: widget.onAddMore,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: goldenColor,
                      width: 1.5,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    color: goldenColor.withOpacity(0.04),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    isAr ? '+ إضافة المزيد من الطلبات' : '+ Add More Orders',
                    style: font(fontSize: 14.0, fontWeight: FontWeight.w700, color: BazzColors.primary),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // ── Stats row ─────────────────────────────────────────────────
            Row(
              children: [
                Expanded(child: _StatBox(label: isAr ? 'الطلبات' : 'Total Orders', value: '${orders.length}', font: font)),
                const SizedBox(width: 8),
                Expanded(child: _StatBox(label: isAr ? 'المناطق' : 'Areas', value: '$govCount', font: font)),
                const SizedBox(width: 8),
                Expanded(child: _StatBox(label: isAr ? 'سائقون مطلوبون' : 'Drivers Needed', value: '$govCount', font: font)),
              ],
            ),

            const SizedBox(height: 20),

            // ── Info box ──────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE8F8EF),
                borderRadius: BorderRadius.circular(12),
                border: const Border(left: BorderSide(color: BazzColors.success, width: 3)),
              ),
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, color: BazzColors.success, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isAr
                          ? 'بعد التأكيد، ستحصل كل مجموعة سائق على رمز PIN فريد. شارك الرمز فقط مع سائقك!'
                          : 'After confirmation, each driver group will receive a unique PIN. Share the PIN only with your driver!',
                      style: font(fontSize: 12.0, color: const Color(0xFF1B5E20)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Center(
              child: Text(
                isAr ? 'يمكنك تعديل أي طلب أعلاه' : 'You can still edit any order above',
                style: font(fontSize: 12.0, color: BazzColors.textSecondary)
                    .copyWith(fontStyle: FontStyle.italic),
              ),
            ),

            const SizedBox(height: 20),

            // ── Confirm button ────────────────────────────────────────────
            SizedBox(
              height: 54,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: widget.onConfirm,
                child: Text(
                  isAr
                      ? 'تأكيد ${orders.length} ${orders.length == 1 ? 'طلب' : 'طلبات'}'
                      : 'Confirm ${orders.length} Order${orders.length > 1 ? 's' : ''}',
                  style: font(fontSize: 16.0, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label, value;
  final dynamic font;
  const _StatBox({required this.label, required this.value, required this.font});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Text(value, style: font(fontSize: 22.0, fontWeight: FontWeight.w800, color: BazzColors.primary)),
          const SizedBox(height: 4),
          Text(label, style: font(fontSize: 10.0, color: BazzColors.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── Step 4: All Set screen ────────────────────────────────────────────────────
class _Step4 extends StatelessWidget {
  final List<_OrderData> orders;
  final Map<String, int> govPins;
  final bool isAr;
  final dynamic font;
  final VoidCallback onTrackOrders;

  const _Step4({
    required this.orders,
    required this.govPins,
    required this.isAr,
    required this.font,
    required this.onTrackOrders,
  });

  @override
  Widget build(BuildContext context) {
    // Count orders per gov
    final Map<String, int> govOrderCount = {};
    for (final o in orders) {
      final g = o.governorate.isEmpty ? 'Unknown' : o.governorate;
      govOrderCount[g] = (govOrderCount[g] ?? 0) + 1;
    }

    return Scaffold(
      backgroundColor: BazzColors.primary,
      body: Stack(
        children: [
          const _ConfettiWidget(),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Navy header ─────────────────────────────────────────
                Container(
                  color: BazzColors.primary,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 32,
                    left: 32,
                    right: 32,
                    bottom: 40,
                  ),
                  child: Column(
                    children: [
                      const BazzLogoWhite(fontSize: 24),
                      const SizedBox(height: 16),
                      Container(
                        width: 72, height: 72,
                        decoration: const BoxDecoration(color: BazzColors.accent, shape: BoxShape.circle),
                        child: const Icon(Icons.check_rounded, color: BazzColors.primary, size: 40),
                      )
                          .animate()
                          .scale(
                            begin: const Offset(0.5, 0.5),
                            end: const Offset(1.0, 1.0),
                            duration: 600.ms,
                            curve: Curves.elasticOut,
                          ),
                      const SizedBox(height: 16),
                      Text(
                        'All Set! 🎉',
                        style: font(fontSize: 28.0, fontWeight: FontWeight.w800, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isAr
                            ? '${orders.length} طلباتك تم تأكيدها'
                            : '${orders.length} Your orders are confirmed',
                        style: font(fontSize: 15.0, color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // ── White card body ─────────────────────────────────────
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Driver PINs header
                      Row(
                        children: [
                          const Text('🔐', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Text(
                            isAr ? 'أرقام PIN للسائقين' : 'Driver PINs',
                            style: font(fontSize: 16.0, fontWeight: FontWeight.w800, color: BazzColors.textPrimary),
                          ),
                          const Spacer(),
                          Flexible(
                            child: Text(
                              isAr ? 'شارك كل PIN مع السائق الصحيح فقط' : 'Share each PIN with the correct driver only',
                              style: font(fontSize: 11.0, color: BazzColors.textSecondary),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Per-governorate PIN cards
                      ...govPins.entries.map((entry) {
                        final govEn = entry.key;
                        final pin = entry.value;
                        final pinStr = pin.toString().padLeft(4, '0');
                        final govIdx = _govsEn.indexOf(govEn);
                        final govDisplay = isAr && govIdx >= 0 ? _govsAr[govIdx] : govEn;
                        final orderCount = govOrderCount[govEn] ?? 0;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFFFD600), width: 1.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    const Text('📍', style: TextStyle(fontSize: 16)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(govDisplay,
                                          style: font(fontSize: 14.0, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFD600),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '$orderCount ${isAr ? 'طلبات' : 'Orders'}',
                                        style: font(fontSize: 11.0, fontWeight: FontWeight.w700, color: BazzColors.primary),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  isAr ? 'رمز PIN للسائق' : 'Driver PIN',
                                  style: font(fontSize: 12.0, color: BazzColors.textSecondary),
                                ),
                                const SizedBox(height: 8),
                                // 4 digit boxes
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(4, (i) {
                                    return Container(
                                      width: 56, height: 64,
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      decoration: BoxDecoration(
                                        color: BazzColors.accent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        pinStr[i],
                                        style: font(fontSize: 28.0, fontWeight: FontWeight.w800, color: BazzColors.primary),
                                      ),
                                    );
                                  }),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 8, height: 8,
                                      decoration: const BoxDecoration(color: BazzColors.success, shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isAr ? 'صالح لمدة 24 ساعة' : 'Valid for 24 hours',
                                      style: font(fontSize: 12.0, color: BazzColors.success),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => Clipboard.setData(ClipboardData(text: pinStr)),
                                        icon: const Icon(Icons.copy_rounded, size: 16),
                                        label: Text(isAr ? 'نسخ PIN' : 'Copy PIN',
                                            style: font(fontSize: 13.0, fontWeight: FontWeight.w600)),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: BazzColors.primary,
                                          side: const BorderSide(color: BazzColors.primary),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: FilledButton.icon(
                                        onPressed: () {
                                          // Share PIN
                                          Clipboard.setData(ClipboardData(text: pinStr));
                                        },
                                        icon: const Icon(Icons.share_rounded, size: 16),
                                        label: Text(isAr ? 'مشاركة' : 'Share PIN',
                                            style: font(fontSize: 13.0, fontWeight: FontWeight.w600)),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: BazzColors.accent,
                                          foregroundColor: BazzColors.primary,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity, height: 48,
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      final msg = Uri.encodeComponent('Driver PIN: $pinStr — Valid 24h');
                                      final url = Uri.parse('https://wa.me/?text=$msg');
                                      await launchUrl(url, mode: LaunchMode.externalApplication);
                                    },
                                    icon: const FaIcon(FontAwesomeIcons.whatsapp, size: 18),
                                    label: Text(
                                      isAr ? 'إرسال عبر واتساب' : 'Send via WhatsApp',
                                      style: font(fontSize: 13.0, fontWeight: FontWeight.w700),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF25D366),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Center(
                                  child: TextButton(
                                    onPressed: () {
                                      // Regenerate PIN (noop for now)
                                    },
                                    child: Text(
                                      '🔄 ${isAr ? 'إعادة توليد PIN' : 'Regenerate PIN'}',
                                      style: font(fontSize: 12.0, color: BazzColors.textSecondary),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                      // Tip
                      Text(
                        isAr
                            ? '💡 نصيحة: التقط صورة أو شارك الرموز فوراً مع سائقيك'
                            : '💡 Tip: Screenshot or share PINs immediately with your drivers',
                        style: font(fontSize: 12.0, color: BazzColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Track Orders button
                      SizedBox(
                        width: double.infinity, height: 54,
                        child: FilledButton.icon(
                          onPressed: onTrackOrders,
                          icon: const Icon(Icons.local_shipping_rounded, size: 20),
                          label: Text(
                            isAr ? 'تتبع طلباتي' : 'Track My Orders',
                            style: font(fontSize: 16.0, fontWeight: FontWeight.w800),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: BazzColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Confetti Widget ───────────────────────────────────────────────────────────
class _Dot {
  final double x;
  final double startY;
  final double speed;
  final double size;
  final Color color;

  _Dot({required math.Random rng})
      : x = rng.nextDouble(),
        startY = -rng.nextDouble() * 0.3,
        speed = 0.4 + rng.nextDouble() * 0.6,
        size = 4.0 + rng.nextDouble() * 8.0,
        color = [
          Colors.red,
          const Color(0xFF2ECC71),
          const Color(0xFFFFD600),
          Colors.blue,
          Colors.orange,
          Colors.purple,
        ][rng.nextInt(6)];
}

class _ConfettiPainter extends CustomPainter {
  final List<_Dot> dots;
  final double t;

  const _ConfettiPainter(this.dots, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final dot in dots) {
      final y = (dot.startY + t * dot.speed) * size.height;
      final opacity = t > 0.7 ? (1.0 - (t - 0.7) / 0.3).clamp(0.0, 1.0) : 1.0;
      final paint = Paint()..color = dot.color.withOpacity(opacity);
      canvas.drawCircle(Offset(dot.x * size.width, y), dot.size / 2, paint);
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}

class _ConfettiWidget extends StatefulWidget {
  const _ConfettiWidget();

  @override
  State<_ConfettiWidget> createState() => _ConfettiState();
}

class _ConfettiState extends State<_ConfettiWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final _rng = math.Random();
  late List<_Dot> _dots;

  @override
  void initState() {
    super.initState();
    _dots = List.generate(50, (_) => _Dot(rng: _rng));
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        size: Size.infinite,
        painter: _ConfettiPainter(_dots, _ctrl.value),
      ),
    );
  }
}

// ── Category data ─────────────────────────────────────────────────────────────
class _Category {
  final String key, emoji, label;
  const _Category(this.key, this.emoji, this.label);
}

List<_Category> _categories(bool isAr) => [
  _Category('clothes',     '👕', isAr ? 'ملابس'        : 'Clothes'),
  _Category('electronics', '📱', isAr ? 'إلكترونيات'   : 'Electronics'),
  _Category('gifts',       '🎁', isAr ? 'هدايا'         : 'Gifts'),
  _Category('food',        '🍱', isAr ? 'طعام'          : 'Food'),
  _Category('medicine',    '💊', isAr ? 'أدوية'         : 'Medicine'),
  _Category('furniture',   '🛋️', isAr ? 'أثاث'          : 'Furniture'),
  _Category('books',       '📚', isAr ? 'كتب وقرطاسية' : 'Books'),
  _Category('cosmetics',   '💄', isAr ? 'مستحضرات'     : 'Cosmetics'),
  _Category('sports',      '⚽', isAr ? 'رياضة'         : 'Sports'),
  _Category('others',      '📦', isAr ? 'أخرى'          : 'Others'),
];

// ── Shared sub-widgets ────────────────────────────────────────────────────────
class _SecHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final dynamic font;
  final Color iconColor;

  const _SecHeader({required this.icon, required this.label, required this.font, this.iconColor = BazzColors.primary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 8),
        Text(label, style: font(fontSize: 15.0, fontWeight: FontWeight.w800, color: BazzColors.textPrimary)),
      ],
    );
  }
}

class _OptionalChip extends StatelessWidget {
  final dynamic font;
  final bool isAr;
  const _OptionalChip({required this.font, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: BazzColors.accent.withOpacity(0.25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(isAr ? 'اختياري' : 'Optional',
          style: font(fontSize: 11.0, fontWeight: FontWeight.w600, color: BazzColors.primary)),
  );
  }
}
