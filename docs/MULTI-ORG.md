# Multi-Organization Setup Guide

## 🏢 Configuração para Múltiplas Organizações

Este guia explica como configurar a action para funcionar em diferentes organizações (br-action, br-next, br-core).

### 🎯 Problema Resolvido

✅ **Antes**: Ruleset IDs hardcoded específicos de uma organização  
✅ **Depois**: Detecção dinâmica de regras específicas por organização

## 📋 Configuração por Organização

### 1. Organização `br-action` (onde a action está hospedada)

```yaml
# .github/workflows/check-approvers.yml
- name: Check PR Approvers
  uses: br-action/check-pr-approvers@v1
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    organization: ${{ github.repository_owner }}
    repository: ${{ github.event.repository.name }}
    pull-request-number: ${{ github.event.pull_request.number }}
    # Usa detecção automática de regras
```

### 2. Organização `br-next`

```yaml
# .github/workflows/check-approvers.yml
- name: Check PR Approvers
  uses: br-action/check-pr-approvers@v1
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    organization: br-next
    repository: ${{ github.event.repository.name }}
    pull-request-number: ${{ github.event.pull_request.number }}
    # Configurações específicas para br-next
    required-approvals-main: '3'
    required-approvals-develop: '2'
    required-approvals-feature: '1'
```

### 3. Organização `br-core`

```yaml
# .github/workflows/check-approvers.yml
- name: Check PR Approvers
  uses: br-action/check-pr-approvers@v1
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    organization: br-core
    repository: ${{ github.event.repository.name }}
    pull-request-number: ${{ github.event.pull_request.number }}
    # Configurações específicas para br-core
    required-approvals-main: '2'
    required-approvals-develop: '1'
    required-approvals-feature: '1'
    skip-branch-patterns: 'dependabot/*,auto-update/*'
```

## 🔧 Estratégias de Configuração

### Opção 1: Detecção Automática (Recomendado)

```yaml
- name: Check PR Approvers
  uses: br-action/check-pr-approvers@v1
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    organization: ${{ github.repository_owner }}
    repository: ${{ github.event.repository.name }}
    pull-request-number: ${{ github.event.pull_request.number }}
```

**Vantagens:**
- ✅ Detecta automaticamente branch protection rules
- ✅ Busca rulesets da organização
- ✅ Funciona out-of-the-box

### Opção 2: Configuração Customizada

```yaml
- name: Check PR Approvers
  uses: br-action/check-pr-approvers@v1
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    organization: ${{ github.repository_owner }}
    repository: ${{ github.event.repository.name }}
    pull-request-number: ${{ github.event.pull_request.number }}
    required-approvals-main: '3'
    required-approvals-develop: '2'
    required-approvals-feature: '1'
```

**Vantagens:**
- ✅ Controle total sobre as regras
- ✅ Consistência entre repositórios
- ✅ Fallback garantido

### Opção 3: Configuração Híbrida

```yaml
# Usar variáveis de organização/repositório
- name: Check PR Approvers
  uses: br-action/check-pr-approvers@v1
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    organization: ${{ github.repository_owner }}
    repository: ${{ github.event.repository.name }}
    pull-request-number: ${{ github.event.pull_request.number }}
    required-approvals-main: ${{ vars.APPROVALS_MAIN || '2' }}
    required-approvals-develop: ${{ vars.APPROVALS_DEVELOP || '1' }}
    required-approvals-feature: ${{ vars.APPROVALS_FEATURE || '1' }}
    skip-branch-patterns: ${{ vars.SKIP_PATTERNS || '' }}
```

## 🔍 Fluxo de Detecção

### 1. Branch Protection Rules
```
API: GET /repos/{org}/{repo}/branches/{branch}/protection
```
- Verifica se há regras específicas da branch
- Extrai `required_approving_review_count`

### 2. Organization Rulesets
```
API: GET /orgs/{org}/rulesets
```
- Lista todos os rulesets da organização
- Filtra por branch usando regex patterns
- Extrai regras de pull request

### 3. Fallback por Input
```
Inputs da action:
- required-approvals-main
- required-approvals-develop  
- required-approvals-feature
```

### 4. Fallback Padrão
```
main/master: 2 aprovações
develop/dev/hotfix: 1 aprovação
feature: 1 aprovação
```

## 🚀 Exemplo de Migração

### Antes (Workflow Reusável)
```yaml
jobs:
  check-approvers:
    uses: Bradesco-Next/reusable-workflows/.github/workflows/check-approvers.yaml@main
    with:
      organization: Bradesco-Next
      repository: ${{ github.event.repository.name }}
      pull-request-number: ${{ github.event.pull_request.number }}
    secrets: inherit
```

### Depois (Action Multi-Org)
```yaml
jobs:
  check-approvers:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        
      - name: Generate token
        uses: Bradesco-Actions/generate-token@v1
        id: generate-token
        with:
          org: ${{ github.repository_owner }}
          app-id: ${{ vars.AUTHENTICATION_AND_AUTHORIZATION_APP_ID }}
          app-private-key: ${{ secrets.AUTHENTICATION_AND_AUTHORIZATION_PRIVATE_KEY }}
        
      - name: Check PR Approvers
        uses: br-action/check-pr-approvers@v1
        with:
          github-token: ${{ steps.generate-token.outputs.token }}
          organization: ${{ github.repository_owner }}  # ← Detecta automaticamente a org
          repository: ${{ github.event.repository.name }}
          pull-request-number: ${{ github.event.pull_request.number }}
```

## 🔒 Permissões Necessárias

### Token Requirements
```yaml
permissions:
  pull-requests: read    # Para ler reviews do PR
  organization: read     # Para acessar rulesets
  members: read         # Para listar membros dos teams
  contents: read        # Para acessar CODEOWNERS
```

### Organization Settings
- Teams configurados com membros apropriados
- CODEOWNERS files nos repositórios
- Branch protection rules ou rulesets (opcional)

## 📊 Benefícios da Abordagem Multi-Org

1. **🎯 Flexibilidade**: Cada org pode ter suas próprias regras
2. **🔧 Manutenibilidade**: Uma action, múltiplas organizações
3. **📈 Escalabilidade**: Fácil adição de novas organizações
4. **🔒 Segurança**: Respeita permissões específicas de cada org
5. **⚡ Performance**: Detecção eficiente de regras
