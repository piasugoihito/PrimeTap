import 'package:flutter/material.dart';
import 'theme.dart';

class DisclaimerScreen extends StatefulWidget {
  const DisclaimerScreen({super.key});

  @override
  State<DisclaimerScreen> createState() => _DisclaimerScreenState();
}

class _DisclaimerScreenState extends State<DisclaimerScreen> {
  String _selectedLanguage = 'Japanese';

  final Map<String, Map<String, String>> _disclaimers = {
    'Japanese': {
      'title': '免責事項および利用規約',
      'content': '''フィクションの明示: 本アプリ「PrimeTap」は娯楽を目的としたフィクションであり、実在の人物、団体、政党、宗教、事件とは一切関係ありません。特定の政治的思想を支持または批判するものではありません。

政治的利用の禁止: ユーザーは、本アプリを特定の政治的思想の宣伝、政治活動、選挙運動、または特定の個人や団体を誹謗中傷する目的で利用することを固く禁止します。

責任制限: 運営（GAME POP）は、本アプリの利用により生じた損害（端末故障、データ消失、金銭的損失等）について、一切の責任を負いません。

サービスの終了: 運営は予告なくサービスを変更または終了する権利を留保します。

準拠法・管轄: 本規約は日本法に準拠します。万一の紛争については、運営の居住地を管轄する地方裁判所を第一審の専属的合意管轄裁判所とします。

言語優先: 翻訳版と日本語版に相違がある場合は、日本語版が優先されます。''',
    },
    'English': {
      'title': 'Disclaimer and Terms of Service',
      'content': '''Fiction: "PrimeTap" is a work of fiction for entertainment purposes. It has no affiliation with any real persons, political parties, or organizations. It does not endorse or criticize any specific political ideology.

Prohibition of Political Use: Users are strictly prohibited from using this app for political propaganda, campaigning, or any activities intended to defame specific individuals or groups.

Limitation of Liability: GAME POP shall not be liable for any damages (device failure, data loss, etc.) arising from the use of this app.

Service Termination: The operator reserves the right to modify or terminate the service without prior notice.

Governing Law: These terms are governed by the laws of Japan. Any disputes shall be subject to the exclusive jurisdiction of the district court in the operator's place of residence.

Priority: In case of discrepancies between translations, the Japanese version shall prevail.''',
    },
    'Chinese': {
      'title': '免责声明及使用条款',
      'content': '''虚构声明: 本应用“PrimeTap”仅为娱乐目的的虚构作品，与任何真实人物、团体、政党、宗教或事件无关。本应用不代表、不支持或批评任何特定政治思想。

禁止政治用途: 严禁用户将本应用用于宣传特定政治思想、政治活动、选举运动，或用于诽谤、抹黑特定个人或团体的行为。

责任限制: 运营方（GAME POP）对因使用本应用而产生的任何损害（设备损坏、数据丢失等）不承担任何责任。

服务终止: 运营方保留无需预告即可修改或终止服务的权利。

适用法律与管轄: 本条款受日本法律管轄。如发生争议，应提交至运营方所在地具有管辖权的地方法院作为第一审专属合意管辖法院。

语言优先: 如翻译版本与日语原文存在差异，以日语原文为准。''',
    },
    'Spanish': {
      'title': 'Descargo de Responsabilidad y Términos de Servicio',
      'content': '''Ficción: "PrimeTap" es una obra de ficción con fines de entretenimiento. No tiene relación con personas, organizaciones, partidos políticos o eventos reales. No apoya ni critica ninguna ideología política específica.

Prohibición de Uso Político: Se prohíbe estrictamente a los usuarios utilizar esta aplicación para propaganda política, campañas electorales o cualquier actividad destinada a difamar a personas o grupos específicos.

Limitación de Responsabilidad: El operador (GAME POP) no será responsable de ningún daño (fallo del dispositivo, pérdida de datos, etc.) derivado del uso de esta aplicación.

Terminación del Servicio: El operador se reserva el derecho de modificar o finalizar el servicio sin previo aviso.

Ley Aplicable: Estos términos se rigen por las leyes de Japón. Cualquier disputa estará sujeta a la jurisdicción exclusiva del tribunal de distrito de la residencia del operador.

Prioridad Lingüística: En caso de discrepancia entre las traducciones, prevalecerá la versión en japonés.''',
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightCyan,
      appBar: AppBar(
        title: Text('Disclaimer', style: AppTheme.glossyTextStyle(color: Colors.cyan[900]!)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.deepCyan),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _disclaimers.keys.map((lang) {
                  bool isSelected = _selectedLanguage == lang;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(lang),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedLanguage = lang);
                      },
                      selectedColor: AppTheme.primaryCyan,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.deepCyan,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(20.0),
              decoration: AppTheme.glossyDecoration(color: Colors.white, borderRadius: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _disclaimers[_selectedLanguage]!['title']!,
                      style: AppTheme.glossyTextStyle(fontSize: 22, color: AppTheme.deepCyan),
                    ),
                    const Divider(height: 30),
                    Text(
                      _disclaimers[_selectedLanguage]!['content']!,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: GlossyButton(
              label: 'Close',
              onTap: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
