import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/dropbox_service.dart';

class DropboxImage extends StatefulWidget {
  final String remotePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const DropboxImage({
    super.key,
    required this.remotePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  State<DropboxImage> createState() => _DropboxImageState();
}

class _DropboxImageState extends State<DropboxImage> {
  Uint8List? _bytes;
  bool _loading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant DropboxImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.remotePath != widget.remotePath) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (widget.remotePath.isEmpty) {
      setState(() {
        _loading = false;
        _hasError = true;
      });
      return;
    }

    setState(() {
      _loading = true;
      _hasError = false;
    });

    try {
      final bytes =
          await DropboxService.instance.fetchFileBytes(widget.remotePath);
      if (mounted) {
        setState(() {
          _bytes = bytes;
          _loading = false;
          _hasError = bytes == null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_loading) {
      content = Container(
        width: widget.width,
        height: widget.height,
        color: AppColors.surfaceElevated,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
      );
    } else if (_hasError || _bytes == null) {
      content = Container(
        width: widget.width,
        height: widget.height,
        color: AppColors.surfaceElevated,
        child: Center(
          child: Icon(
            Icons.image_outlined,
            color: AppColors.textMuted.withOpacity(0.6),
            size: 32,
          ),
        ),
      );
    } else {
      content = Image.memory(
        _bytes!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) => Container(
          width: widget.width,
          height: widget.height,
          color: AppColors.surfaceElevated,
          child: const Icon(
            Icons.broken_image_outlined,
            color: AppColors.textMuted,
          ),
        ),
      );
    }

    if (widget.borderRadius != null) {
      return ClipRRect(
        borderRadius: widget.borderRadius!,
        child: content,
      );
    }

    return content;
  }
}
