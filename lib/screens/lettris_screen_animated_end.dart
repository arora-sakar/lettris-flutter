              fontSize: _getResponsiveFontSize(context, baseSize: 16, scaleFactor: 0.008),
            ),
          ),
        
        // Instructions popup
        if (instPopupShow)
          _buildPopupDialog(
            context: context, 
            child: InstructionsPopup(
              fontSize: _getResponsiveFontSize(context, baseSize: 14, scaleFactor: 0.007),
            ),
            onClose: handleInstClick,
          ),
        
        // Stats popup
        if (statPopupShow)
          _buildPopupDialog(
            context: context, 
            child: StatsPopup(
              score: score,
              highScore: highScore,
              fontSize: _getResponsiveFontSize(context, baseSize: 16, scaleFactor: 0.008),
            ),
            onClose: handleStatClick,
            maxHeightFactor: 0.4,
          ),
      ],
    );
  }
  
  // Helper method to build popup dialogs
  Widget _buildPopupDialog({
    required BuildContext context,
    required Widget child,
    required VoidCallback onClose,
    double maxWidthFactor = 0.9,
    double maxHeightFactor = 0.8,
  }) {
    return Center(
      child: Dialog(
        child: IntrinsicHeight(
          child: IntrinsicWidth(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * maxWidthFactor,
                maxHeight: MediaQuery.of(context).size.height * maxHeightFactor,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: child,
                    ),
                  ),
                  TextButton(
                    onPressed: onClose,
                    child: Text(
                      'Close',
                      style: TextStyle(
                        fontSize: _getResponsiveFontSize(context, baseSize: 14, scaleFactor: 0.008),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
