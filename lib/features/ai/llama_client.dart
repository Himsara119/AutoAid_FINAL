// Thin client abstraction for your diagnosis chatbot.
// Swap the body with your real HTTP call when your gateway is ready.

class LlamaClient {
  /// Returns a diagnostic response string.
  /// Wire this to your backend API that calls the LLM.
  Future<String> diagnose({
    required String userPrompt,
    String? analysisSummary,   // from AnalysisResult
    String? make,
    String? model,
    String? year,
  }) async {
    // TODO: replace with HTTP call to your service.
    final extra = [
      if (make != null) 'Make=$make',
      if (model != null) 'Model=$model',
      if (year != null) 'Year=$year',
    ].join(' ');
    return 'Preliminary assessment based on: $analysisSummary. '
        'Share OBD-II codes if available. $extra';
  }
}
