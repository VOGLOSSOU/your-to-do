import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/notification_service.dart';

class NotificationSheet extends StatefulWidget {
  const NotificationSheet({super.key});

  @override
  State<NotificationSheet> createState() => _NotificationSheetState();
}

class _NotificationSheetState extends State<NotificationSheet> {
  bool _enabled = false;
  int _hour = 8;
  int _minute = 0;
  bool _loading = true;
  bool _testing = false;
  bool _hasExactPermission = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await NotificationService.instance.getSettings();
    final exactOk = await NotificationService.instance.hasExactAlarmPermission();
    if (mounted) {
      setState(() {
        _enabled = s.enabled;
        _hour = s.hour;
        _minute = s.minute;
        _hasExactPermission = exactOk;
        _loading = false;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _hour, minute: _minute),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _hour = picked.hour;
      _minute = picked.minute;
    });
    await NotificationService.instance.scheduleDailyReminder(_hour, _minute);
    if (mounted) setState(() => _enabled = true);
  }

  Future<void> _toggle(bool val) async {
    setState(() => _enabled = val);
    if (val) {
      final granted = await NotificationService.instance.requestPermission();
      if (!granted && mounted) {
        setState(() => _enabled = false);
        _showSnack('Permission refusée. Active les notifications dans les paramètres.', Colors.red.shade700);
        return;
      }
      final exactOk = await NotificationService.instance.hasExactAlarmPermission();
      if (!exactOk && mounted) {
        setState(() => _hasExactPermission = false);
      }
      await NotificationService.instance.scheduleDailyReminder(_hour, _minute);
    } else {
      await NotificationService.instance.cancel();
    }
  }

  Future<void> _requestExactPermission() async {
    await NotificationService.instance.requestExactAlarmPermission();
    // Re-check after returning from settings
    final exactOk = await NotificationService.instance.hasExactAlarmPermission();
    if (mounted) {
      setState(() => _hasExactPermission = exactOk);
      if (exactOk && _enabled) {
        await NotificationService.instance.scheduleDailyReminder(_hour, _minute);
        _showSnack('Permission accordée — rappel activé.', Colors.green.shade700);
      }
    }
  }

  Future<void> _sendTest() async {
    setState(() => _testing = true);
    final granted = await NotificationService.instance.requestPermission();
    if (!granted && mounted) {
      setState(() => _testing = false);
      _showSnack('Permission refusée. Active les notifications dans les paramètres.', Colors.red.shade700);
      return;
    }
    await NotificationService.instance.sendTestNotification();
    if (mounted) {
      setState(() => _testing = false);
      _showSnack('Notification test envoyée — vérifie ta barre.', Colors.green.shade700);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.inter(fontSize: 13)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _timeLabel() {
    final h = _hour.toString().padLeft(2, '0');
    final m = _minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: cs.surface,
      padding: EdgeInsets.fromLTRB(24, 12, 24, 32 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Daily reminder',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Get notified every morning to check your tasks.',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),

          if (_loading)
            const Center(child: CircularProgressIndicator())
          else ...[

            // Warning: exact alarm permission missing
            if (!_hasExactPermission) ...[
              GestureDetector(
                onTap: _requestExactPermission,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange.shade600, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Tap to grant "Exact alarms" permission — required for the reminder to fire on time.',
                          style: GoogleFonts.inter(fontSize: 13, color: Colors.orange.shade800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Enable toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Enable reminder',
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: cs.onSurface),
                  ),
                  Switch(
                    value: _enabled,
                    onChanged: _toggle,
                    activeThumbColor: cs.onSurface,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Time picker
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _enabled ? cs.onSurface : cs.outline,
                    width: _enabled ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reminder time',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: cs.onSurface),
                    ),
                    Row(
                      children: [
                        Text(
                          _timeLabel(),
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: cs.onSurface),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade500),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Test button
            GestureDetector(
              onTap: _testing ? null : _sendTest,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outline),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Send test notification',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: cs.onSurface),
                    ),
                    _testing
                        ? SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: cs.onSurface),
                          )
                        : Icon(Icons.send_outlined, size: 18, color: Colors.grey.shade500),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Done',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15, color: cs.onSurface),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
