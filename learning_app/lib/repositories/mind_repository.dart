class MindRepository {
  Future<List<String>> fetchMindData() async {
    await Future.delayed(const Duration(seconds: 2));
    return ['Meditate', 'Focus', 'Move', 'Sleep'];
  }
}
