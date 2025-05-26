#!/bin/bash

# Configurar logging
LOG_FILE="setup_cursor.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "🚀 Configurando MCP Crawl4AI para Cursor IDE..."
echo "📄 Log sendo salvo em: $LOG_FILE"
echo "⏰ Iniciado em: $(date)"
echo "===========================================" 

# Verificar se uv está instalado
echo "🔍 Verificando instalação do uv..."

# Adicionar possíveis caminhos do uv ao PATH
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

if ! command -v uv &> /dev/null; then
    echo "❌ uv não encontrado. Instalando..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    
    # Recarregar o PATH após instalação
    export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
    
    # Aguardar um momento para a instalação finalizar
    sleep 2
    
    if command -v uv &> /dev/null; then
        echo "✅ uv instalado com sucesso!"
        echo "📍 uv encontrado em: $(which uv)"
        uv --version
    else
        echo "❌ Falha na instalação do uv"
        echo "🔍 Tentando localizar uv..."
        find $HOME -name "uv" -type f 2>/dev/null | head -5
        echo "💡 Tente executar: export PATH=\"\$HOME/.local/bin:\$PATH\" && ./setup_cursor.sh"
        exit 1
    fi
else
    echo "✅ uv encontrado!"
    echo "📍 uv localizado em: $(which uv)"
    uv --version
fi

# Verificar se o arquivo .env existe
echo "🔍 Verificando arquivo .env..."
if [ ! -f .env ]; then
    echo "❌ Arquivo .env não encontrado. Por favor, configure suas chaves de API:"
    echo "OPENAI_API_KEY=your_key_here"
    echo "SUPABASE_URL=your_url_here" 
    echo "SUPABASE_SERVICE_KEY=your_key_here"
    exit 1
else
    echo "✅ Arquivo .env encontrado!"
    echo "📋 Configurações encontradas:"
    grep -E "^[A-Z_]+=.+" .env | sed 's/=.*/=***/' || echo "Nenhuma configuração válida encontrada"
fi

echo "📦 Configurando ambiente virtual..."
if [ ! -d ".venv" ]; then
    echo "🔨 Criando ambiente virtual..."
    if uv venv; then
        echo "✅ Ambiente virtual criado!"
    else
        echo "❌ Erro ao criar ambiente virtual"
        exit 1
    fi
else
    echo "✅ Ambiente virtual já existe!"
fi

echo "📦 Instalando dependências..."
if uv pip install -e .; then
    echo "✅ Dependências instaladas com sucesso!"
else
    echo "❌ Erro ao instalar dependências"
    exit 1
fi

echo "🕷️ Configurando Crawl4AI..."
if uv run crawl4ai-setup; then
    echo "✅ Crawl4AI configurado com sucesso!"
else
    echo "❌ Erro ao configurar Crawl4AI"
    exit 1
fi

echo "🧪 Testando o servidor MCP..."
echo "🚀 Iniciando servidor de teste..."

# Testar o servidor de forma mais robusta (macOS compatível)
uv run src/crawl4ai_mcp.py &
MCP_PID=$!

echo "🔄 Aguardando inicialização do servidor (PID: $MCP_PID)..."
sleep 3

if ps -p $MCP_PID > /dev/null; then
    echo "✅ Servidor MCP está funcionando!"
    echo "🛑 Parando servidor de teste..."
    kill $MCP_PID
    wait $MCP_PID 2>/dev/null
    echo "✅ Servidor de teste parado com sucesso!"
else
    echo "❌ Erro ao iniciar o servidor MCP. Verifique as configurações."
    echo "🔍 Verificando logs de erro..."
    wait $MCP_PID 2>/dev/null
    echo "💡 Dica: Verifique se as chaves de API estão corretas no arquivo .env"
    exit 1
fi

echo "==========================================="
echo "🎯 Configuração concluída com sucesso!"
echo "⏰ Finalizado em: $(date)"
echo "📝 Próximos passos:"
echo "1. ✅ Dependências instaladas"
echo "2. ✅ Crawl4AI configurado" 
echo "3. ✅ Servidor MCP testado"
echo "4. 🔄 Execute o SQL em crawled_pages.sql no seu Supabase"
echo "5. 🔄 Reinicie o Cursor IDE"
echo "6. 🔄 Verifique se o MCP aparece nas ferramentas disponíveis"
echo ""
echo "📄 Log completo salvo em: $LOG_FILE"
echo "🆘 Se houver problemas, consulte CURSOR_SETUP.md"