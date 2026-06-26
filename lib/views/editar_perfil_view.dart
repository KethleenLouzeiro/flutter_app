import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class EditarPerfilView extends StatefulWidget {
  const EditarPerfilView({super.key});

  @override
  State<EditarPerfilView> createState() => _EditarPerfilViewState();
}

class _EditarPerfilViewState extends State<EditarPerfilView> {
  final TextEditingController _nomeController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _telefoneController = TextEditingController();

  File? _imagemPerfil;

  String? _caminhoImagem;

  Color corSelecionada = Colors.deepPurple;

  Future<void> _selecionarFoto() async {
    final ImagePicker picker = ImagePicker();

    final XFile? imagem = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (imagem == null) return;

    setState(() {
      _imagemPerfil = File(imagem.path);
      _caminhoImagem = imagem.path;
    });
  }

  @override
  void initState() {
    super.initState();

    // Dados iniciais
    _nomeController.text = ' ';
    _emailController.text = ' ';
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  InputDecoration campo(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        title: const Text(
          'Editar Perfil',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: const Color(0xFFE8EAF6),
                  backgroundImage:
                      _imagemPerfil != null ? FileImage(_imagemPerfil!) : null,
                  child: _imagemPerfil == null
                      ? const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.deepPurple,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    child: IconButton(
                      onPressed: _selecionarFoto,
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _nomeController,
              decoration: campo(
                'Nome Completo',
              ),
            ),
            const SizedBox(height: 25),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Cor do Perfil',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildColorOption(Colors.deepPurple),
                _buildColorOption(Colors.blue),
                _buildColorOption(Colors.green),
                _buildColorOption(Colors.orange),
                _buildColorOption(Colors.black),
              ],
            ),
            const SizedBox(height: 25),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();

                  await prefs.setString(
                    'nome_usuario',
                    _nomeController.text,
                  );
                  if (_caminhoImagem != null) {
                    await prefs.setString(
                      'foto_usuario',
                      _caminhoImagem!,
                    );
                  }
                  await prefs.setInt(
                    'cor_perfil',
                    corSelecionada.toARGB32(),
                  );

                  print('SALVOU: ${_nomeController.text}');

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Perfil atualizado com sucesso!',
                      ),
                    ),
                  );

                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      30,
                    ),
                  ),
                  backgroundColor: const Color(
                    0xFF1E88E5,
                  ),
                ),
                child: const Text(
                  'SALVAR ALTERAÇÕES',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(Color cor) {
    return GestureDetector(
      onTap: () {
        setState(() {
          corSelecionada = cor;
        });
      },
      child: CircleAvatar(
        radius: 18,
        backgroundColor: cor,
        child: corSelecionada == cor
            ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 18,
              )
            : null,
      ),
    );
  }
}
