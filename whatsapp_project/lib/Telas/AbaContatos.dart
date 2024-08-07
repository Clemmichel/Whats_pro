import 'package:flutter/material.dart';
import 'package:whatsapp_project/Model/Usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Abacontatos extends StatefulWidget {
  const Abacontatos({super.key});

  @override
  State<Abacontatos> createState() => _AbacontatosState();
}

class _AbacontatosState extends State<Abacontatos> {
  late String _idUsuarioLogado;
  late String _emailUsuarioLogado;

  Future<List<Usuario>> _recuperarContatos() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await db.collection("usuarios").get();

    List<Usuario> listaUsuario = [];
    for (DocumentSnapshot item in querySnapshot.docs) {
      var dados = item.data() as Map<String, dynamic>;

      if (dados.containsKey("email") &&
          dados["email"] is String &&
          dados.containsKey("nome") &&
          dados["nome"] is String) {
        String email = dados["email"] ?? "";
        String nome = dados["nome"] ?? "";
        String? urlImagem = dados["urlImagem"];

        if (email == _emailUsuarioLogado) continue;

        Usuario usuario = Usuario();
        usuario.email = email;
        usuario.nome = nome;
        usuario.urlImagem = urlImagem;
        usuario.idUsuario = item.id;

        listaUsuario.add(usuario);
      }
    }
    return listaUsuario;
  }

  Future<void> _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioLogado = auth.currentUser;
    if (usuarioLogado != null) {
      _idUsuarioLogado = usuarioLogado.uid;
      _emailUsuarioLogado = usuarioLogado.email ?? "";
    }
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Usuario>>(
      future: _recuperarContatos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Carregando contatos"),
                CircularProgressIndicator(),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          print("Erro ao carregar contatos: ${snapshot.error}");
          return Center(
              child: Text("Erro ao carregar contatos: ${snapshot.error}"));
        }

        List<Usuario> listaItens = snapshot.data ?? [];

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("Nenhum contato encontrado"));
        }

        return ListView.builder(
          itemCount: listaItens.length,
          itemBuilder: (context, index) {
            Usuario usuario = listaItens[index];

            return ListTile(
              onTap: () {
                Navigator.pushNamed(context, "/mensagens", arguments: usuario);
              },
              contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              leading: CircleAvatar(
                maxRadius: 30,
                backgroundColor: Colors.grey,
                backgroundImage: usuario.urlImagem != null
                    ? NetworkImage(usuario.urlImagem!)
                    : null,
              ),
              title: Text(
                usuario.nome,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
