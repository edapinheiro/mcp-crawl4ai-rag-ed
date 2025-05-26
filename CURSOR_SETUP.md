# Configuração do MCP Crawl4AI para Cursor IDE

## Passo a Passo Rápido

### 1. Configuração Inicial
```bash
# Execute o script de setup
./setup_cursor.sh
```

### 2. Configure suas chaves de API
Edite o arquivo `.env`:
```env
OPENAI_API_KEY=sua_chave_openai_aqui
SUPABASE_URL=sua_url_supabase_aqui  
SUPABASE_SERVICE_KEY=sua_chave_supabase_aqui
```

### 3. Configure o Banco de Dados
1. Abra o Supabase SQL Editor
2. Execute o conteúdo do arquivo `crawled_pages.sql`

### 4. Configure o Cursor
O arquivo `.cursor/mcp_settings.json` já está configurado. Se não funcionar, adicione manualmente nas configurações do Cursor:

```json
{
  "mcpServers": {
    "crawl4ai-rag": {
      "command": "uv",
      "args": ["run", "src/crawl4ai_mcp.py"],
      "cwd": "/Users/edpiinheiro/Documents/GitHub/mcp-crawl4ai-rag-ed",
      "env": {
        "TRANSPORT": "stdio"
      }
    }
  }
}
```

## Troubleshooting

### "No tools available"

**Problema**: O Cursor não consegue conectar ao MCP server.

**Soluções**:
1. **Verificar se uv está instalado**:
   ```bash
   uv --version
   ```

2. **Testar o servidor manualmente**:
   ```bash
   cd /Users/edpiinheiro/Documents/GitHub/mcp-crawl4ai-rag-ed
   uv run src/crawl4ai_mcp.py
   ```

3. **Verificar dependências**:
   ```bash
   uv pip install -e .
   crawl4ai-setup
   ```

4. **Verificar arquivo .env**:
   - Confirme que todas as chaves estão preenchidas
   - Teste as chaves no Supabase/OpenAI

5. **Reiniciar o Cursor**:
   - Feche completamente o Cursor
   - Reabra e aguarde a inicialização do MCP

### Logs de Debug

**Ativar logs no Cursor**:
1. `Cmd/Ctrl + Shift + P`
2. "Developer: Reload Window"  
3. Abra o Developer Console (`Cmd/Ctrl + Shift + I`)
4. Procure por erros relacionados a MCP

**Testar conexão direta**:
```bash
# Teste se o servidor responde
echo '{"jsonrpc":"2.0","method":"initialize","id":1,"params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}}' | uv run src/crawl4ai_mcp.py
```

### Problemas Comuns

1. **Erro de caminho**: Confirme que o `cwd` aponta para o diretório correto
2. **Erro de permissão**: Execute `chmod +x setup_cursor.sh`
3. **Python/uv não encontrado**: Instale uv ou use Python diretamente
4. **Timeout**: Aumente o timeout do MCP nas configurações do Cursor

## Alternativa: Docker

Se o setup local não funcionar, use Docker:

```bash
# Build da imagem
docker build -t mcp-crawl4ai .

# Configuração para Cursor com Docker
{
  "mcpServers": {
    "crawl4ai-rag": {
      "command": "docker",
      "args": ["run", "--rm", "-i", 
               "--env-file", ".env",
               "mcp-crawl4ai"],
      "cwd": "/Users/edpiinheiro/Documents/GitHub/mcp-crawl4ai-rag-ed"
    }
  }
}
```

## Verificação Final

Após a configuração, você deve ver nas ferramentas do Cursor:
- `crawl_single_page`
- `smart_crawl_url` 
- `get_available_sources`
- `perform_rag_query`