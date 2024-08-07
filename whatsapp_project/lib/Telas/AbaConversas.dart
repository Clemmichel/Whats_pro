import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_project/Model/Conversa.dart';
import 'package:whatsapp_project/Model/Usuario.dart';

class Abaconversas extends StatefulWidget {
  const Abaconversas({super.key});

  @override
  State<Abaconversas> createState() => _AbaconversasState();
}

class _AbaconversasState extends State<Abaconversas> {
  List<Conversa> _ListaConversas = [];

  final _controller = StreamController<QuerySnapshot>.broadcast();
  FirebaseFirestore db = FirebaseFirestore.instance;
  late String _idusuarioLogado;

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();

    Conversa conversa = Conversa();
    conversa.nome = "Michell";
    conversa.mensagem = "Olá tudo bem?";

    _ListaConversas.add(conversa);
  }

  void _adicionarlistenerConversas() {
    db
        .collection("conversa")
        .doc(_idusuarioLogado)
        .collection("ultima_conversa")
        .snapshots()
        .listen((dados) {
      _controller.add(dados);
    });
  }

  Future<void> _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioLogado = auth.currentUser;

    if (usuarioLogado != null) {
      _idusuarioLogado = usuarioLogado.uid;
      _adicionarlistenerConversas();
    } else {
      _idusuarioLogado = '';
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.close();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _controller.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Carregando Conversa"),
                  CircularProgressIndicator(),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Erro ao carregar os dados!"));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text("Nenhuma conversa encontrada!"));
          }

          QuerySnapshot querySnapshot = snapshot.data!;

          if (querySnapshot.docs.isEmpty) {
            return Center(
              child: Text(
                "Você não tem nenhuma mensagem ainda!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          return ListView.builder(
            itemCount: querySnapshot.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot item = querySnapshot.docs[index];

              String urlImagem = item["caminhoFoto"] ?? '';
              String tipo = item["tipoMensagem"];
              String mensagem = item["mensagem"];
              String nome = item["nome"];
              String idDestinatario = item["idDestinatario"];

              Usuario usuario = Usuario();
              usuario.nome = nome;
              usuario.urlImagem = urlImagem;
              usuario.idUsuario = idDestinatario;

              return ListTile(
                onTap: () {
                  Navigator.pushNamed(context, "/mensagens",
                      arguments: usuario);
                },
                contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                leading: CircleAvatar(
                  maxRadius: 30,
                  backgroundColor: Colors.grey,
                  backgroundImage:
                      urlImagem.isNotEmpty ? NetworkImage(urlImagem) : null,
                ),
                title: Text(
                  nome,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(
                  tipo == "texto" ? mensagem : "imagem...",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              );
            },
          );
        });
  }
}
