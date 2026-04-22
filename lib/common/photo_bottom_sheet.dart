import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:the_galvanometer_gallery/providers/image_provider.dart';
import 'package:the_galvanometer_gallery/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

void photoBottomSheet(
  BuildContext context,
  ImageNotifier imageProv,
  int index,
  WidgetRef ref,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => Container(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 36.h),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(kRadiusMedium)),
        border: const Border(top: BorderSide(color: kOutline, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: kOutline,
                borderRadius: BorderRadius.circular(kRadiusPill),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Container(width: 3.w, height: 14.h, color: kAccent),
              SizedBox(width: 10.w),
              Text(
                'LOG PHOTOGRAPH',
                style: GoogleFonts.jetBrainsMono(
                  color: kAccent,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildPhotoOption(
            ctx,
            imageProv,
            icon: Icons.camera_alt_outlined,
            label: 'TAKE PHOTOGRAPH',
            sublabel: 'Document the instrument with camera',
            source: ImageSource.camera,
          ),
          SizedBox(height: 10.h),
          _buildPhotoOption(
            ctx,
            imageProv,
            icon: Icons.photo_library_outlined,
            label: 'SELECT FROM LIBRARY',
            sublabel: 'Choose an existing photograph',
            source: ImageSource.gallery,
          ),
        ],
      ),
    ),
  );
}

Widget _buildPhotoOption(
  BuildContext ctx,
  ImageNotifier imageProv, {
  required IconData icon,
  required String label,
  required String sublabel,
  required ImageSource source,
}) {
  return GestureDetector(
    onTap: () async {
      Navigator.pop(ctx);
      await imageProv.pickImage(source: source);
    },
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: kBackground,
        borderRadius: BorderRadius.circular(kRadiusStandard),
        border: Border.all(color: kOutline, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: kAccentSurface,
              borderRadius: BorderRadius.circular(kRadiusStandard),
              border: Border.all(color: kAccent.withValues(alpha: 0.2), width: 1),
            ),
            child: Icon(icon, color: kAccent, size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.jetBrainsMono(
                  color: kPrimaryText,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                sublabel,
                style: GoogleFonts.inter(
                  color: kSecondaryText,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
          const Spacer(),
          Icon(Icons.arrow_forward_ios_rounded,
              color: kSecondaryText, size: 14.sp),
        ],
      ),
    ),
  );
}
