import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/config/di/di.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/core/theme/theme_ext.dart';
import 'package:edu_verse/core/utils/date_formatter.dart';
import 'package:edu_verse/core/widgets/app_avatar.dart';
import 'package:edu_verse/core/widgets/app_badge.dart';
import 'package:edu_verse/core/widgets/empty_state.dart';
import 'package:edu_verse/core/widgets/shimmer_loading.dart';
import 'package:edu_verse/features/instructor/data/models/attendance_record.dart';
import 'package:edu_verse/features/instructor/data/models/session_model.dart';
import 'package:edu_verse/features/instructor/ui/cubit/session_detail_cubit.dart';
import 'package:edu_verse/features/instructor/ui/cubit/session_detail_state.dart';

class InstructorSessionDetailScreen extends StatelessWidget {
  const InstructorSessionDetailScreen({super.key, required this.session});

  final SessionModel session;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<InstructorSessionDetailCubit>()..loadAttendance(session.id),
      child: _SessionDetailView(session: session),
    );
  }
}

class _SessionDetailView extends StatelessWidget {
  const _SessionDetailView({required this.session});

  final SessionModel session;

  static BadgeType _badgeType(SessionStatus s) => switch (s) {
        SessionStatus.ongoing => BadgeType.ongoing,
        SessionStatus.upcoming => BadgeType.upcoming,
        SessionStatus.completed => BadgeType.completed,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: BlocBuilder<InstructorSessionDetailCubit, InstructorSessionDetailState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              // ── AppBar ─────────────────────────────────────
              SliverAppBar(
                pinned: true,
                backgroundColor: context.bg,
                elevation: 0,
                scrolledUnderElevation: 0,
                title: Text(session.displayTitle,
                    style: AppTextTheme.screenTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),

              switch (state) {
                InstructorSessionDetailLoading() ||
                InstructorSessionDetailInitial() =>
                  _buildSkeleton(),
                InstructorSessionDetailLoaded(
                  :final attendance,
                  :final qrCode,
                  :final isGeneratingQr,
                  :final isMarking,
                  :final qrError,
                ) =>
                  _buildContent(
                    context,
                    attendance: attendance,
                    qrCode: qrCode,
                    isGeneratingQr: isGeneratingQr,
                    isMarking: isMarking,
                    qrError: qrError,
                  ),
                InstructorSessionDetailError(:final message) =>
                  SliverFillRemaining(
                    child: Center(
                      child: Text(message,
                          style: AppTextTheme.bodyMedium
                              .colored(context.textSecondary)),
                    ),
                  ),
                _ => const SliverToBoxAdapter(child: SizedBox()),
              },
            ],
          );
        },
      ),
    );
  }

  SliverToBoxAdapter _buildSkeleton() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ShimmerCard(height: 120),
            const SizedBox(height: 12),
            ShimmerCard(height: 160),
            const SizedBox(height: 12),
            ShimmerList(itemCount: 4, itemHeight: 68),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required List<AttendanceRecord> attendance,
    required String? qrCode,
    required bool isGeneratingQr,
    required bool isMarking,
    required String? qrError,
  }) {
    final presentCount = attendance.where((r) => r.isPresent).length;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // ── Session info card ────────────────────────────
          _InfoCard(session: session, badgeType: _badgeType(session.status)),

          const SizedBox(height: 20),

          // ── QR Code section ──────────────────────────────
          _QrSection(
            sessionId: session.id,
            qrCode: qrCode,
            isGeneratingQr: isGeneratingQr,
            qrError: qrError,
          ),

          const SizedBox(height: 20),

          // ── Attendance section ───────────────────────────
          _AttendanceSection(
            sessionId: session.id,
            records: attendance,
            presentCount: presentCount,
            isMarking: isMarking,
          ),
        ]),
      ),
    );
  }
}

// ─── Info card ───────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.session, required this.badgeType});

  final SessionModel session;
  final BadgeType badgeType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(session.displayTitle,
                    style: AppTextTheme.displaySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              AppBadge(label: session.statusLabel, type: badgeType),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.access_time_rounded,
            label: DateFormatter.formatTimeRange(
                session.startTime, session.endTime),
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: session.isOnline
                ? Icons.videocam_rounded
                : Icons.location_on_rounded,
            label: session.location,
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.people_outline_rounded,
            label: '${session.studentsEnrolled} students enrolled',
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: DateFormatter.formatDayMonth(session.startTime),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: context.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: context.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: AppTextTheme.bodyMedium),
        ),
      ],
    );
  }
}

// ─── QR section ─────────────────────────────────────────────

class _QrSection extends StatelessWidget {
  const _QrSection({
    required this.sessionId,
    required this.qrCode,
    required this.isGeneratingQr,
    required this.qrError,
  });

