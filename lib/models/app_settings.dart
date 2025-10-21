class AppSettings {
  final bool isDarkMode;
  final String currencySymbol;
  final String language;
  final bool showAmountInWords;
  final bool autoSave;
  final bool? hapticFeedback;

  AppSettings({
    this.isDarkMode = false,
    this.currencySymbol = '₹',
    this.language = 'en',
    this.showAmountInWords = true,
    this.autoSave = false,
    this.hapticFeedback = true,
  });

  AppSettings copyWith({
    bool? isDarkMode,
    String? currencySymbol,
    String? language,
    bool? showAmountInWords,
    bool? autoSave,
    bool? hapticFeedback,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      language: language ?? this.language,
      showAmountInWords: showAmountInWords ?? this.showAmountInWords,
      autoSave: autoSave ?? this.autoSave,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'currencySymbol': currencySymbol,
      'language': language,
      'showAmountInWords': showAmountInWords,
      'autoSave': autoSave,
      'hapticFeedback': hapticFeedback,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      isDarkMode: json['isDarkMode'] ?? false,
      currencySymbol: json['currencySymbol'] ?? '₹',
      language: json['language'] ?? 'en',
      showAmountInWords: json['showAmountInWords'] ?? true,
      autoSave: json['autoSave'] ?? false,
      hapticFeedback: json['hapticFeedback'] ?? true,
    );
  }

  @override
  String toString() {
    return 'AppSettings(isDarkMode: $isDarkMode, currencySymbol: $currencySymbol, language: $language, showAmountInWords: $showAmountInWords, autoSave: $autoSave, hapticFeedback: $hapticFeedback)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.isDarkMode == isDarkMode &&
        other.currencySymbol == currencySymbol &&
        other.language == language &&
        other.showAmountInWords == showAmountInWords &&
        other.autoSave == autoSave &&
        other.hapticFeedback == hapticFeedback;
  }

  @override
  int get hashCode {
    return isDarkMode.hashCode ^
    currencySymbol.hashCode ^
    language.hashCode ^
    showAmountInWords.hashCode ^
    autoSave.hashCode ^
    hapticFeedback.hashCode;
  }
}