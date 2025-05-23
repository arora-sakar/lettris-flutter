import 'package:flutter/material.dart';

// Data class to represent an animated square with position and animation state
class AnimatedSquareData {
  final String letter;
  final bool selected;
  final int gridIndex;
  final bool isAnimating;
  final bool isFalling;
  final bool isRemoving;
  final double animationProgress;
  final int? fromIndex;
  final int? toIndex;
  
  const AnimatedSquareData({
    required this.letter,
    required this.selected,
    required this.gridIndex,
    this.isAnimating = false,
    this.isFalling = false,
    this.isRemoving = false,
    this.animationProgress = 0.0,
    this.fromIndex,
    this.toIndex,
  });
  
  AnimatedSquareData copyWith({
    String? letter,
    bool? selected,
    int? gridIndex,
    bool? isAnimating,
    bool? isFalling,
    bool? isRemoving,
    double? animationProgress,
    int? fromIndex,
    int? toIndex,
  }) {
    return AnimatedSquareData(
      letter: letter ?? this.letter,
      selected: selected ?? this.selected,
      gridIndex: gridIndex ?? this.gridIndex,
      isAnimating: isAnimating ?? this.isAnimating,
      isFalling: isFalling ?? this.isFalling,
      isRemoving: isRemoving ?? this.isRemoving,
      animationProgress: animationProgress ?? this.animationProgress,
      fromIndex: fromIndex ?? this.fromIndex,
      toIndex: toIndex ?? this.toIndex,
    );
  }
}

// Animated square widget that handles smooth position transitions
class AnimatedGameSquare extends StatefulWidget {
  final AnimatedSquareData data;
  final VoidCallback onTap;
  final double fontSize;
  final int gridWidth;
  final Duration animationDuration;
  final Curve animationCurve;

  const AnimatedGameSquare({
    super.key,
    required this.data,
    required this.onTap,
    required this.gridWidth,
    this.fontSize = 20,
    this.animationDuration = const Duration(milliseconds: 400),
    this.animationCurve = Curves.easeInOut,
  });

  @override
  State<AnimatedGameSquare> createState() => _AnimatedGameSquareState();
}