  final String sessionId;
  final String? qrCode;
  final bool isGeneratingQr;
  final String? qrError;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.qr_code_rounded,
                    size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Text('Attendance QR Code', style: AppTextTheme.displaySmall),
            ],
          ),

          const SizedBox(height: 16),

          if (isGeneratingQr)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2.5,
                ),
              ),
            )
          else if (qrCode != null && qrCode!.isNotEmpty)
            _QrDisplay(code: qrCode!, sessionId: sessionId)
          else ...[
            Text(
              'Generate a QR code so students can mark their attendance.',
              style: AppTextTheme.bodySmall.colored(context.textSecondary),
            ),
            if (qrError != null) ...[
              const SizedBox(height: 8),
              Text(
                qrError!,
                style: AppTextTheme.bodySmall.colored(AppColors.error),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context
                    .read<InstructorSessionDetailCubit>()
                    .generateQr(sessionId),
                icon: const Icon(Icons.qr_code_rounded, size: 18),
                label: Text('Generate QR Code',
                    style: AppTextTheme.buttonMedium),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QrDisplay extends StatelessWidget {
  const _QrDisplay({required this.code, required this.sessionId});

  final String code;
  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
          decoration: BoxDecoration(
            color: context.isDark
                ? Colors.white.withValues(alpha: 0.06)
                : AppColors.primary.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.20),
            ),
          ),
          child: Column(
            children: [
              const Icon(Icons.qr_code_2_rounded,
                  size: 64, color: AppColors.primary),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: context.bg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: context.border),
                ),
                child: SelectableText(
                  code,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Students can scan the QR icon or enter this code\nto mark their attendance.',
                style: AppTextTheme.bodySmall.colored(context.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () => context
              .read<InstructorSessionDetailCubit>()
              .generateQr(sessionId),
          icon: const Icon(Icons.refresh_rounded, size: 16),
          label: Text('Refresh QR',
              style: AppTextTheme.labelMedium.colored(AppColors.primary)),
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
        ),
      ],
    );
  }
}

// ─── Attendance section ──────────────────────────────────────

class _AttendanceSection extends StatelessWidget {
  const _AttendanceSection({
    required this.sessionId,
    required this.records,
    required this.presentCount,
    required this.isMarking,
  });

  final String sessionId;
  final List<AttendanceRecord> records;
  final int presentCount;
  final bool isMarking;

  @override
  Widget build(BuildContext context) {
    final absentCount = records.length - presentCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Text('Attendance', style: AppTextTheme.displaySmall),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$presentCount present',
                style: AppTextTheme.labelSmall
                    .colored(AppColors.success)
                    .copyWith(fontSize: 11),
              ),
            ),
            if (absentCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$absentCount absent',
                  style: AppTextTheme.labelSmall
                      .colored(AppColors.error)
                      .copyWith(fontSize: 11),
                ),
              ),
            ],
          ],
        ),

        if (isMarking) ...[
          const SizedBox(height: 8),
          LinearProgressIndicator(
            backgroundColor: context.borderLight,
            color: AppColors.primary,
            minHeight: 2,
            borderRadius: BorderRadius.circular(2),
          ),
        ],

        const SizedBox(height: 12),

        if (records.isEmpty)
          EmptyState(
            icon: Icons.people_outline_rounded,
            title: 'No attendance records yet',
            subtitle: 'Records will appear once students mark attendance.',
          )
        else
          Container(
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.borderLight),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (int i = 0; i < records.length; i++) ...[
                  _AttendanceRow(
                    record: records[i],
                    onMarkPresent: records[i].isPresent
                        ? null
                        : () => context
                            .read<InstructorSessionDetailCubit>()
                            .markStudentAttendance(
                              sessionId,
                              records[i].studentId,
                            ),
                  ),
                  if (i < records.length - 1)
                    const Divider(height: 1, indent: 68),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({required this.record, this.onMarkPresent});

  final AttendanceRecord record;
  final VoidCallback? onMarkPresent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          AppAvatar(name: record.studentName, radius: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.studentName, style: AppTextTheme.cardTitle),
                Text(
                  record.studentEmail,
                  style: AppTextTheme.bodySmall.colored(context.textTertiary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (record.isPresent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Present',
                style: AppTextTheme.labelSmall
                    .colored(AppColors.success)
                    .copyWith(fontSize: 11),
              ),
            )
          else
            GestureDetector(
              onTap: onMarkPresent,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.30),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_rounded,
                        size: 12, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Mark Present',
                      style: AppTextTheme.labelSmall
                          .colored(AppColors.primary)
                          .copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
