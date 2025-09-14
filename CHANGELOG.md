# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-09-12

### Adicionado
- ✨ Action inicial para verificação de aprovadores de PR
- 🔍 Suporte a verificação baseada em CODEOWNERS
- 🎯 Rulesets específicos por branch (main, develop, feature)
- 📊 Outputs detalhados (approved-count, required-count, status)
- 🎨 Logs coloridos e informativos
- 📚 Documentação completa com exemplos
- ✅ Testes básicos de sintaxe
- 🔒 Licença MIT

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