class _AnimatedGameSquareState extends State<AnimatedGameSquare>
    with TickerProviderStateMixin {
  late AnimationController _positionController;
  late AnimationController _removeController;
  late AnimationController _landController;
  
  late Animation<double> _positionAnimation;
  late Animation<double> _removeAnimation;
  late Animation<double> _landAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Position animation for falling movement
    _positionController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    // Remove animation for word clearing
    _removeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Landing animation for bounce effect
    _landController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _positionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _positionController,
      curve: widget.animationCurve,
    ));
    
    _removeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _removeController,
      curve: Curves.easeInOut,
    ));
    
    _landAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _landController,
      curve: Curves.elasticOut,
    ));
  }
  
  @override
  void didUpdateWidget(AnimatedGameSquare oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle animation triggers based on data changes
    if (widget.data.isRemoving && !oldWidget.data.isRemoving) {
      _removeController.forward();
    } else if (!widget.data.isRemoving && oldWidget.data.isRemoving) {
      _removeController.reset();
    }
    
    if (widget.data.isAnimating && !oldWidget.data.isAnimating) {
      _positionController.forward().then((_) {
        // Trigger landing animation when position animation completes
        if (widget.data.isFalling) {
          _landController.forward().then((_) {
            _landController.reset();
          });
        }
      });
    } else if (!widget.data.isAnimating && oldWidget.data.isAnimating) {
      _positionController.reset();
    }
  }
  
  @override
  void dispose() {
    _positionController.dispose();
    _removeController.dispose();
    _landController.dispose();
    super.dispose();
  }
  
  // Calculate position offset based on grid indices
  Offset _calculatePositionOffset() {
    if (!widget.data.isAnimating || 
        widget.data.fromIndex == null || 
        widget.data.toIndex == null) {
      return Offset.zero;
    }
    
    final fromRow = widget.data.fromIndex! ~/ widget.gridWidth;
    final fromCol = widget.data.fromIndex! % widget.gridWidth;
    final toRow = widget.data.toIndex! ~/ widget.gridWidth;
    final toCol = widget.data.toIndex! % widget.gridWidth;
    
    final deltaRow = (toRow - fromRow).toDouble();
    final deltaCol = (toCol - fromCol).toDouble();
    
    // Interpolate position based on animation progress
    final progress = _positionAnimation.value;
    final currentDeltaRow = deltaRow * (1.0 - progress);
    final currentDeltaCol = deltaCol * (1.0 - progress);
    
    return Offset(currentDeltaCol, currentDeltaRow);
  }
  
  // Calculate transform matrix for the square
  Matrix4 _calculateTransform() {
    Matrix4 transform = Matrix4.identity();
    
    // Position offset for falling animation
    final positionOffset = _calculatePositionOffset();
    if (positionOffset != Offset.zero) {
      // Convert grid position to pixel offset (approximate cell size: 40px)
      const cellSize = 40.0;
      transform.translate(
        positionOffset.dx * cellSize,
        positionOffset.dy * cellSize,
      );
    }
    
    // Scale animation for removal
    if (widget.data.isRemoving) {
      final scale = _removeAnimation.value;
      transform.scale(scale, scale);
    }
    
    // Landing bounce effect
    if (_landController.isAnimating) {
      final bounce = 1.0 + (_landAnimation.value * 0.2);
      transform.scale(bounce, bounce);
    }
    
    return transform;
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _positionAnimation,
        _removeAnimation,
        _landAnimation,
      ]),
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: _calculateTransform(),
          child: Opacity(
            opacity: widget.data.isRemoving ? _removeAnimation.value : 1.0,
            child: _buildSquareContent(),
          ),
        );
      },
    );
  }
  
  Widget _buildSquareContent() {
    String squareClass = '';
    Color backgroundColor = Colors.grey[200]!;
    BoxBorder? border;

    if (widget.data.letter.isEmpty) {
      squareClass = "empty-square";
      backgroundColor = Colors.grey[200]!;
      border = null;
    } else {
      // Generate a color based on the letter
      final int letterCode = widget.data.letter.codeUnitAt(0) - 'A'.codeUnitAt(0);
      final double hue = (letterCode * 13.85) % 360; // Distribute colors around the hue wheel
      
      if (widget.data.selected) {
        backgroundColor = HSLColor.fromAHSL(1.0, hue, 0.7, 0.8).toColor();
        border = Border.all(color: Colors.black, width: 1, style: BorderStyle.solid);
      } else {
        backgroundColor = HSLColor.fromAHSL(1.0, hue, 0.7, 0.5).toColor();
        border = Border.all(color: Colors.black, width: 1, style: BorderStyle.solid);
      }
    }

    return GestureDetector(
      onTap: widget.data.selected ? null : widget.onTap,
      child: Container(
        // Add minimum constraints for better accessibility
        constraints: const BoxConstraints(
          minWidth: 48.0,
          minHeight: 48.0,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: border,
          borderRadius: BorderRadius.circular(4),
          boxShadow: widget.data.isFalling ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Center(
          child: Text(
            widget.data.letter,
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// Animation manager to coordinate multiple square animations
class SquareAnimationManager {
  final Map<int, AnimationController> _controllers = {};
  final Duration staggerDelay;
  
  SquareAnimationManager({
    this.staggerDelay = const Duration(milliseconds: 50),
  });
  
  // Animate multiple squares falling with stagger effect
  void animateFallingSquares(
    List<int> indices,
    TickerProvider vsync,
    VoidCallback onComplete,
  ) {
    if (indices.isEmpty) {
      onComplete();
      return;
    }
    
    int completedCount = 0;
    
    for (int i = 0; i < indices.length; i++) {
      final index = indices[i];
      final controller = AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: vsync,
      );
      
      _controllers[index] = controller;
      
      // Stagger the animations
      Future.delayed(staggerDelay * i, () {
        controller.forward().then((_) {
          completedCount++;
          if (completedCount == indices.length) {
            onComplete();
          }
          _controllers.remove(index);
          controller.dispose();
        });
      });
    }
  }
  
  // Get animation progress for a specific square
  double getAnimationProgress(int index) {
    final controller = _controllers[index];
    return controller?.value ?? 0.0;
  }
  
  // Check if a square is currently animating
  bool isAnimating(int index) {
    return _controllers.containsKey(index);
  }
  
  // Clean up all controllers
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }
}