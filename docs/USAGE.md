# Exemplo de uso da Action Check PR Approvers

## Como migrar do workflow reusável para a action

### Antes (usando reusable workflow)

```yaml
name: Check Approvers

on:
  pull_request_review:
    types: [submitted, edited, dismissed, approved]

jobs:
  check-approvers:
    uses: Bradesco-Next/reusable-workflows/.github/workflows/check-approvers.yaml@main
    with:
      organization: Bradesco-Next
      repository: ${{ github.event.repository.name }}
      pull-request-number: ${{ github.event.pull_request.number }}
    secrets: inherit
```

### Depois (usando a action)

```yaml
name: Check Approvers

on:
  pull_request_review:
    types: [submitted, edited, dismissed]

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
        uses: seu-usuario/check-pr-approvers@v1
        with:
          github-token: ${{ steps.generate-token.outputs.token }}
          organization: ${{ github.repository_owner }}
          repository: ${{ github.event.repository.name }}
          pull-request-number: ${{ github.event.pull_request.number }}
```

## Vantagens da migração

### ✅ Melhorias

- **Modularidade**: Action independente, não depende de repositório externo
- **Performance**: Lógica otimizada com melhor tratamento de erros
- **Manutenibilidade**: Código mais limpo e organizado
- **Flexibilidade**: Outputs disponíveis para uso em outros steps
- **Logs melhorados**: Mensagens mais claras e coloridas
- **Reutilização**: Pode ser facilmente compartilhada entre organizações

### 🔄 Compatibilidade

- Mantém a mesma funcionalidade do workflow original
- Suporte aos mesmos rulesets e branches
- Mesma lógica de verificação de teams do CODEOWNERS

## Exemplos avançados

### Com validação condicional

```yaml
- name: Check PR Approvers
  id: check-approvers
  uses: seu-usuario/check-pr-approvers@v1
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    organization: ${{ github.repository_owner }}
    repository: ${{ github.event.repository.name }}
    pull-request-number: ${{ github.event.pull_request.number }}

- name: Block merge if not approved
  if: steps.check-approvers.outputs.status == 'failed'
  run: |
    echo "❌ PR não pode ser mergeado - aprovações insuficientes"
    echo "Aprovações: ${{ steps.check-approvers.outputs.approved-count }}/${{ steps.check-approvers.outputs.required-count }}"
    exit 1

- name: Allow merge
  if: steps.check-approvers.outputs.status == 'success'
  run: |
    echo "✅ PR aprovado para merge!"
    echo "Aprovações: ${{ steps.check-approvers.outputs.approved-count }}/${{ steps.check-approvers.outputs.required-count }}"
```

### Com notificação customizada

```yaml
- name: Check PR Approvers
  id: check-approvers
  uses: seu-usuario/check-pr-approvers@v1
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    organization: ${{ github.repository_owner }}
    repository: ${{ github.event.repository.name }}
    pull-request-number: ${{ github.event.pull_request.number }}

- name: Comment on PR
  if: steps.check-approvers.outputs.status == 'failed'
  uses: actions/github-script@v7
  with:
    script: |
      github.rest.issues.createComment({
        issue_number: context.issue.number,
        owner: context.repo.owner,
        repo: context.repo.repo,
        body: `❌ **Aprovações insuficientes**
        
        Este PR precisa de **${{ steps.check-approvers.outputs.required-count }}** aprovações de membros dos teams definidos no CODEOWNERS.
        
        Aprovações atuais: **${{ steps.check-approvers.outputs.approved-count }}**
        
        Por favor, solicite review dos membros dos teams apropriados.`
      })
```
