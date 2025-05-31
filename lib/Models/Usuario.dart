class Usuario {
  late String _nome;
  late String _email;
  late String _Senha;
  String? _urlImagem;
  late String _idsuario;

  Usuario();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {"nome": this.nome, "email": this.email};
    return map;
  }

  String get nome => this._nome;

  set nome(String value) => this._nome = value;

  String get email => this._email;

  set email(String value) => this._email = value;

  String get Senha => this._Senha;

  set Senha(String value) => this._Senha = value;

  String? get urlImagem => this._urlImagem;

  set urlImagem(String? value) => this._urlImagem = value;

  String get idUsuario => this._idsuario;

  set idUsuario(value) => this._idsuario = value;
}
