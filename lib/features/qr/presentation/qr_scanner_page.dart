import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  late final MobileScannerController _controller;
  bool _hasScanned = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      formats: const [BarcodeFormat.qrCode],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    await _controller.stop();
    if (!mounted) return;

    Navigator.of(context).maybePop();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    final code = capture.barcodes.isEmpty
        ? null
        : capture.barcodes.first.rawValue;
    if (_hasScanned || code == null) return;

    _hasScanned = true;
    await _controller.stop();
    if (!mounted) return;

    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF111111),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final scanSize = math.min(constraints.maxWidth - 90, 299.0);
            const scanTop = 223.0;
            final scanLeft = (constraints.maxWidth - scanSize) / 2;
            final scanRect = Rect.fromLTWH(
              scanLeft,
              scanTop,
              scanSize,
              scanSize,
            );

            return Stack(
              children: [
                Positioned.fill(
                  child: MobileScanner(
                    controller: _controller,
                    fit: BoxFit.cover,
                    onDetect: _onDetect,
                  ),
                ),
                Positioned.fill(
                  child: CustomPaint(
                    painter: _QrScannerOverlayPainter(scanRect: scanRect),
                  ),
                ),
                Positioned(
                  top: math.max(scanRect.top - 68, 112),
                  left: 24,
                  right: 24,
                  child: const Text(
                    'Поместите QR-код в рамку',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Positioned(
                  top: 70,
                  right: 42,
                  child: IconButton(
                    onPressed: _close,
                    icon: const Icon(Icons.close),
                    color: Color(0xFF8E8E93),
                    iconSize: 32,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _QrScannerOverlayPainter extends CustomPainter {
  final Rect scanRect;

  const _QrScannerOverlayPainter({required this.scanRect});

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPath = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRect(scanRect);

    canvas.drawPath(
      overlayPath,
      Paint()..color = Colors.black.withValues(alpha: 0.64),
    );

    final cornerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const cornerLength = 36.0;

    canvas
      ..drawLine(
        scanRect.topLeft,
        scanRect.topLeft + const Offset(cornerLength, 0),
        cornerPaint,
      )
      ..drawLine(
        scanRect.topLeft,
        scanRect.topLeft + const Offset(0, cornerLength),
        cornerPaint,
      )
      ..drawLine(
        scanRect.topRight,
        scanRect.topRight - const Offset(cornerLength, 0),
        cornerPaint,
      )
      ..drawLine(
        scanRect.topRight,
        scanRect.topRight + const Offset(0, cornerLength),
        cornerPaint,
      )
      ..drawLine(
        scanRect.bottomLeft,
        scanRect.bottomLeft + const Offset(cornerLength, 0),
        cornerPaint,
      )
      ..drawLine(
        scanRect.bottomLeft,
        scanRect.bottomLeft - const Offset(0, cornerLength),
        cornerPaint,
      )
      ..drawLine(
        scanRect.bottomRight,
        scanRect.bottomRight - const Offset(cornerLength, 0),
        cornerPaint,
      )
      ..drawLine(
        scanRect.bottomRight,
        scanRect.bottomRight - const Offset(0, cornerLength),
        cornerPaint,
      );
  }

  @override
  bool shouldRepaint(_QrScannerOverlayPainter oldDelegate) {
    return oldDelegate.scanRect != scanRect;
  }
}
