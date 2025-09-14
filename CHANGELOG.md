# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2025-09-14

### 🗂️ Organização
- 📁 Reestruturação completa do projeto
- 📋 Separação clara: `scripts/`, `examples/`, `tests/`, `docs/`
- 📚 Documentação modular e navegável
- 🧹 Remoção de licença (projeto interno)

### 🔧 Melhorias
- ✨ Pasta `examples/` com casos de uso práticos
- 📖 Índice de documentação em `docs/README.md`
- 🧪 Scripts de demonstração organizados em `tests/`
- 🎯 Estrutura seguindo melhores práticas

### 📁 Nova Estrutura
```
aprovadores/
├── action.yml
├── scripts/           # Código de produção
├── examples/          # Exemplos práticos
├── tests/            # Demos e testes
├── docs/             # Documentação detalhada
└── README.md         # Documentação principal
```

## [1.1.0] - 2025-09-13

### 🚀 Adicionado
- ✨ Suporte a múltiplas organizações (multi-org)
- 🔍 Detecção dinâmica de branch protection rules
- 📋 Busca automática de organization rulesets
- ⚙️ Inputs configuráveis para aprovações por tipo de branch
- 🎯 Padrões de skip de branches customizáveis
- 📚 Documentação específica para multi-org (MULTI-ORG.md)

### 🔧 Modificado
- 🏗️ Refatoração completa da função `get_ruleset_id()` → `get_branch_protection_rules()`
- 🔄 Estratégia hierárquica de detecção de regras
- 📈 Melhoria na flexibilidade de configuração
- 🛡️ Tratamento robusto de falhas de API

### 🐛 Corrigido
- ❌ Ruleset IDs hardcoded que causavam falhas em outras organizações
- 🔒 Dependência específica de uma organização
- ⚡ Problemas de compatibilidade entre organizações

### 💥 Breaking Changes
- 🔄 Remoção de ruleset IDs hardcoded
- 📝 Novos inputs opcionais (mantém compatibilidade)

### 🎯 Funcionalidades
- Detecção automática de regras por branch protection
- Fallback inteligente usando organization rulesets
- Configuração customizável via inputs
- Suporte a skip patterns para branches especiais
- Compatibilidade total com organizações múltiplas

## [1.0.0] - 2025-09-12

### Adicionado
- ✨ Action inicial para verificação de aprovadores de PR
- 🔍 Suporte a verificação baseada em CODEOWNERS
- 🎯 Rulesets específicos por branch (main, develop, feature)
- 📊 Outputs detalhados (approved-count, required-count, status)
- 🎨 Logs coloridos e informativos
- 📚 Documentação completa com exemplos
- ✅ Testes básicos de sintaxe

### Recursos
- Verifica aprovações de PRs contra teams do CODEOWNERS
- Suporte a diferentes rulesets por tipo de branch
- Performance otimizada com paginação da API GitHub
- Tratamento robusto de erros
- Compatibilidade com workflow reusável existente
- Outputs para integração com outros steps

### Branches suportadas
- `main` - Ruleset ID 4598964
- `develop`, `dev/*`, `hotfix`, `hotfix/*` - Ruleset ID 4599019
- Feature branches (padrão BG/CE/IN/TASK/TS) - Ruleset ID 4598964
- Outras branches - Verificação ignorada

## [Unreleased]

### Planejado
- [ ] Suporte a configuração customizada de rulesets
- [ ] Cache de dados da API para melhor performance
- [ ] Modo de debug detalhado
- [ ] Suporte a múltiplos arquivos CODEOWNERS
- [ ] Integração com GitHub Enterprise Server
