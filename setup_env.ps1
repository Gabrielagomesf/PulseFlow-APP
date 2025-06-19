# Script para configurar o arquivo .env
Write-Host "Configurando arquivo .env..." -ForegroundColor Green

$envContent = @"
# MongoDB Atlas Connection String
MONGODB_URI=mongodb+srv://pulseflow:projetointegrador@pulseflow.uesi5bb.mongodb.net/?retryWrites=true&w=majority

# Configurações JWT
JWT_SECRET=sua_chave_secreta_jwt_aqui_2024

# Configurações de E-mail (Gmail)
EMAIL_USER=goomes.016@gmail.com
EMAIL_PASS=gpoe ovit bjgs zesn

# Configurações da API
API_BASE_URL=http://localhost:3000/api
"@

$envContent | Out-File -FilePath ".env" -Encoding UTF8
Write-Host "Arquivo .env criado com sucesso!" -ForegroundColor Green
Write-Host "EMAIL_USER configurado como: goomes.016@gmail.com" -ForegroundColor Yellow 