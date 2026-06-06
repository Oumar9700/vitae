import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../meal_tracking/presentation/bloc/meal_bloc.dart';
import '../bloc/barcode_bloc.dart';
import 'barcode_product_confirmation_page.dart';

class BarcodeScannerPage extends StatefulWidget {
  final String userId;
  final DateTime date;

  const BarcodeScannerPage({
    super.key,
    required this.userId,
    required this.date,
  });

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final _controller = MobileScannerController();
  bool _scanned = false;
  bool _torchOn = false;

  @override
  void initState() {
    super.initState();
    context.read<BarcodeBloc>().add(const BarcodeStartRequested());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final code = capture.barcodes
        .where((b) => b.rawValue != null && b.rawValue!.isNotEmpty)
        .map((b) => b.rawValue!)
        .firstOrNull;
    if (code == null) return;

    setState(() => _scanned = true);
    _controller.stop();
    context.read<BarcodeBloc>().add(BarcodeCodeDetected(code));
  }

  void _retry() {
    setState(() => _scanned = false);
    _controller.start();
    context.read<BarcodeBloc>().add(const BarcodeRetryRequested());
  }

  Future<void> _onProductFound(BarcodeProductFound state) async {
    final didAdd = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (newCtx) => BlocProvider.value(
          value: context.read<MealBloc>(),
          child: BarcodeProductConfirmationPage(
            food: state.food,
            userId: widget.userId,
            date: widget.date,
          ),
        ),
      ),
    );

    if (!mounted) return;
    if (didAdd == true) {
      Navigator.pop(context);
    } else {
      _retry();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Scanner un code-barres',
            style: AppTypography.h3.copyWith(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(
              _torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              _controller.toggleTorch();
              setState(() => _torchOn = !_torchOn);
            },
          ),
        ],
      ),
      body: BlocConsumer<BarcodeBloc, BarcodeState>(
        listener: (context, state) {
          if (state is BarcodeProductFound) {
            _onProductFound(state);
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // Camera view
              MobileScanner(
                controller: _controller,
                onDetect: _onDetect,
              ),

              // Scan overlay
              _ScanOverlay(scanning: state is BarcodeScannerReady),

              // Status panel at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: _StatusPanel(
                    state: state,
                    onRetry: _retry,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Overlay de scan ─────────────────────────────────────────────────────────

class _ScanOverlay extends StatelessWidget {
  final bool scanning;
  const _ScanOverlay({required this.scanning});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OverlayPainter(scanning: scanning),
      child: const SizedBox.expand(),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final bool scanning;
  _OverlayPainter({required this.scanning});

  @override
  void paint(Canvas canvas, Size size) {
    const frameSize = 260.0;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final rect = Rect.fromCenter(
        center: Offset(cx, cy), width: frameSize, height: frameSize);

    // Dark overlay
    final overlayPaint = Paint()..color = Colors.black.withValues(alpha: 0.6);
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, overlayPaint);

    // Corner lines
    final cornerPaint = Paint()
      ..color = scanning ? AppColors.accent : Colors.white
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const len = 24.0;
    const r = 16.0;

    // Top-left
    canvas.drawLine(Offset(rect.left + r, rect.top), Offset(rect.left + r + len, rect.top), cornerPaint);
    canvas.drawLine(Offset(rect.left, rect.top + r), Offset(rect.left, rect.top + r + len), cornerPaint);
    // Top-right
    canvas.drawLine(Offset(rect.right - r, rect.top), Offset(rect.right - r - len, rect.top), cornerPaint);
    canvas.drawLine(Offset(rect.right, rect.top + r), Offset(rect.right, rect.top + r + len), cornerPaint);
    // Bottom-left
    canvas.drawLine(Offset(rect.left + r, rect.bottom), Offset(rect.left + r + len, rect.bottom), cornerPaint);
    canvas.drawLine(Offset(rect.left, rect.bottom - r), Offset(rect.left, rect.bottom - r - len), cornerPaint);
    // Bottom-right
    canvas.drawLine(Offset(rect.right - r, rect.bottom), Offset(rect.right - r - len, rect.bottom), cornerPaint);
    canvas.drawLine(Offset(rect.right, rect.bottom - r), Offset(rect.right, rect.bottom - r - len), cornerPaint);
  }

  @override
  bool shouldRepaint(_OverlayPainter old) => old.scanning != scanning;
}

// ─── Panneau de statut ────────────────────────────────────────────────────────

class _StatusPanel extends StatelessWidget {
  final BarcodeState state;
  final VoidCallback onRetry;

  const _StatusPanel({required this.state, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state is BarcodeScannerReady) ...[
            const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text('Pointez la caméra vers le code-barres',
                style: AppTypography.body.copyWith(color: Colors.white),
                textAlign: TextAlign.center),
          ] else if (state is BarcodeDetected || state is BarcodeProductLoading) ...[
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 3),
            ),
            const SizedBox(height: 8),
            Text('Recherche du produit…',
                style: AppTypography.body.copyWith(color: Colors.white)),
          ] else if (state is BarcodeProductNotFound) ...[
            const Icon(Icons.search_off_rounded, color: AppColors.error, size: 28),
            const SizedBox(height: 8),
            Text('Produit non trouvé dans OpenFoodFacts',
                style: AppTypography.body.copyWith(color: Colors.white),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            _RetryButton(onRetry: onRetry),
          ] else if (state is BarcodeError) ...[
            const Icon(Icons.wifi_off_rounded, color: AppColors.error, size: 28),
            const SizedBox(height: 8),
            Text((state as BarcodeError).message,
                style: AppTypography.body.copyWith(color: Colors.white),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            _RetryButton(onRetry: onRetry),
          ] else ...[
            Text('Initialisation…',
                style: AppTypography.body.copyWith(color: Colors.white)),
          ],
        ],
      ),
    );
  }
}

class _RetryButton extends StatelessWidget {
  final VoidCallback onRetry;
  const _RetryButton({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onRetry,
      icon: const Icon(Icons.refresh_rounded, size: 18),
      label: const Text('Réessayer'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 42),
      ),
    );
  }
}
