# Configuração do Ícone do App PulseFlow

## ✅ O que já foi configurado:

1. **Nome do app alterado para "PulseFlow"** em todos os arquivos:
   - `pubspec.yaml`
   - `lib/main.dart`
   - `android/app/src/main/AndroidManifest.xml`
   - `ios/Runner/Info.plist`

2. **Configuração do flutter_launcher_icons** adicionada ao `pubspec.yaml`

## 🔧 Próximos passos para você:

### 1. Criar a imagem do ícone
- Crie uma imagem PNG de **1024x1024 pixels** com o logo "PF"
- A imagem deve ter fundo transparente ou branco
- Salve como `assets/images/app_icon.png`

### 2. Gerar os ícones automaticamente
Execute os seguintes comandos no terminal:

```bash
# Instalar dependências
flutter pub get

# Gerar ícones para todas as plataformas
flutter pub run flutter_launcher_icons:main
```

### 3. Limpar e reconstruir o app
```bash
# Limpar cache
flutter clean

# Reconstruir o app
flutter run
```

## 📱 Resultado esperado:
- O app aparecerá como "PulseFlow" na tela inicial
- O ícone será o logo "PF" que você criou
- Funcionará em Android, iOS, Web, Windows e macOS

## 🎨 Cores sugeridas para o ícone:
- **P**: Azul escuro (#00324A)
- **F**: Azul claro/ciano (#64B5F6)
- **Fundo**: Branco ou transparente

## ⚠️ Importante:
- A imagem deve ser exatamente 1024x1024 pixels
- Use formato PNG
- Certifique-se de que o contraste está bom para diferentes fundos

