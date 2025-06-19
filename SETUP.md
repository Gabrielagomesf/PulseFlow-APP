# 🚀 Configuração do PulseFlow Saúde

## 📋 Pré-requisitos

1. **Flutter SDK** (versão 3.0.0 ou superior)
2. **Dart SDK** (versão 3.0.0 ou superior)
3. **MongoDB** (local ou na nuvem)
4. **Conta Gmail** (para envio de e-mails 2FA)

## ⚙️ Configuração Inicial

### 1. Instalar Flutter
```bash
# Windows
# Baixe o Flutter SDK de: https://flutter.dev/docs/get-started/install/windows
# Adicione o caminho do Flutter ao PATH do sistema

# Verificar instalação
flutter doctor
```

### 2. Configurar Variáveis de Ambiente
Crie um arquivo `.env` na raiz do projeto:

```env
# Configurações do Banco de Dados MongoDB
MONGODB_URI=mongodb://localhost:27017/paciente_app

# Configurações JWT
JWT_SECRET=sua_chave_secreta_jwt_aqui_2024

# Configurações de E-mail (Gmail)
EMAIL_USER=seu_email@gmail.com
EMAIL_PASS=sua_senha_de_app

# Configurações da API
API_BASE_URL=http://localhost:3000/api
```

### 3. Configurar Gmail para E-mails 2FA
1. Ative a verificação em duas etapas na sua conta Google
2. Gere uma senha de app específica para o Flutter
3. Use essa senha no campo `EMAIL_PASS` do arquivo `.env`

### 4. Instalar Dependências
```bash
flutter pub get
```

## 🔧 Solução de Problemas

### Problema: "flutter não é reconhecido"
**Solução**: Adicione o Flutter ao PATH do sistema
```bash
# Windows - Adicione ao PATH:
C:\flutter\bin
```

### Problema: Erro de overflow no login
**Solução**: ✅ Já corrigido - Layout reorganizado com SafeArea

### Problema: Botão de cadastro não aparece
**Solução**: ✅ Já corrigido - Botão adicionado na tela de login

### Problema: Validações muito restritivas
**Solução**: ✅ Já corrigido - Validações ajustadas para serem mais flexíveis

### Problema: Erro de conexão com MongoDB
**Solução**: 
1. Verifique se o MongoDB está rodando
2. Confirme a URI no arquivo `.env`
3. Teste a conexão: `mongodb://localhost:27017`

### Problema: E-mails 2FA não são enviados
**Solução**:
1. Verifique as credenciais do Gmail no `.env`
2. Confirme se a verificação em duas etapas está ativa
3. Use uma senha de app, não a senha normal

## 🏃‍♂️ Como Executar

### Desenvolvimento
```bash
flutter run
```

### Build para Produção
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## 📱 Funcionalidades

### ✅ Login
- Autenticação com e-mail e senha
- Verificação em duas etapas (2FA)
- Lembrar-me
- Navegação para cadastro

### ✅ Cadastro
- Formulário completo de paciente
- Validações em tempo real
- Busca automática de CEP
- Seleção múltipla de alergias e doenças
- Termos e condições

### ✅ Segurança
- Senhas criptografadas
- Tokens JWT
- Verificação 2FA por e-mail
- Armazenamento seguro

## 🐛 Debug

### Logs do App
```bash
flutter logs
```

### Análise de Código
```bash
flutter analyze
```

### Testes
```bash
flutter test
```

## 📞 Suporte

Se encontrar problemas:
1. Verifique este arquivo SETUP.md
2. Consulte a documentação do Flutter
3. Abra uma issue no repositório

## 🔄 Atualizações

Para atualizar o projeto:
```bash
git pull origin main
flutter pub get
flutter clean
flutter run
``` 