import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  try {
    await dotenv.load(fileName: ".env");
    
    print('🔧 Testando conexão com MongoDB...');
    
    final uri = dotenv.env['MONGODB_URI'] ?? 'mongodb://localhost:27017/paciente_app';
    print('📡 URI do MongoDB: $uri');
    
    final db = await Db.create(uri);
    await db.open();
    
    print('✅ Conexão estabelecida com sucesso!');
    
    // Testar operações básicas
    final collection = db.collection('patients');
    
    // Contar documentos
    final count = await collection.count();
    print('📊 Número de pacientes no banco: $count');
    
    // Listar coleções
    final collections = await db.getCollectionNames();
    print('📁 Coleções disponíveis: $collections');
    
    await db.close();
    print('🔒 Conexão fechada');
    
  } catch (e) {
    print('❌ Erro na conexão: $e');
  }
} 