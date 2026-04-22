import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_galvanometer_gallery/common/photo_bottom_sheet.dart';
import 'package:the_galvanometer_gallery/enum/my_enums.dart';
import 'package:the_galvanometer_gallery/providers/image_provider.dart';
import 'package:the_galvanometer_gallery/providers/input_provider.dart';
import 'package:the_galvanometer_gallery/providers/project_provider.dart';
import 'package:the_galvanometer_gallery/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class AddScreen extends ConsumerStatefulWidget {
  final bool isEdit;
  final int currentIndex;
  const AddScreen({super.key, this.isEdit = false, this.currentIndex = 0});

  @override
  ConsumerState<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends ConsumerState<AddScreen> {
  late PageController _pageCtrl;
  int _currentPage = 0;

  // Controllers
  late TextEditingController _idCtrl;
  late TextEditingController _manCtrl;
  late TextEditingController _countryCtrl;
  late TextEditingController _eraCtrl;
  late TextEditingController _resistanceCtrl;
  late TextEditingController _sensitivityCtrl;
  late TextEditingController _dimCtrl;
  late TextEditingController _accessoriesCtrl;
  late TextEditingController _markingsCtrl;
  late TextEditingController _provCtrl;
  late TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    final p = ref.read(inputProvider);
    _idCtrl = TextEditingController(text: p.laboratoryIdentifier);
    _manCtrl = TextEditingController(text: p.manufacturer);
    _countryCtrl = TextEditingController(text: p.countryOfOrigin);
    _eraCtrl = TextEditingController(text: p.eraOfProduction);
    _resistanceCtrl = TextEditingController(text: p.internalResistance);
    _sensitivityCtrl = TextEditingController(text: p.sensitivityAndScale);
    _dimCtrl = TextEditingController(text: p.dimensionsAndWeight);
    _accessoriesCtrl = TextEditingController(text: p.includedAccessories);
    _markingsCtrl = TextEditingController(text: p.markingsAndEngravings);
    _provCtrl = TextEditingController(text: p.provenance);
    _notesCtrl = TextEditingController(text: p.notes);

    // Listen to ID changes to enable/disable button
    _idCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    for (final c in [
      _idCtrl,
      _manCtrl,
      _countryCtrl,
      _eraCtrl,
      _resistanceCtrl,
      _sensitivityCtrl,
      _dimCtrl,
      _accessoriesCtrl,
      _markingsCtrl,
      _provCtrl,
      _notesCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _goToPage(int page) {
    _pageCtrl.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.jetBrainsMono(
            color: Colors.white,
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: kError,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(20.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadiusStandard),
        ),
      ),
    );
  }

  void _save() async {
    final p = ref.read(inputProvider);

    // Deep sync from controllers
    p.laboratoryIdentifier = _idCtrl.text.trim();
    p.manufacturer = _manCtrl.text;
    p.countryOfOrigin = _countryCtrl.text;
    p.eraOfProduction = _eraCtrl.text;
    p.internalResistance = _resistanceCtrl.text;
    p.sensitivityAndScale = _sensitivityCtrl.text;
    p.dimensionsAndWeight = _dimCtrl.text;
    p.includedAccessories = _accessoriesCtrl.text;
    p.markingsAndEngravings = _markingsCtrl.text;
    p.provenance = _provCtrl.text;
    p.notes = _notesCtrl.text;

    if (_idCtrl.text.trim().isEmpty) {
      _showError('LABORATORY IDENTIFIER REQUIRED');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _SavingDialog(),
    );

    await Future.delayed(const Duration(milliseconds: 1200));

    if (widget.isEdit) {
      ref.read(projectProvider).editEntry(ref, widget.currentIndex);
    } else {
      ref.read(projectProvider).addEntry(ref);
    }

    if (mounted) {
      Navigator.pop(context);
      Navigator.pop(context);
      ref.read(inputProvider).clearAll();
      ref.read(imageProvider).clearImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: kPrimaryText, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEdit ? 'EDIT SPECIMEN' : 'REGISTER SPECIMEN',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: kAccent,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(20.h),
          child: _buildStepIndicator(),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 2.h),
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: [_buildPage1(), _buildPage2(), _buildPage3()],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
      child: Row(
        children: List.generate(3, (i) {
          final isActive = i <= _currentPage;
          final isCurrent = i == _currentPage;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < 2 ? 6.w : 0),
              height: 3.h,
              decoration: BoxDecoration(
                color: isActive ? kAccent : kOutline,
                borderRadius: BorderRadius.circular(kRadiusPill),
                boxShadow:
                    isCurrent
                        ? const [
                          BoxShadow(
                            offset: Offset(0, 8),
                            blurRadius: 24,
                            spreadRadius: -4,
                            color: Color(0x282B5EA7),
                          ),
                        ]
                        : null,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPage1() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader('01', 'Identification'),
          SizedBox(height: 24.h),
          _buildPhotoSection(),
          SizedBox(height: 32.h),
          _monoField(
            label: 'LABORATORY IDENTIFIER',
            ctrl: _idCtrl,
            hint: 'e.g. TGG-SIEMENS-1888-BERLIN-102',
            onChanged: (v) => ref.read(inputProvider).laboratoryIdentifier = v,
          ),
          _buildEnumGroup<InstrumentType>(
            label: 'INSTRUMENT TYPE',
            values: InstrumentType.values,
            current: ref.watch(inputProvider).instrumentType,
            onSelected: (t) => ref.read(inputProvider).instrumentType = t,
            labelBuilder: (t) => t.label,
          ),
          _monoField(
            label: 'MANUFACTURER / MAKER',
            ctrl: _manCtrl,
            hint: 'e.g. Siemens & Halske',
            onChanged: (v) => ref.read(inputProvider).manufacturer = v,
          ),
          _monoField(
            label: 'COUNTRY OF ORIGIN',
            ctrl: _countryCtrl,
            hint: 'e.g. Germany, England, USA',
            onChanged: (v) => ref.read(inputProvider).countryOfOrigin = v,
          ),
          _monoField(
            label: 'ERA OF PRODUCTION',
            ctrl: _eraCtrl,
            hint: 'e.g. 1880s',
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9s]')),
              _EraInputFormatter(),
            ],
            onChanged: (v) => ref.read(inputProvider).eraOfProduction = v,
          ),
        ],
      ),
    );
  }

  Widget _buildPage2() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader('02', 'Technical Specs'),
          SizedBox(height: 24.h),
          _buildEnumGroup<OperatingPrinciple>(
            label: 'OPERATING PRINCIPLE',
            values: OperatingPrinciple.values,
            current: ref.watch(inputProvider).operatingPrinciple,
            onSelected: (t) => ref.read(inputProvider).operatingPrinciple = t,
            labelBuilder: (t) => t.label.split(' (')[0],
          ),
          _buildEnumGroup<SensitivityClass>(
            label: 'SENSITIVITY CLASS',
            values: SensitivityClass.values,
            current: ref.watch(inputProvider).sensitivityClass,
            onSelected: (t) => ref.read(inputProvider).sensitivityClass = t,
            labelBuilder: (t) => t.label,
          ),
          _monoField(
            label: 'INTERNAL RESISTANCE (Ω)',
            ctrl: _resistanceCtrl,
            hint: 'e.g. 4200',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (v) => ref.read(inputProvider).internalResistance = v,
          ),
          _monoField(
            label: 'SENSITIVITY & SCALE',
            ctrl: _sensitivityCtrl,
            hint: 'e.g. 10⁻⁹ A/mm or 120 scale divisions',
            onChanged: (v) => ref.read(inputProvider).sensitivityAndScale = v,
          ),
          _buildEnumGroup<PrimaryMaterial>(
            label: 'PRIMARY MATERIAL & HOUSING',
            values: PrimaryMaterial.values,
            current: ref.watch(inputProvider).primaryMaterial,
            onSelected: (t) => ref.read(inputProvider).primaryMaterial = t,
            labelBuilder: (t) => t.label,
          ),
          _monoField(
            label: 'DIMENSIONS & WEIGHT',
            ctrl: _dimCtrl,
            hint: 'e.g. 320 × 180 × 240 mm, 4.2 kg',
            onChanged: (v) => ref.read(inputProvider).dimensionsAndWeight = v,
          ),
        ],
      ),
    );
  }

  Widget _buildPage3() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader('03', 'Archival Record'),
          SizedBox(height: 24.h),
          _buildEnumGroup<ConditionState>(
            label: 'CONDITION STATE',
            values: ConditionState.values,
            current: ref.watch(inputProvider).conditionState,
            onSelected: (t) => ref.read(inputProvider).conditionState = t,
            labelBuilder: (t) => t.label.split(' — ')[0],
          ),
          _monoField(
            label: 'INCLUDED ACCESSORIES',
            ctrl: _accessoriesCtrl,
            hint: 'Travel case, shunt resistors, mirrors...',
            maxLines: 2,
            onChanged: (v) => ref.read(inputProvider).includedAccessories = v,
          ),
          _monoField(
            label: 'MARKINGS & ENGRAVINGS',
            ctrl: _markingsCtrl,
            hint: 'Serial no., university stamps, patent dates...',
            maxLines: 2,
            onChanged: (v) => ref.read(inputProvider).markingsAndEngravings = v,
          ),
          _monoField(
            label: 'PROVENANCE',
            ctrl: _provCtrl,
            hint: 'e.g. Cambridge Cavendish, Berlin PTR',
            onChanged: (v) => ref.read(inputProvider).provenance = v,
          ),
          _monoField(
            label: 'ARCHIVAL NOTES',
            ctrl: _notesCtrl,
            hint: 'History, laboratory significance, observations...',
            maxLines: 5,
            onChanged: (v) => ref.read(inputProvider).notes = v,
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader(String num, String title) {
    return Row(
      children: [
        Text(
          num,
          style: GoogleFonts.jetBrainsMono(
            color: kAccent,
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(width: 12.w),
        Container(width: 24.w, height: 1, color: kOutline),
        SizedBox(width: 12.w),
        Text(
          title,
          style: GoogleFonts.cormorant(
            color: kPrimaryText,
            fontSize: 28.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSection() {
    final imgPath = ref
        .watch(imageProvider)
        .getImagePath(ref.watch(imageProvider).resultImage);
    return GestureDetector(
      onTap: () => photoBottomSheet(context, ref.read(imageProvider), 0, ref),
      child: Container(
        width: double.infinity,
        height: 180.h,
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusStandard),
          border: Border.all(color: kOutline, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child:
            imgPath != null && File(imgPath).existsSync()
                ? Image.file(File(imgPath), fit: BoxFit.cover)
                : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        color: kSecondaryText.withValues(alpha: 0.4),
                        size: 32.sp,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'TAP TO PHOTOGRAPH',
                        style: GoogleFonts.jetBrainsMono(
                          color: kSecondaryText,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _monoField({
    required String label,
    required TextEditingController ctrl,
    required Function(String) onChanged,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              color: kSecondaryText,
              fontSize: 9.sp,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: ctrl,
            onChanged: onChanged,
            maxLines: maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: GoogleFonts.inter(
              color: kPrimaryText,
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                color: kSecondaryText.withValues(alpha: 0.35),
                fontSize: 14.sp,
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: kOutline, width: 1.0),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: kAccent, width: 1.5),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 10.h),
              filled: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnumGroup<T>({
    required String label,
    required List<T> values,
    required T current,
    required Function(T) onSelected,
    required String Function(T) labelBuilder,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 28.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              color: kSecondaryText,
              fontSize: 9.sp,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children:
                values.map((val) {
                  final isSel = val == current;
                  return GestureDetector(
                    onTap: () => onSelected(val),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSel ? kAccent : kPanelBg,
                        borderRadius: BorderRadius.circular(kRadiusSubtle),
                        border: Border.all(
                          color: isSel ? kAccent : kOutline,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        labelBuilder(val),
                        style: GoogleFonts.inter(
                          color: isSel ? Colors.white : kPrimaryText,
                          fontSize: 12.sp,
                          fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20.w,
        12.h,
        20.w,
        MediaQuery.of(context).padding.bottom + 12.h,
      ),
      decoration: BoxDecoration(
        color: kBackground,
        border: const Border(top: BorderSide(color: kOutline, width: 1)),
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: GestureDetector(
                onTap: () => _goToPage(_currentPage - 1),
                child: Container(
                  height: 52.h,
                  decoration: BoxDecoration(
                    color: kPanelBg,
                    borderRadius: BorderRadius.circular(kRadiusStandard),
                    border: Border.all(color: kOutline, width: 1),
                  ),
                  child: Center(
                    child: Text(
                      '← BACK',
                      style: GoogleFonts.jetBrainsMono(
                        color: kPrimaryText,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (_currentPage > 0) SizedBox(width: 12.w),
          Expanded(
            flex: 2,
            child: Builder(
              builder: (context) {
                final isIdEmpty = _idCtrl.text.trim().isEmpty;
                final isDisabled = _currentPage == 0 && isIdEmpty;

                return GestureDetector(
                  onTap:
                      isDisabled
                          ? null
                          : () {
                            if (_currentPage < 2) {
                              _goToPage(_currentPage + 1);
                            } else {
                              _save();
                            }
                          },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 52.h,
                    decoration: BoxDecoration(
                      color: isDisabled ? kOutline : kAccent,
                      borderRadius: BorderRadius.circular(kRadiusStandard),
                      boxShadow: isDisabled ? null : const [kShadowBlue],
                    ),
                    child: Center(
                      child: Text(
                        _currentPage < 2
                            ? 'NEXT →'
                            : (widget.isEdit
                                ? 'UPDATE RECORD'
                                : 'REGISTER TO ARCHIVE'),
                        style: GoogleFonts.jetBrainsMono(
                          color: isDisabled ? kSecondaryText : Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SavingDialog extends StatelessWidget {
  const _SavingDialog();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: kPanelBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusMedium),
      ),
      child: Padding(
        padding: EdgeInsets.all(40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 48.w,
              height: 48.w,
              child: const CircularProgressIndicator(
                color: kAccent,
                strokeWidth: 2,
              ),
            ),
            SizedBox(height: 32.h),
            Text(
              'COMMITTING RECORD',
              style: GoogleFonts.jetBrainsMono(
                color: kPrimaryText,
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Please wait while we synchronize the specimen data with the archival vault.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: kSecondaryText,
                fontSize: 13.sp,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EraInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    // Rule: up to 4 digits followed by an optional 's'
    final regExp = RegExp(r'^\d{0,4}s?$');
    if (regExp.hasMatch(text)) {
      return newValue;
    }
    return oldValue;
  }
}
