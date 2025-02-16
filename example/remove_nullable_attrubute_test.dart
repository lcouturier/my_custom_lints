class kiOui {
  void addCodePromo(String? codePromo) {
    if (codePromo != null) {
      print(codePromo);
    }
  }

  void call() {
    String codePromo = 'test';
    kiOui().addCodePromo(codePromo);
    kiOui().addCodePromo(null);
  }
}
