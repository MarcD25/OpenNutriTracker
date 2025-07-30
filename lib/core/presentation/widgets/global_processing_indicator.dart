import 'package:flutter/material.dart';
import 'package:opennutritracker/features/chat/domain/service/chat_processing_service.dart';

class GlobalProcessingIndicator extends StatefulWidget {
  const GlobalProcessingIndicator({super.key});

  @override
  State<GlobalProcessingIndicator> createState() => _GlobalProcessingIndicatorState();
}

class _GlobalProcessingIndicatorState extends State<GlobalProcessingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    // Start checking for global processing state
    _checkProcessingState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _checkProcessingState() {
    if (ChatProcessingService.isGlobalProcessing && !_isVisible) {
      setState(() {
        _isVisible = true;
      });
      _animationController.forward();
    } else if (!ChatProcessingService.isGlobalProcessing && _isVisible) {
      _animationController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _isVisible = false;
          });
        }
      });
    }
    
    // Check again after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _checkProcessingState();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          right: 16,
          child: Transform.translate(
            offset: Offset(0, -50 * (1 - _animation.value)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'AI is processing your message...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
} 