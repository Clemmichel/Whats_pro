import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsapp_project/Models/Conversa.dart';
import 'package:whatsapp_project/Models/Mensagens.dart';
import 'package:whatsapp_project/Models/Usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class Mensagem extends StatefulWidget {
  final Usuario contato;

  const Mensagem({super.key, required this.contato});

  @override
  State<Mensagem> createState() => _MensagemState();
}

class _MensagemState extends State<Mensagem> {
  bool _subindoImagem = false;
  File? _imagem;
  late String _idusuarioLogado = " ";
  late String _idusuarioDestinatario;
  FirebaseFirestore db = FirebaseFirestore.instance;
  final TextEditingController _controllerMensagem = TextEditingController();
  final _controller = StreamController<QuerySnapshot>.broadcast();
  ScrollController _scrollController = ScrollController();

  Future<void> _enviarMensagem() async {
    String textoMensagem = _controllerMensagem.text;
    if (textoMensagem.isNotEmpty) {
      Mensagens mensagens = Mensagens(
        idUsuario: _idusuarioLogado,
        textoMensagens: textoMensagem,
        urlImagem: "",
        tipo: "texto",
        data: Timestamp.now().toString(),
      );

      await _salvarMensagem(
          _idusuarioLogado, _idusuarioDestinatario, mensagens);
      await _salvarMensagem(
          _idusuarioDestinatario, _idusuarioLogado, mensagens);

      _salvarConversa(mensagens);
    }
  }

  void _salvarConversa(Mensagens msg) {
    Conversa cRemetente = Conversa();
    cRemetente.idRemetente = _idusuarioLogado;
    cRemetente.idDestinatario = _idusuarioDestinatario;
    cRemetente.mensagem = msg.textoMensagens;
    cRemetente.nome = widget.contato.nome;
    cRemetente.caminhoFoto = widget.contato.urlImagem;
    cRemetente.tipoMensagem = msg.tipo;
    cRemetente.salvar();

    Conversa cDestinatario = Conversa();
    cDestinatario.idRemetente = _idusuarioDestinatario;
    cDestinatario.idDestinatario = _idusuarioLogado;
    cDestinatario.mensagem = msg.textoMensagens;
    cDestinatario.nome = widget.contato.nome;
    cDestinatario.caminhoFoto = widget.contato.urlImagem;
    cDestinatario.tipoMensagem = msg.tipo;
    cDestinatario.salvar();
  }

  Future<void> _salvarMensagem(
      String idRemetente, String idDestinario, Mensagens msg) async {
    await db
        .collection("mensagens")
        .doc(idRemetente)
        .collection(idDestinario)
        .add(msg.toMap());

    _controllerMensagem.clear();
  }

  Future<void> _enviarFoto() async {
    final picker = ImagePicker();
    final XFile? xFile = await picker.pickImage(source: ImageSource.gallery);

    if (xFile == null) return;

    File imagemSelecionada = File(xFile.path);
    setState(() {
      _subindoImagem = true;
    });

    String nomeImagem = DateTime.now().microsecondsSinceEpoch.toString();
    Reference pastaRaiz = FirebaseStorage.instance.ref();
    Reference arquivo = pastaRaiz
        .child("mensagens")
        .child(_idusuarioLogado)
        .child("$nomeImagem.jpg");

    UploadTask task = arquivo.putFile(imagemSelecionada);

    task.snapshotEvents.listen((TaskSnapshot snapshot) {
      if (snapshot.state == TaskState.running) {
        setState(() {
          _subindoImagem = true;
        });
      } else if (snapshot.state == TaskState.success) {
        setState(() {
          _subindoImagem = false;
        });
      }
    });

    final TaskSnapshot snapshot = await task;
    final String urlImagem = await snapshot.ref.getDownloadURL();

    Mensagens mensagens = Mensagens(
      idUsuario: _idusuarioLogado,
      textoMensagens: "",
      urlImagem: urlImagem,
      tipo: "imagem",
      data: Timestamp.now().toString(),
    );

    await _salvarMensagem(_idusuarioLogado, _idusuarioDestinatario, mensagens);
    await _salvarMensagem(_idusuarioDestinatario, _idusuarioLogado, mensagens);
  }

  Future<void> _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioLogado = auth.currentUser;
    _idusuarioDestinatario = widget.contato.idUsuario;
    _adicionarlistenerMensagem();

    if (usuarioLogado != null) {
      _idusuarioLogado = usuarioLogado.uid;
    } else {
      _idusuarioLogado = '';
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _recuperarDadosUsuario().then((_) {
      _adicionarlistenerMensagem();
    });
  }

  void _adicionarlistenerMensagem() {
    if (_idusuarioLogado.isEmpty || _idusuarioDestinatario.isEmpty) {
      return; // ou exiba uma mensagem de erro
    }

    db
        .collection("mensagens")
        .doc(_idusuarioLogado)
        .collection(_idusuarioDestinatario)
        .orderBy("data", descending: false)
        .snapshots()
        .listen((dados) {
      _controller.add(dados);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    });
  }

  void _navegarParaHome() {
    Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff075E54),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, "/home");
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              maxRadius: 20,
              backgroundColor: Colors.grey,
              backgroundImage: widget.contato.urlImagem != null
                  ? NetworkImage(widget.contato.urlImagem!)
                  : AssetImage('urlImagem'),
            ),
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(widget.contato.nome),
            ),
          ],
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _controller.stream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Carregando Mensagens"),
                              CircularProgressIndicator(),
                            ],
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                            child: Text("Erro ao carregar os dados!"));
                      } else if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return Center(
                            child: Text("Nenhuma mensagem encontrada!"));
                      }

                      final querySnapshot = snapshot.data!;
                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: querySnapshot.docs.length,
                        itemBuilder: (context, index) {
                          final item = querySnapshot.docs[index];

                          double larguraContainer =
                              MediaQuery.of(context).size.width * 0.8;
                          Alignment alinhamento =
                              _idusuarioLogado == item["idUsuario"]
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft;
                          Color cor = _idusuarioLogado == item["idUsuario"]
                              ? Color(0xffd2ffa5)
                              : Colors.white;

                          return Align(
                            alignment: alinhamento,
                            child: Padding(
                              padding: EdgeInsets.all(6),
                              child: Container(
                                width: larguraContainer,
                                decoration: BoxDecoration(
                                  color: cor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                ),
                                child: item["tipo"] == "imagem"
                                    ? Image.network(item["urlImagem"],
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                        return Center(
                                            child: Text(
                                                'Erro ao carregar imagem'));
                                      })
                                    : Text(
                                        item["textoMensagens"],
                                        style: TextStyle(fontSize: 18),
                                      ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                caixaMensagem,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get caixaMensagem {
    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 8),
              child: TextField(
                controller: _controllerMensagem,
                autofocus: true,
                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                  hintText: "Digite uma mensagem...",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  prefixIcon: _subindoImagem
                      ? CircularProgressIndicator()
                      : IconButton(
                          onPressed: _enviarFoto,
                          icon: Icon(Icons.camera_alt),
                        ),
                ),
              ),
            ),
          ),
          FloatingActionButton(
            backgroundColor: Color(0xff075E54),
            child: Icon(
              Icons.send,
              color: Colors.white,
            ),
            mini: true,
            onPressed: _enviarMensagem,
          ),
        ],
      ),
    );
  }
}
