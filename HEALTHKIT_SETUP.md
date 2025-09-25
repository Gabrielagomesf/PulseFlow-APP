# Configuração do HealthKit para PulseFlow

Este documento explica como configurar o HealthKit no projeto PulseFlow para acessar dados de saúde do iPhone.

## ✅ O que já foi configurado

### 1. Dependências
- ✅ Adicionada dependência `health: ^9.0.1` no `pubspec.yaml`
- ✅ HealthService implementado com métodos para acessar dados do HealthKit

### 2. Permissões no Info.plist
- ✅ `NSHealthShareUsageDescription` - Para ler dados de saúde
- ✅ `NSHealthUpdateUsageDescription` - Para salvar dados de saúde

### 3. ProfileController
- ✅ Integração com HealthService real
- ✅ Verificação automática de permissões na inicialização
- ✅ Carregamento de dados reais do HealthKit

## 🔧 Configuração Manual Necessária

### 1. Configurar Capabilities no Xcode

1. **Abra o projeto no Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Selecione o target "Runner"**

3. **Vá para "Signing & Capabilities"**

4. **Adicione HealthKit capability:**
   - Clique em "+ Capability"
   - Procure por "HealthKit"
   - Adicione a capability

5. **Configure as permissões necessárias:**
   - ✅ Health Records (se necessário)
   - ✅ Clinical Health Records (se necessário)

### 2. Verificar Entitlements

O arquivo `ios/Runner/Runner.entitlements` foi criado com as configurações básicas:

```xml
<key>com.apple.developer.healthkit</key>
<true/>
<key>com.apple.developer.healthkit.access</key>
<array>
    <string>health-records</string>
</array>
```

### 3. Configurar no Xcode (Passo a Passo)

1. **Abra o projeto:**
   ```bash
   cd ios
   open Runner.xcworkspace
   ```

2. **Selecione o target Runner**

3. **Vá para "Signing & Capabilities"**

4. **Adicione HealthKit:**
   - Clique em "+ Capability"
   - Digite "HealthKit" e selecione
   - Isso adicionará automaticamente as configurações necessárias

5. **Verifique se aparecem as opções:**
   - Health Records
   - Clinical Health Records (opcional)

## 📱 Testando a Integração

### 1. Executar no Dispositivo Físico
```bash
flutter run --release
```

**⚠️ IMPORTANTE:** HealthKit não funciona no simulador, apenas em dispositivos físicos.

### 2. Verificar Permissões
1. Abra o app no iPhone
2. Vá para a tela de Perfil
3. Clique em "Conectar" no Apple Health
4. Autorize as permissões quando solicitado

### 3. Verificar Dados
Após conceder permissões, o app deve mostrar:
- Frequência cardíaca atual
- Horas de sono
- Passos do dia

## 🔍 Troubleshooting

### Problema: "HealthKit não está disponível"
**Solução:** Execute apenas em dispositivo físico, não no simulador.

### Problema: "Permissões negadas"
**Solução:** 
1. Vá para Configurações > Privacidade e Segurança > Saúde
2. Encontre o PulseFlow
3. Ative as permissões necessárias

### Problema: "Dados não aparecem"
**Solução:**
1. Verifique se o iPhone tem dados no app Saúde
2. Verifique se as permissões foram concedidas
3. Verifique os logs do console para erros

### Problema: "Erro de build"
**Solução:**
1. Execute `flutter clean`
2. Execute `cd ios && pod install`
3. Execute `flutter run`

## 📊 Tipos de Dados Acessados

O app solicita acesso aos seguintes dados:

- **Frequência Cardíaca** (`HealthDataType.HEART_RATE`)
- **Sono** (`HealthDataType.SLEEP_IN_BED`)
- **Passos** (`HealthDataType.STEPS`)

## 🔐 Privacidade

- Todos os dados são processados localmente
- Nenhum dado de saúde é enviado para servidores externos
- As permissões podem ser revogadas a qualquer momento nas configurações do iPhone

## 📝 Logs de Debug

Para verificar se a integração está funcionando, verifique os logs do console:

```
🔐 Solicitando permissões do Apple Health...
📱 Tipos de dados solicitados: [HealthDataType.HEART_RATE, HealthDataType.SLEEP_IN_BED, HealthDataType.STEPS]
🏥 Tentando acessar HealthKit...
✅ Permissões do Apple Health concedidas!
🫀 Buscando dados reais de frequência cardíaca do Apple Health...
📊 Encontrados X pontos de dados de frequência cardíaca
```

## 🚀 Próximos Passos

1. Teste a integração em um dispositivo físico
2. Verifique se os dados estão sendo carregados corretamente
3. Implemente visualizações mais avançadas dos dados de saúde
4. Adicione mais tipos de dados conforme necessário
