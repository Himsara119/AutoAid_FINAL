// lib/core/ai/image_analysis_service.dart
import 'dart:io';
import 'dart:developer' as dev;
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

class AnalysisResult {
  final String label;
  final double confidence;
  final Map<String, double>? topK;
  final DateTime ts;
  final String? modelName;
  final String? notes;

  // Not const; we use DateTime.now().
  AnalysisResult({
    required this.label,
    required this.confidence,
    this.topK,
    this.modelName,
    this.notes,
    DateTime? ts,
  }) : ts = ts ?? DateTime.now();
}

class ImageAnalysisService {
  static const _tag = 'ImageAnalysis';

  tfl.Interpreter? _interpreter;
  late List<String> _labels;

  // Discovered at runtime
  int _inH = 224, _inW = 224, _inC = 3, _outN = 1;
  late tfl.TensorType _inType;

  // For float models:
  // true  -> [0,1] normalize
  // false -> [-1,1] with mean/std 127.5 (MobileNet v1 style)
  final bool floatZeroToOne;
  ImageAnalysisService({this.floatZeroToOne = true});

  bool get isReady => _interpreter != null;

  Future<void> init({
    String modelAsset = 'assets/ml/model.tflite',
    String labelsAsset = 'assets/ml/labels.txt',
  }) async {
    if (_interpreter != null) return;

    // Load labels
    final txt = await rootBundle.loadString(labelsAsset);
    _labels = txt.split('\n').where((e) => e.trim().isNotEmpty).toList();

    // Try fast path; if the asset is compressed, fall back to temp file
    try {
      _interpreter = await tfl.Interpreter.fromAsset(modelAsset);
    } catch (_) {
      final bytes = await rootBundle.load(modelAsset);
      final dir = Directory.systemTemp.createTempSync('tflite_');
      final f = File('${dir.path}/model.tflite');
      await f.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
      _interpreter = await tfl.Interpreter.fromFile(f);
    }

    // Discover input tensor shape + type
    final inTensor = _interpreter!.getInputTensor(0);
    final shape = inTensor.shape; // [1, H, W, C]
    _inH = shape[1];
    _inW = shape[2];
    _inC = shape[3];
    _inType = inTensor.type;

    final outTensor = _interpreter!.getOutputTensor(0);
    // Most classifiers: [1, N]
    _outN = outTensor.shape.last;

    dev.log(
      'Interpreter ready: input=${inTensor.shape}($_inType), '
          'output=${outTensor.shape}(${outTensor.type}), '
          'labels=${_labels.length}',
      name: _tag,
    );

    // Warm-up with zeros of the correct shape and type
    final warmIn = _zeroInput();
    final warmOut = _zeroOutput();
    _interpreter!.run(warmIn, warmOut);
    dev.log('Warm-up complete', name: _tag);
  }

  Future<AnalysisResult> analyze(File file, {String? modelName}) async {
    if (_interpreter == null) {
      throw StateError('Service not initialized. Call init() first.');
    }

    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw 'Unsupported or corrupted image';

    // Center-crop shortest side, then resize to model H×W
    final minSide = decoded.width < decoded.height ? decoded.width : decoded.height;
    final crop = img.copyCrop(
      decoded,
      x: (decoded.width - minSide) ~/ 2,
      y: (decoded.height - minSide) ~/ 2,
      width: minSide,
      height: minSide,
    );
    final resized = img.copyResize(
      crop,
      width: _inW,
      height: _inH,
      interpolation: img.Interpolation.linear,
    );

    final input = _buildInput(resized);
    final output = _zeroOutput();
    _interpreter!.run(input, output);

    // output shape [1, N]
    final probs = (output[0] as List).map((e) => (e as num).toDouble()).toList();
    int best = 0;
    for (int j = 1; j < probs.length; j++) {
      if (probs[j] > probs[best]) best = j;
    }

    final idx = List<int>.generate(probs.length, (k) => k)
      ..sort((a, b) => probs[b].compareTo(probs[a]));
    final top = <String, double>{};
    for (final j in idx.take(5)) {
      // Guard if labels < outN
      final label = j < _labels.length ? _labels[j] : 'class_$j';
      top[label] = probs[j];
    }

    final bestLabel = best < _labels.length ? _labels[best] : 'class_$best';

    final result = AnalysisResult(
      label: bestLabel,
      confidence: probs[best],
      topK: top,
      modelName: modelName ?? 'tflite-local',
    );

    dev.log(
      'Result: ${result.label} ${(result.confidence * 100).toStringAsFixed(2)}%',
      name: _tag,
    );
    return result;
  }

  // ---------- internals ----------

  bool get _isUint8 =>
      _inType == tfl.TensorType.uint8 || _inType.toString().contains('uint8');

  dynamic _zeroInput() {
    // Build nested list with correct dtype/shape
    if (_isUint8) {
      return List.generate(
        1,
            (_) => List.generate(
          _inH,
              (_) => List.generate(_inW, (_) => List.filled(_inC, 0)),
        ),
      );
    } else {
      return List.generate(
        1,
            (_) => List.generate(
          _inH,
              (_) => List.generate(_inW, (_) => List.filled(_inC, 0.0)),
        ),
      );
    }
  }

  List<List<double>> _zeroOutput() {
    // Use the model's out size, not labels length
    return [List.filled(_outN, 0.0)];
  }

  // Pull channels directly from Pixel (image >= 4)
  @pragma('vm:prefer-inline')
  int _r(img.Pixel p) => p.r.toInt();
  @pragma('vm:prefer-inline')
  int _g(img.Pixel p) => p.g.toInt();
  @pragma('vm:prefer-inline')
  int _b(img.Pixel p) => p.b.toInt();

  dynamic _buildInput(img.Image image) {
    // Build nested list [1,H,W,C] matching input dtype
    if (_isUint8) {
      return List.generate(
        1,
            (_) => List.generate(
          _inH,
              (y) => List.generate(_inW, (x) {
            final px = image.getPixel(x, y); // Pixel
            return [_r(px), _g(px), _b(px)];
          }),
        ),
      );
    } else {
      // float32 path
      return List.generate(
        1,
            (_) => List.generate(
          _inH,
              (y) => List.generate(_inW, (x) {
            final px = image.getPixel(x, y);
            final r = _r(px).toDouble();
            final g = _g(px).toDouble();
            final b = _b(px).toDouble();
            if (floatZeroToOne) {
              return [r / 255.0, g / 255.0, b / 255.0];
            } else {
              const mean = 127.5, std = 127.5;
              return [(r - mean) / std, (g - mean) / std, (b - mean) / std];
            }
          }),
        ),
      );
    }
  }
}
