/// Where the access and refresh tokens live.
abstract class TokenStore {
  Future<StoredTokens?> read();
  Future<void> write(StoredTokens tokens);
  Future<void> clear();
}

class StoredTokens {
  const StoredTokens({required this.access, required this.refresh});

  final String access;
  final String refresh;
}

/// In-memory tokens for tests and the first frame before secure storage.
class MemoryTokenStore implements TokenStore {
  StoredTokens? current;

  @override
  Future<void> clear() async {
    current = null;
  }

  @override
  Future<StoredTokens?> read() async => current;

  @override
  Future<void> write(StoredTokens tokens) async {
    current = tokens;
  }
}
