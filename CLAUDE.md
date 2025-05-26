# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Crawl4AI RAG MCP (Model Context Protocol) server that provides web crawling and Retrieval Augmented Generation capabilities for AI agents and coding assistants. The server integrates Crawl4AI web scraping with Supabase vector database storage and OpenAI embeddings.

## Architecture

- **Main Server**: `src/crawl4ai_mcp.py` - FastMCP server with four main tools for crawling and RAG
- **Utilities**: `src/utils.py` - Helper functions for Supabase operations, embeddings, and document processing
- **Database**: PostgreSQL with pgvector extension via Supabase
- **Dependencies**: Uses uv for Python package management

### Key Components

- **Crawling Engine**: AsyncWebCrawler from Crawl4AI with smart URL detection (sitemaps, text files, regular pages)
- **Content Processing**: Smart chunking by headers/paragraphs, contextual embeddings (optional)
- **Vector Storage**: Supabase with OpenAI text-embedding-3-small model
- **Transport**: Supports both SSE and stdio for MCP communication

## Development Commands

### Setup
```bash
# Install dependencies
uv pip install -e .
crawl4ai-setup

# Create virtual environment
uv venv
source .venv/bin/activate  # macOS/Linux
# .venv\Scripts\activate   # Windows
```

### Running the Server
```bash
# Direct Python execution
uv run src/crawl4ai_mcp.py

# Docker build and run
docker build -t mcp/crawl4ai-rag --build-arg PORT=8051 .
docker run --env-file .env -p 8051:8051 mcp/crawl4ai-rag

# Docker Compose
docker-compose up --build
```

### Database Setup
Execute `crawled_pages.sql` in Supabase SQL Editor to create required tables and pgvector functions.

## Environment Configuration

Required variables in `.env`:
- `OPENAI_API_KEY` - OpenAI API key for embeddings
- `SUPABASE_URL` - Supabase project URL
- `SUPABASE_SERVICE_KEY` - Supabase service role key
- `HOST` - Server host (default: 0.0.0.0)
- `PORT` - Server port (default: 8051)
- `TRANSPORT` - sse or stdio (default: sse)
- `MODEL_CHOICE` - Optional for contextual embeddings

## MCP Tools

1. **crawl_single_page** - Crawl single URL and store in vector DB
2. **smart_crawl_url** - Auto-detect URL type (sitemap/txt/webpage) and crawl accordingly  
3. **get_available_sources** - List all crawled domains for filtering
4. **perform_rag_query** - Semantic search with optional source filtering

## Code Patterns

- Use `@mcp.tool()` decorator for new MCP tools
- Chunking via `smart_chunk_markdown()` respects code blocks and headers
- Batch embedding creation for efficiency (`create_embeddings_batch()`)
- Parallel crawling with `MemoryAdaptiveDispatcher`
- Contextual embeddings when `MODEL_CHOICE` is set