

import 'package:flutter/material.dart';
import 'package:pulsepay/common/reusable_text.dart';

class CustomSubmitBtn extends StatefulWidget {
  const CustomSubmitBtn({
    super.key,
    this.width,
    this.height,
    required this.text,
    required this.onTap,
    required this.color,
    this.color2,
  });

  final double? width;
  final double? height;
  final String text;
  final Future<void> Function() onTap; // Updated to async to handle waiting
  final Color color;
  final Color? color2;

  @override
  State<CustomSubmitBtn> createState() => _CustomOutlineBtnState();
}

class _CustomOutlineBtnState extends State<CustomSubmitBtn> {
  bool _isDisabled = false;

  Future<void> _handleTap() async {
    if (_isDisabled) return;

    setState(() {
      _isDisabled = true;
    });

    try {
      await widget.onTap(); // wait for action to complete
    } catch (e) {
      // optionally show error or revert disabled state
      debugPrint("Error: $e");
    }

    setState(() {
      _isDisabled = false; // re-enable if needed, or keep it disabled
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isDisabled ? null : _handleTap,
      child: Opacity(
        opacity: _isDisabled ? 0.6 : 1.0, // Visual feedback for disabled state
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: widget.color2,
            border: Border.all(
              width: 1,
              color: widget.color,
            ),
          ),
          child: Center(
            child: ReusableText(
              text: widget.text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
