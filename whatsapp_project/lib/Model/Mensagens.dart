class Mensagens {
  late String _idUsuario;
  late String _textoMensagens;
  late String _urlImagem;
  late String _tipo;
  late String _data;

  Mensagens({
    required String idUsuario,
    required String textoMensagens,
    required String urlImagem,
    required String tipo,
    required String data,
  })  : _idUsuario = idUsuario,
        _textoMensagens = textoMensagens,
        _urlImagem = urlImagem,
        _tipo = tipo,
        _data = data;

  String get idUsuario => _idUsuario;
  set idUsuario(String value) => _idUsuario = value;

  String get textoMensagens => _textoMensagens;
  set textoMensagens(String value) => _textoMensagens = value;

  String get urlImagem => _urlImagem;
  set urlImagem(String value) => _urlImagem = value;

  String get tipo => _tipo;
  set tipo(String value) => _tipo = value;

  String get data => _data;
  set data(String value) => _data = value;

  Map<String, dynamic> toMap() {
    return {
      "idUsuario": _idUsuario,
      "textoMensagens": _textoMensagens,
      "urlImagem": _urlImagem,
      "tipo": _tipo,
      "data": _data,
    };
  }
}
