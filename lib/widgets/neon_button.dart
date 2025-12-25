import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NeonButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final Color color;
  final double? width;
  final double height;
  final bool isLoading;
  final double borderRadius;
  final double fontSize;
  final double iconSize;
  final double letterSpacing;

  const NeonButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.color = AppTheme.neonBlue,
    this.width,
    this.height = 55,
    this.isLoading = false,
    this.borderRadius = 15,
    this.fontSize = 16,
    this.iconSize = 22,
    this.letterSpacing = 1,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.width,
              height: widget.height,
              transform: Matrix4.identity()
                ..scale(_isPressed ? 0.95 : (_isHovered ? 1.02 : 1.0)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDisabled
                      ? [Colors.grey.shade700, Colors.grey.shade800]
                      : [
                          widget.color,
                          widget.color.withOpacity(0.7),
                        ],
                ),
                boxShadow: isDisabled
                    ? []
                    : [
                        BoxShadow(
                          color: widget.color.withOpacity(
                            _isHovered
                                ? 0.6
                                : 0.3 + (_glowAnimation.value * 0.2),
                          ),
                          blurRadius: _isHovered
                              ? 25
                              : 15 + (_glowAnimation.value * 10),
                          spreadRadius: _isHovered ? 3 : 1,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: widget.color.withOpacity(
                            _isHovered ? 0.4 : 0.2,
                          ),
                          blurRadius: 40,
                          spreadRadius: _isHovered ? 5 : 2,
                        ),
                      ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: Border.all(
                    color: Colors.white.withOpacity(
                      _isHovered ? 0.4 : 0.2,
                    ),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: widget.isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.8),
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(
                                widget.icon,
                                color: Colors.white,
                                size: widget.iconSize,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              widget.label,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: widget.fontSize,
                                fontWeight: FontWeight.bold,
                                letterSpacing: widget.letterSpacing,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class IconNeonButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final Color color;
  final double size;
  final String? tooltip;

  const IconNeonButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.color = AppTheme.neonBlue,
    this.size = 50,
    this.tooltip,
  });

  @override
  State<IconNeonButton> createState() => _IconNeonButtonState();
}

class _IconNeonButtonState extends State<IconNeonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip ?? '',
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.color,
                      widget.color.withOpacity(0.6),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(
                        _isHovered ? 0.7 : 0.3 + (_controller.value * 0.3),
                      ),
                      blurRadius: _isHovered ? 20 : 12 + (_controller.value * 8),
                      spreadRadius: _isHovered ? 2 : 0,
                    ),
                  ],
                ),
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: widget.size * 0.5,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class GradientButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final LinearGradient gradient;
  final double? width;
  final double height;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.gradient = AppTheme.goldGradient,
    this.width,
    this.height = 50,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width,
          height: widget.height,
          transform: Matrix4.identity()
            ..scale(_isPressed ? 0.95 : (_isHovered ? 1.03 : 1.0)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: widget.gradient,
            boxShadow: [
              BoxShadow(
                color: widget.gradient.colors.first.withOpacity(
                  _isHovered ? 0.6 : 0.3,
                ),
                blurRadius: _isHovered ? 20 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
