import 'package:flutter/material.dart';

class EditarPerfilView extends StatefulWidget {
  const EditarPerfilView({super.key});

  @override
  State<EditarPerfilView> createState() =>
      _EditarPerfilViewState();
}

class _EditarPerfilViewState
    extends State<EditarPerfilView> {

  final TextEditingController _nomeController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _telefoneController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    // Dados iniciais
    _nomeController.text = 'Patricia';
    _emailController.text =
        'pattystore43@email.com';
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
        borderRadius:
            BorderRadius.circular(15),
      ),
      contentPadding:
          const EdgeInsets.symmetric(
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

                const CircleAvatar(
                  radius: 55,
                  backgroundColor:
                      Color(0xFFE8EAF6),

                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.deepPurple,
                  ),
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
                      onPressed: () {
                        // Futuro:
                        // trocar foto
                      },
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

            const SizedBox(height: 20),

            TextField(
              controller: _emailController,
              decoration: campo(
                'E-mail',
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _telefoneController,
              keyboardType:
                  TextInputType.phone,
              decoration: campo(
                'Telefone (Opcional)',
              ),
            ),

            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed: () {

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Perfil atualizado com sucesso!',
                      ),
                    ),
                  );

                  Navigator.pop(context);
                },

                style:
                    ElevatedButton.styleFrom(
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      30,
                    ),
                  ),

                  backgroundColor:
                      const Color(
                    0xFF1E88E5,
                  ),
                ),

                child: const Text(
                  'SALVAR ALTERAÇÕES',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.bold,
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
}