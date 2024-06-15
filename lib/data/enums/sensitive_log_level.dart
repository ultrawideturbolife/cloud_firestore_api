enum SensitiveLogLevel {
  info,
  warning,
  error,
  none,
  ;

  bool get shouldNotInfo => index > SensitiveLogLevel.info.index;
  bool get shouldNotWarning => index > SensitiveLogLevel.warning.index;
  bool get shouldNotError => index > SensitiveLogLevel.error.index;
}
