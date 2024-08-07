import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_project/Login.dart';
import 'package:whatsapp_project/Telas/AbaContatos.dart';
import 'package:whatsapp_project/Telas/AbaConversas.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _emailUsuario = "";

  Future _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioLogado = await auth.currentUser;

    setState(() {
      if (usuarioLogado != null) {
        _emailUsuario = usuarioLogado.email ?? "";
      }
    });
  }

  List<String> itensMenu = ["Configurações", "Sair"];

  Future _verificarUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    Future.delayed(Duration.zero, () {
      User? usuarioLogado = auth.currentUser;
      if (usuarioLogado == null) {
        Navigator.pushReplacementNamed(context, "/login");
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _verificarUsuarioLogado();
    _recuperarDadosUsuario();

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();

    super.dispose();
  }

  _escolhaMenuItem(String itemEscolhido) {
    switch (itemEscolhido) {
      case "Configurações":
        Navigator.pushNamed(context, "/configuracoes");

        break;
      case "Sair":
        _deslogarUsuario();
        break;
    }
  }

  _deslogarUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();

    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff075E54),
        title: Text("WhatsApp"),
        foregroundColor: Colors.white,
        bottom: TabBar(
            indicatorWeight: 4,
            labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            controller: _tabController,
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                text: "Conversas",
              ),
              Tab(
                text: "Contatos",
              )
            ]),
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (context) {
              return itensMenu.map((String item) {
                return PopupMenuItem<String>(
                  child: Text(item),
                  value: item,
                );
              }).toList();
            },
            onSelected: _escolhaMenuItem,
          )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [Abaconversas(), Abacontatos()],
      ),
    );
  }
}
