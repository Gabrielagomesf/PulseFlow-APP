# Salvamento de Dados de Saúde no Banco de Dados

Este documento explica como os dados do HealthKit são salvos no banco de dados MongoDB do PulseFlow.

## ✅ Funcionalidades Implementadas

### 1. **Modelo de Dados**
- **HealthData**: Modelo para armazenar dados de saúde
- Campos: `patientId`, `dataType`, `value`, `date`, `source`, `metadata`
- Suporte a diferentes tipos: `heartRate`, `sleep`, `steps`

### 2. **DatabaseService**
- Métodos CRUD completos para dados de saúde
- `createHealthData()` - Criar dados individuais
- `createMultipleHealthData()` - Criar múltiplos dados (batch)
- `getHealthDataByPatientId()` - Buscar por paciente
- `getHealthDataByType()` - Buscar por tipo
- `getHealthDataByPeriod()` - Buscar por período
- `updateHealthData()` - Atualizar dados
- `deleteHealthData()` - Deletar dados

### 3. **HealthDataService**
- Serviço de alto nível para gerenciar dados de saúde
- `saveHealthDataFromHealthKit()` - Salva dados do HealthKit
- `syncHealthData()` - Sincroniza dados (evita duplicatas)
- `getHealthDataStats()` - Calcula estatísticas
- Métodos para buscar dados por período (hoje, semana, mês)

### 4. **Integração Automática**
- **ProfileController** salva dados automaticamente
- Verificação de permissões antes de salvar
- Fallback para dados do banco se HealthKit não disponível
- Sincronização inteligente (evita duplicatas)

### 5. **Histórico de Dados**
- **HealthHistoryScreen** - Tela completa de histórico
- Gráficos interativos com fl_chart
- Filtros por tipo de dados e período
- Estatísticas detalhadas (média, máximo, mínimo)
- Lista de registros recentes

## 🔄 Como Funciona o Salvamento

### 1. **Fluxo Automático**
```
Usuário conecta ao Apple Health
    ↓
ProfileController verifica permissões
    ↓
HealthService busca dados do HealthKit
    ↓
HealthDataService converte e salva no MongoDB
    ↓
Dados ficam disponíveis no histórico
```

### 2. **Estrutura dos Dados Salvos**
```json
{
  "_id": "ObjectId",
  "patientId": "ID do paciente",
  "dataType": "heartRate|sleep|steps",
  "value": 72.5,
  "date": "2024-01-15T10:30:00Z",
  "source": "HealthKit",
  "metadata": {
    "unit": "bpm",
    "description": "Frequência cardíaca"
  },
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T10:30:00Z"
}
```

### 3. **Tipos de Dados Suportados**

#### **Frequência Cardíaca** (`heartRate`)
- **Unidade**: bpm (batimentos por minuto)
- **Fonte**: Apple Health
- **Frequência**: Múltiplas medições por dia

#### **Sono** (`sleep`)
- **Unidade**: horas
- **Fonte**: Apple Health
- **Frequência**: Uma medição por dia

#### **Passos** (`steps`)
- **Unidade**: passos
- **Fonte**: Apple Health
- **Frequência**: Uma medição por dia

## 📊 Funcionalidades do Histórico

### 1. **Filtros Disponíveis**
- **Tipo de Dados**: Frequência cardíaca, Sono, Passos
- **Período**: 7 dias, 30 dias, 90 dias
- **Fonte**: HealthKit, Manual, Smartwatch

### 2. **Visualizações**
- **Gráfico de Linha**: Evolução temporal dos dados
- **Estatísticas**: Média, máximo, mínimo, contagem
- **Lista de Registros**: Dados detalhados por data

### 3. **Navegação**
- Acesso via botão "Ver Histórico Completo" no perfil
- Rota: `/health-history`
- Transição suave

## 🔐 Segurança e Privacidade

### 1. **Dados Locais**
- Todos os dados são processados localmente no iPhone
- Nenhum dado de saúde é enviado para servidores externos
- Criptografia automática do MongoDB

### 2. **Permissões**
- Usuário deve conceder permissões explicitamente
- Permissões podem ser revogadas a qualquer momento
- App funciona mesmo sem permissões (dados do banco)

### 3. **Controle do Usuário**
- Usuário pode desconectar do Apple Health
- Dados podem ser deletados individualmente
- Histórico completo disponível para revisão

## 🚀 Como Usar

### 1. **Para o Usuário**
1. Vá para a tela de Perfil
2. Clique em "Conectar" no Apple Health
3. Autorize as permissões quando solicitado
4. Os dados são salvos automaticamente
5. Acesse "Ver Histórico Completo" para ver gráficos

### 2. **Para o Desenvolvedor**
```dart
// Salvar dados manualmente
final healthDataService = HealthDataService();
await healthDataService.saveHealthDataFromHealthKit(patientId);

// Buscar dados
final data = await healthDataService.getHealthDataByPatient(patientId);

// Calcular estatísticas
final stats = await healthDataService.getHealthDataStats(patientId, 'heartRate');
```

## 📈 Benefícios

### 1. **Para o Paciente**
- Histórico completo de dados de saúde
- Visualizações claras e intuitivas
- Sincronização automática com Apple Health
- Dados sempre disponíveis (mesmo offline)

### 2. **Para o Médico**
- Acesso a dados históricos do paciente
- Tendências e padrões de saúde
- Dados objetivos e precisos
- Integração com prontuário médico

### 3. **Para o Sistema**
- Dados estruturados e organizados
- Consultas eficientes por período/tipo
- Estatísticas automáticas
- Escalabilidade para grandes volumes

## 🔧 Configuração Técnica

### 1. **Banco de Dados**
- **Coleção**: `health_data`
- **Índices**: `patientId`, `dataType`, `date`
- **Tamanho**: ~1KB por registro

### 2. **Performance**
- Batch insert para múltiplos dados
- Consultas otimizadas por período
- Cache local para dados recentes

### 3. **Monitoramento**
- Logs detalhados de operações
- Métricas de sincronização
- Alertas de falhas

## 🎯 Próximos Passos

1. **Integração com Prontuário**
   - Associar dados de saúde a consultas
   - Alertas baseados em tendências
   - Relatórios automáticos

2. **Mais Tipos de Dados**
   - Pressão arterial
   - Glicemia
   - Peso
   - Atividade física

3. **Análise Avançada**
   - IA para detectar padrões
   - Previsões de saúde
   - Recomendações personalizadas

4. **Integração com Dispositivos**
   - Smartwatches
   - Balanças inteligentes
   - Monitores de glicemia

## 📝 Logs e Debug

Para verificar se o salvamento está funcionando:

```
💾 Salvando dados do HealthKit no banco de dados...
✅ 21 dados de saúde salvos no banco de dados
📊 Carregando dados de saúde do banco de dados...
✅ Dados de saúde carregados do banco: FC=72.0, Sono=85.0, Passos=8500
```

## ❓ Troubleshooting

### Problema: Dados não são salvos
**Solução**: Verificar conexão com MongoDB e permissões do HealthKit

### Problema: Dados duplicados
**Solução**: Usar `syncHealthData()` em vez de `saveHealthDataFromHealthKit()`

### Problema: Histórico vazio
**Solução**: Verificar se há dados no banco e se as consultas estão corretas

### Problema: Performance lenta
**Solução**: Implementar paginação e cache para grandes volumes de dados
