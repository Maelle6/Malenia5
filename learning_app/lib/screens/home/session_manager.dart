class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  bool hasGreetedThisSession = false;

  factory SessionManager() => _instance;

  SessionManager._internal();

  void reset() {
    hasGreetedThisSession = false;
  }
}
