#!/bin/bash

echo "🔍 Diagnóstico MCP para Cursor IDE"
echo "=================================="

# Verificar se uv está acessível
echo "1. Verificando uv..."
if command -v /Users/edpiinheiro/.local/bin/uv &> /dev/null; then
    echo "✅ uv encontrado: $(/Users/edpiinheiro/.local/bin/uv --version)"
else
    echo "❌ uv não encontrado no caminho absoluto"
    exit 1
fi

# Verificar se o projeto existe
echo "2. Verificando projeto..."
if [ -f "src/crawl4ai_mcp.py" ]; then
    echo "✅ Arquivo MCP encontrado"
else
    echo "❌ Arquivo src/crawl4ai_mcp.py não encontrado"
    exit 1
fi

# Verificar se .env existe
echo "3. Verificando configuração..."
if [ -f ".env" ]; then
    echo "✅ Arquivo .env encontrado"
    echo "📋 Variáveis configuradas:"
    grep -E "^[A-Z_]+=.+" .env | sed 's/=.*/=***/'
else
    echo "❌ Arquivo .env não encontrado"
    exit 1
fi

# Testar servidor MCP
echo "4. Testando servidor MCP..."
echo "🚀 Iniciando teste do servidor..."

# Executar servidor em background e capturar PID
echo '{"jsonrpc":"2.0","method":"initialize","id":1,"params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}}' | /Users/edpiinheiro/.local/bin/uv run src/crawl4ai_mcp.py > /tmp/mcp_test.json 2>&1 &
MCP_PID=$!

# Aguardar alguns segundos
sleep 3

# Verificar se o processo ainda está rodando e matar se necessário
if ps -p $MCP_PID > /dev/null 2>&1; then
    kill $MCP_PID 2>/dev/null
    wait $MCP_PID 2>/dev/null
fi

# Verificar resultado
if [ -f "/tmp/mcp_test.json" ] && [ -s "/tmp/mcp_test.json" ]; then
    if grep -q "protocolVersion" /tmp/mcp_test.json; then
        echo "✅ Servidor MCP respondeu corretamente"
        echo "✅ Resposta MCP válida"
    else
        echo "⚠️ Resposta inesperada:"
        cat /tmp/mcp_test.json
    fi
else
    echo "❌ Servidor MCP não respondeu ou arquivo vazio"
    if [ -f "/tmp/mcp_test.json" ]; then
        echo "Conteúdo do arquivo:"
        cat /tmp/mcp_test.json
    fi
fi

# Verificar configuração do Cursor
echo "5. Verificando configuração do Cursor..."
if [ -f ".cursor/mcp_settings.json" ]; then
    echo "✅ Configuração do Cursor encontrada"
    echo "📋 Configuração atual:"
    cat .cursor/mcp_settings.json | jq '.' 2>/dev/null || cat .cursor/mcp_settings.json
else
    echo "❌ Arquivo .cursor/mcp_settings.json não encontrado"
fi

echo ""
echo "🎯 Diagnóstico concluído!"
echo "📝 Próximos passos:"
echo "1. Reinicie o Cursor IDE completamente"
echo "2. Abra o projeto no Cursor"
echo "3. Aguarde alguns segundos para o MCP inicializar"
echo "4. Teste perguntando: 'Quais ferramentas estão disponíveis?'"
echo ""
echo "🆘 Se ainda não funcionar:"
echo "- Verifique logs do Cursor (Developer Tools > Console)"
echo "- Verifique se não há outro processo usando as ferramentas MCP"

# Limpar arquivo temporário
rm -f /tmp/mcp_test.json