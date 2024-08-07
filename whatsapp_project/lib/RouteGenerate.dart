import 'package:flutter/material.dart';
import 'package:whatsapp_project/Cadastro.dart' as cadastro_page;
import 'package:whatsapp_project/Configuracao.dart' as configuracao_page;
import 'package:whatsapp_project/Home.dart';
import 'package:whatsapp_project/Login.dart';
import 'package:whatsapp_project/mensagem.dart';
import 'package:whatsapp_project/Model/Usuario.dart';

class RouteGenerator {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case "/":
        return MaterialPageRoute(
          builder: (_) => Login(),
        );
      case "/login":
        return MaterialPageRoute(
          builder: (_) => Login(),
        );
      case "/cadastro":
        return MaterialPageRoute(
          builder: (_) => cadastro_page.Cadastro(),
        );
      case "/mensagens":
        if (args is Usuario) {
          return MaterialPageRoute(
            builder: (_) => Mensagem(contato: args),
          );
        }
        return _erroRota();
      case "/home":
        return MaterialPageRoute(
          builder: (_) => Home(),
        );
      case "/configuracoes":
        return MaterialPageRoute(
          builder: (_) => configuracao_page.Configuracoes(),
        );
      default:
        return _erroRota();
    }
  }

  static Route<dynamic>? _erroRota() {
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Tela não encontrada"),
          ),
          body: Center(
            child: Text("Tela não encontrada"),
          ),
        );
      },
    );
  }
}
