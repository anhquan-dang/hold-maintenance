import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/providers/asset_provider.dart';
import '../utils/colors.dart';

class QrScanScreen extends ConsumerStatefulWidget {
  const QrScanScreen({super.key});

  @override
  ConsumerState<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends ConsumerState<QrScanScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final TextEditingController _codeController = TextEditingController();
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleScan(String code) async {
    final assets = await ref.read(assetsProvider.future);
    final match = assets.where((a) => a.assetCode.toUpperCase().trim() == code.toUpperCase().trim()).firstOrNull;

    if (match != null) {
      if (mounted) {
        // Redirect to detail
        Navigator.pushReplacementNamed(
          context,
          '/assets/detail',
          arguments: match.id,
        );
      }
    } else {
      setState(() {
        _errorMessage = 'Không tìm thấy tài sản với mã "$code"';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final assetsAsync = ref.watch(assetsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét mã QR'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Simulated camera background
          Container(color: Colors.black87),
          // Scanner Overlay Viewport
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60),
                const Text(
                  'Đặt mã QR vào khung hình bên dưới',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 30),
                Center(
                  child: SizedBox(
                    width: 250,
                    height: 250,
                    child: Stack(
                      children: [
                        // Viewfinder border corners
                        _buildViewfinderCorner(top: 0, left: 0),
                        _buildViewfinderCorner(top: 0, right: 0),
                        _buildViewfinderCorner(bottom: 0, left: 0),
                        _buildViewfinderCorner(bottom: 0, right: 0),
                        // Scanner Laser animation
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Positioned(
                              top: 250 * _animationController.value,
                              left: 8,
                              right: 8,
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withValues(alpha: 0.8),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Manual input section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      const Text(
                        'Hoặc nhập mã tài sản thủ công:',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _codeController,
                              style: const TextStyle(color: Colors.white),
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                hintText: 'Ví dụ: LTEN001',
                                hintStyle: const TextStyle(color: Colors.white38),
                                fillColor: Colors.white.withValues(alpha: 0.1),
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              final text = _codeController.text.trim();
                              if (text.isNotEmpty) {
                                _handleScan(text);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                      if (_errorMessage.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Simulating shortcuts
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                          child: Text(
                            'Giả lập quét tài sản nhanh:',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                        ),
                        Expanded(
                          child: assetsAsync.when(
                            data: (assets) {
                              final demoAssets = assets.take(5).toList();
                              return ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                itemCount: demoAssets.length,
                                itemBuilder: (context, index) {
                                  final asset = demoAssets[index];
                                  return ListTile(
                                    leading: const Icon(Icons.qr_code_2_rounded, color: AppColors.primary),
                                    title: Text(asset.assetName),
                                    subtitle: Text(asset.assetCode),
                                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                                    dense: true,
                                    onTap: () => _handleScan(asset.assetCode),
                                  );
                                },
                              );
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (error, _) => Center(child: Text(error.toString())),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewfinderCorner({
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border(
            top: top != null ? const BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
            bottom: bottom != null ? const BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
            left: left != null ? const BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
            right: right != null ? const BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
