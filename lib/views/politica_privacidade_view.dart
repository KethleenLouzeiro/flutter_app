import 'package:flutter/material.dart';

class PoliticaPrivacidadeView extends StatelessWidget {
  const PoliticaPrivacidadeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Política de Privacidade'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Termos e Condições',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 20),

            Text(
              'Esta Política de Privacidade descreve como o ViageBem coleta, utiliza e protege as informações dos usuários, em conformidade com a Lei Geral de Proteção de Dados (LGPD - Lei nº 13.709/2018).',
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
              ),
            ),

            SizedBox(height: 30),

            Text(
              '📋 Coleta de Dados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 10),

            Text(
              'O ViageBem poderá coletar informações necessárias para o funcionamento do aplicativo, como nome, endereço de e-mail, localização e preferências do usuário, sempre respeitando a legislação vigente.',
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
              ),
            ),

            SizedBox(height: 25),

            Text(
              '📍 Uso da Localização',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 10),

            Text(
              'A localização poderá ser utilizada para exibir pontos turísticos, hospitais, hotéis, restaurantes, postos de combustível, mercados, farmácias, portos e demais serviços próximos ao usuário.',
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
              ),
            ),

            SizedBox(height: 25),

            Text(
              '🔒 Segurança das Informações',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 10),

            Text(
              'O ViageBem adota medidas técnicas e organizacionais para proteger os dados dos usuários contra acessos não autorizados, perda, alteração ou divulgação indevida.',
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
              ),
            ),

            SizedBox(height: 25),

            Text(
              '👤 Direitos do Usuário',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 10),

            Text(
              'Nos termos da LGPD, o usuário poderá solicitar informações sobre seus dados pessoais, bem como correção, atualização ou exclusão dos dados armazenados, quando aplicável.',
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
              ),
            ),

            SizedBox(height: 25),

            Text(
              '🚫 Compartilhamento de Dados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 10),

            Text(
              'O ViageBem não comercializa informações pessoais dos usuários. Os dados poderão ser compartilhados apenas quando necessário para o funcionamento do aplicativo ou para cumprimento de obrigações legais.',
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
              ),
            ),

            SizedBox(height: 25),

            Text(
              '🔄 Atualizações da Política',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 10),

            Text(
              'Esta Política de Privacidade poderá ser atualizada periodicamente para refletir melhorias do aplicativo, alterações legais ou inclusão de novos recursos.',
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
              ),
            ),

            SizedBox(height: 25),

            Text(
              '📧 Contato',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 10),

            Text(
              'Em caso de dúvidas sobre privacidade, segurança ou tratamento de dados, entre em contato pelo e-mail:',
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
              ),
            ),

            SizedBox(height: 10),

            SelectableText(
              'eqviagebemoficial@gmail.com',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}