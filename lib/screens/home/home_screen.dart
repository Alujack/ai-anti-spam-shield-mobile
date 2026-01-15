import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../providers/scan_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../utils/colors.dart';
import '../result/result_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocus = FocusNode();

  // Voice recording
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _recordingPath;
  int _recordingDuration = 0;

  @override
  void dispose() {
    _messageController.dispose();
    _messageFocus.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<bool> _checkMicrophonePermission() async {
    final status = await Permission.microphone.status;
    if (status.isDenied) {
      final result = await Permission.microphone.request();
      return result.isGranted;
    }
    return status.isGranted;
  }

  Future<void> _startRecording() async {
    final hasPermission = await _checkMicrophonePermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission is required for voice scanning'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _recordingPath = '${directory.path}/voice_scan_$timestamp.m4a';

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _recordingPath!,
      );

      setState(() {
        _isRecording = true;
        _recordingDuration = 0;
      });

      // Update recording duration every second
      _updateRecordingDuration();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start recording: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateRecordingDuration() async {
    while (_isRecording && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (_isRecording && mounted) {
        setState(() {
          _recordingDuration++;
        });
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
      });

      if (path != null && mounted) {
        // Show confirmation dialog
        _showVoiceScanConfirmation(path);
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to stop recording: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showVoiceScanConfirmation(String audioPath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.mic, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Voice Recording'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recording duration: ${_formatDuration(_recordingDuration)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your voice message will be transcribed and analyzed for scams.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Delete the recording
              File(audioPath).deleteSync();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _scanVoiceMessage(audioPath);
            },
            icon: const Icon(Icons.search, size: 18),
            label: const Text('Scan Voice'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _scanVoiceMessage(String audioPath) async {
    try {
      await ref.read(scanProvider.notifier).scanVoice(audioPath);

      // Clean up the audio file
      try {
        File(audioPath).deleteSync();
      } catch (_) {}

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ResultScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error scanning voice: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _scanMessage() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a message to scan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await ref.read(scanProvider.notifier).scanText(_messageController.text);
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ResultScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanProvider);
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.primary,
        elevation: 0,
        title: const Text(
          'AI Anti-Scam Shield',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/history');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Section
            FadeInDown(
              duration: const Duration(milliseconds: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome${authState.user?.name != null ? ", ${authState.user!.name}" : ""}!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Protect yourself from scams and spam messages',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Info Card
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(isDark ? 0.2 : 0.1),
                      AppColors.accent.withOpacity(isDark ? 0.2 : 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield, color: AppColors.primary, size: 40),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'AI-powered protection against scams, phishing, and spam',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Message Input Section
            FadeInUp(
              duration: const Duration(milliseconds: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter Message to Scan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _messageController,
                      focusNode: _messageFocus,
                      maxLines: 6,
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Paste or type the message you want to check...\n\nExample:\n"Congratulations! You\'ve won \$1000. Click here to claim your prize!"',
                        hintStyle: TextStyle(
                          color: (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary).withOpacity(0.5),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                        filled: true,
                        fillColor: isDark ? AppColors.darkCard : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Scan Button
            FadeInUp(
              duration: const Duration(milliseconds: 1000),
              child: CustomButton(
                text: 'Scan Message',
                onPressed: scanState.isLoading ? null : _scanMessage,
                isLoading: scanState.isLoading,
                icon: Icons.search,
              ),
            ),

            const SizedBox(height: 16),

            // Voice Recording Button
            FadeInUp(
              duration: const Duration(milliseconds: 1100),
              child: _isRecording
                  ? _buildRecordingButton()
                  : OutlinedButton.icon(
                      onPressed: scanState.isLoading ? null : _startRecording,
                      icon: const Icon(
                        Icons.mic,
                        color: AppColors.primary,
                      ),
                      label: const Text(
                        'Scan Voice Message',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.primary, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
            ),

            const SizedBox(height: 32),

            // Quick Tips
            FadeInUp(
              duration: const Duration(milliseconds: 1200),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb, color: AppColors.warning),
                        const SizedBox(width: 8),
                        Text(
                          'Quick Tips',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTip('Be cautious of messages asking for money or personal information', isDark),
                    _buildTip('Check for urgency tactics like "Act now!" or "Limited time!"', isDark),
                    _buildTip('Verify sender identity before clicking any links', isDark),
                    _buildTip('Trust your instincts - if it seems too good to be true, it probably is', isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingButton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated recording indicator
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.5, end: 1.0),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(value),
                  shape: BoxShape.circle,
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          Text(
            'Recording... ${_formatDuration(_recordingDuration)}',
            style: const TextStyle(
              color: AppColors.danger,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _stopRecording,
            icon: const Icon(Icons.stop, size: 18),
            label: const Text('Stop'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

