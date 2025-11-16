// bilibili错误
class BilibiliError implements Exception {
  static const notLoggedIn = BilibiliError(-101, '未登陆');
  
  final int code;
  final String message;

  const BilibiliError(this.code, this.message);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BilibiliError) return false;
    return code == other.code;
  }

  @override
  int get hashCode => code.hashCode;
}
