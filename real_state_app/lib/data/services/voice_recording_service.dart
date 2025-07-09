import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class VoiceRecordingService {
  final AudioRecorder _recorder = AudioRecorder();

  /// Starts recording and returns the file path where the audio will be saved.
  Future<String?> startRecording() async {
    if (await _recorder.hasPermission()) {
      final dir = await getTemporaryDirectory();
      final filePath =
          '${dir.path}/voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(
        path: filePath,
        RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
      );
      return filePath;
    }
    return null;
  }

  /// Stops the recording and returns the file path of the recorded audio.
  Future<String?> stopRecording() async {
    return await _recorder.stop();
  }

  /// Returns true if currently recording, false otherwise.
  Future<bool> isRecording() async {
    return await _recorder.isRecording();
  }
}
