import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../prayer_times/data/adhan_preview.dart';
import '../../prayer_times/data/adhan_voices.dart';

Future<void> showAdhanVoiceSheet(
  BuildContext context, {
  required List<AdhanVoice> voices,
  required String selectedId,
  required ValueChanged<String> onSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _AdhanVoiceSheet(
      voices: voices,
      selectedId: selectedId,
      onSelected: onSelected,
    ),
  ).whenComplete(AdhanPreview.stop);
}

class _AdhanVoiceSheet extends StatefulWidget {
  const _AdhanVoiceSheet({
    required this.voices,
    required this.selectedId,
    required this.onSelected,
  });
  final List<AdhanVoice> voices;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  State<_AdhanVoiceSheet> createState() => _AdhanVoiceSheetState();
}

class _AdhanVoiceSheetState extends State<_AdhanVoiceSheet> {
  late String _selected = widget.selectedId;
  String? _previewing;

  Future<void> _togglePreview(AdhanVoice v) async {
    if (_previewing == v.id) {
      await AdhanPreview.stop();
      setState(() => _previewing = null);
    } else {
      await AdhanPreview.play(v.rawName);
      setState(() => _previewing = v.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            for (final v in widget.voices)
              RadioListTile<String>(
                value: v.id,
                groupValue: _selected,
                title: Text(v.nameAr),
                secondary: IconButton(
                  tooltip: 'استمع',
                  icon: Icon(
                    _previewing == v.id
                        ? Icons.stop_circle_outlined
                        : Icons.play_circle_outline,
                    color: AppColors.deepEmerald,
                  ),
                  onPressed: () => _togglePreview(v),
                ),
                onChanged: (id) {
                  if (id == null) return;
                  setState(() => _selected = id);
                  widget.onSelected(id);
                },
              ),
          ],
        ),
      ),
    );
  }
}
