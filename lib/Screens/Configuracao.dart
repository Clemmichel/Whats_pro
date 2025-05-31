import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Configuracoes extends StatefulWidget {
  const Configuracoes({super.key});

  @override
  State<Configuracoes> createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes> {
  TextEditingController _controllerNome = TextEditingController();
  File? imagemSelecionada;
  String? imagemUrl;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  Future<void> _carregarDadosUsuario() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        print('Documento encontrado: ${doc.data()}');
        var data = doc.data() as Map<String, dynamic>?;

        setState(() {
          imagemUrl = data?['urlImagem'] ?? '';
          _controllerNome.text = data?['nome'] ?? '';
        });
      } else {
        print('Documento não encontrado.');
      }
    } else {
      print('Usuário não autenticado.');
    }
    print("Imagem carregada do Firestore: $imagemUrl");
  }

  Future<void> _recuperarImagem(String origemImagem) async {
    final picker = ImagePicker();
    final XFile? xFile = await picker.pickImage(
        source: origemImagem == "Camera"
            ? ImageSource.camera
            : ImageSource.gallery);

    if (xFile != null) {
      setState(() {
        imagemSelecionada = File(xFile.path);
      });
    }
  }

  Future<void> _uploadImagem() async {
    if (imagemSelecionada == null) {
      await _atualizarNome();
      _navegarParaHome();
      return;
    }

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref();
    Reference arquivo = pastaRaiz
        .child("perfil")
        .child(DateTime.now().millisecondsSinceEpoch.toString() + ".jpg");

    try {
      UploadTask uploadTask = arquivo.putFile(imagemSelecionada!);
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();
      print("Imagem carregada com sucesso. URL: $downloadUrl");

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .set({
          'urlImagem': downloadUrl,
          'nome': _controllerNome.text,
        }, SetOptions(merge: true));

        setState(() {
          imagemUrl = downloadUrl;
        });

        _navegarParaHome();
      }
    } catch (e) {
      print('Erro ao fazer upload: $e');
    }
      _showSucessoDialog() {

}

  }

  Future<void> _atualizarNome() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .set({
        'nome': _controllerNome.text,
      }, SetOptions(merge: true));
    }
  }

  void _navegarParaHome() {
    Navigator.pushNamed(context, "/home");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configurações"),
        foregroundColor: Colors.white,
        backgroundColor: Color(0xff075E54),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                CircleAvatar(
  radius: 100,
  backgroundImage: imagemSelecionada != null
      ? FileImage(imagemSelecionada!)
      : (imagemUrl != null && imagemUrl!.isNotEmpty
          ? NetworkImage(imagemUrl!)
          : null),
  backgroundColor: Colors.grey,
  child: imagemSelecionada == null && (imagemUrl == null || imagemUrl!.isEmpty)
      ? Icon(Icons.camera_alt, size: 50, color: Colors.white)
      : null,
),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _recuperarImagem("Camera");
                      },
                      child: Text("Camera"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        _recuperarImagem("Galeria");
                      },
                      child: Text("Galeria"),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerNome,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Nome",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () {
                      _uploadImagem();
                    },
                    child: Text(
                      "Salvar",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
