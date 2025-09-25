# Diagnóstico de Dados de Saúde - PulseFlow

## 🔍 Problema Identificado

**Situação:** Permissões do HealthKit são concedidas, mas dados não são salvos no banco.

## 🛠️ Ferramentas de Diagnóstico Implementadas

### 1. **Logs Detalhados**
- ✅ Logs adicionados ao `HealthDataService`
- ✅ Logs de conexão com banco
- ✅ Logs de processamento de dados
- ✅ Logs de salvamento

### 2. **Serviço de Teste**
- ✅ `HealthDataTestService` criado
- ✅ Teste de conexão com banco
- ✅ Teste de criação de dados
- ✅ Teste de busca de dados

### 3. **Botão de Teste**
- ✅ Botão "Testar" na tela de perfil
- ✅ Executa todos os testes automaticamente
- ✅ Mostra resultados na interface

## 🔧 Como Diagnosticar

### **Passo 1: Executar Teste**
1. Abra o app no iPhone
2. Vá para a tela de Perfil
3. Conecte ao Apple Health
4. Clique no botão **"Testar"**
5. Verifique os logs no console

### **Passo 2: Verificar Logs**
Procure por estas mensagens no console:

```
🔧 Testando conexão com o banco de dados...
✅ Conexão com banco de dados OK
🧪 Testando criação de dados de saúde...
📝 Criando dado de teste: {...}
✅ Dado de teste criado com sucesso: ObjectId(...)
🔍 Testando busca de dados de saúde...
📊 Dados encontrados: X
```

### **Passo 3: Verificar Problemas Comuns**

#### **A. Problema de Conexão com Banco**
```
❌ Erro na conexão com banco de dados: ...
```
**Solução:** Verificar string de conexão MongoDB

#### **B. Problema de Permissões**
```
❌ Sem permissões do HealthKit
```
**Solução:** Reautorizar permissões nas Configurações do iPhone

#### **C. Problema de Dados Vazios**
```
⚠️ Nenhum dado de saúde encontrado para salvar
```
**Solução:** Verificar se há dados no app Saúde do iPhone

#### **D. Problema de Salvamento**
```
❌ Erro ao salvar dados de saúde: ...
```
**Solução:** Verificar configuração do banco de dados

## 📊 Verificações Necessárias

### 1. **Banco de Dados MongoDB**

#### **Verificar String de Conexão:**
```dart
// Em lib/config/database_config.dart
static String get connectionString {
  // Verificar se MONGODB_URI está configurada no .env
  // Ou se está usando a configuração padrão
}
```

#### **Verificar Conexão:**
- MongoDB está rodando?
- String de conexão está correta?
- Permissões de acesso estão OK?

### 2. **HealthKit**

#### **Verificar Permissões:**
- Configurações > Privacidade e Segurança > Saúde
- Encontrar "PulseFlow"
- Verificar se está ativado

#### **Verificar Dados:**
- Abrir app "Saúde" do iPhone
- Verificar se há dados de frequência cardíaca, sono, passos
- Se não há dados, o HealthKit não tem nada para retornar

### 3. **Configuração do iOS**

#### **Verificar Info.plist:**
```xml
<key>NSHealthShareUsageDescription</key>
<string>Este app precisa acessar seus dados de saúde...</string>
```

#### **Verificar Entitlements:**
```xml
<key>com.apple.developer.healthkit</key>
<true/>
```

## 🚨 Problemas Comuns e Soluções

### **Problema 1: Banco de Dados Não Conecta**
```
❌ Falha ao conectar após 3 tentativas: ...
```
**Solução:**
1. Verificar se MongoDB está rodando
2. Verificar string de conexão
3. Verificar firewall/rede

### **Problema 2: HealthKit Sem Dados**
```
⚠️ Nenhum dado de saúde encontrado para salvar
```
**Solução:**
1. Verificar se há dados no app Saúde
2. Adicionar dados manualmente no app Saúde
3. Aguardar sincronização com Apple Watch

### **Problema 3: Permissões Negadas**
```
❌ Sem permissões do HealthKit
```
**Solução:**
1. Ir em Configurações > Saúde
2. Encontrar PulseFlow
3. Ativar todas as permissões

### **Problema 4: Erro de Salvamento**
```
❌ Erro ao salvar dados de saúde: ...
```
**Solução:**
1. Verificar logs detalhados
2. Verificar estrutura do banco
3. Verificar permissões de escrita

## 📱 Teste Manual

### **1. Teste de Conexão:**
```bash
# No terminal, testar conexão MongoDB
mongosh "sua_string_de_conexao"
```

### **2. Teste de Dados:**
- Abrir app Saúde do iPhone
- Adicionar dados manualmente
- Verificar se aparecem na interface

### **3. Teste de Permissões:**
- Revogar permissões do PulseFlow
- Reautorizar permissões
- Verificar se dados são carregados

## 🔧 Configuração do Banco

### **Se Usando MongoDB Local:**
```bash
# Instalar MongoDB
brew install mongodb-community

# Iniciar MongoDB
brew services start mongodb-community

# Verificar se está rodando
mongosh
```

### **Se Usando MongoDB Atlas:**
1. Verificar string de conexão
2. Verificar IPs permitidos
3. Verificar usuário e senha
4. Verificar cluster ativo

## 📋 Checklist de Verificação

- [ ] MongoDB está rodando
- [ ] String de conexão está correta
- [ ] Permissões do HealthKit estão ativas
- [ ] Há dados no app Saúde do iPhone
- [ ] App tem permissões de rede
- [ ] Configuração do iOS está correta
- [ ] Logs mostram erros específicos

## 🎯 Próximos Passos

1. **Executar teste** usando o botão "Testar"
2. **Verificar logs** no console
3. **Identificar problema** específico
4. **Aplicar solução** correspondente
5. **Testar novamente** até funcionar

## 📞 Suporte

Se o problema persistir:
1. Copiar logs completos
2. Verificar configuração do banco
3. Testar em dispositivo diferente
4. Verificar versões das dependências
