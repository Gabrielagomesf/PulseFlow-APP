#!/bin/bash

echo "🔧 Testando build do PulseFlow..."

# Limpa o projeto
echo "🧹 Limpando projeto..."
flutter clean

# Obtém dependências
echo "📦 Obtendo dependências..."
flutter pub get

# Testa o build para iOS
echo "📱 Testando build para iOS..."
flutter build ios --no-codesign

echo "✅ Build testado com sucesso!"

