# Check PR Approvers Action

Uma GitHub Action para verificar se um pull request possui o número mínimo de aprovações de membros dos times definidos no arquivo CODEOWNERS, seguindo as regras de branch protecti4. Abra uma [issue](../../issues) no repositório

---

Desenvolvido com ❤️ pela Squad DevSecOps repositório.

## 📋 Funcionalidades

- ✅ Verifica aprovações de PRs baseado nos times do CODEOWNERS
- 🎯 Suporte a diferentes rulesets por branch (main, develop, feature branches)
- 🔍 Validação automática contra as regras de proteção de branch
- 📊 Outputs detalhados para integração com outros workflows
- 🎨 Logs coloridos e informativos
- 🚀 Performance otimizada com paginação da API GitHub

## 🚀 Como usar

### Exemplo básico

```yaml
name: Check PR Approvers

on:
  pull_request_review:
    types: [submitted, edited, dismissed]

jobs:
  check-approvers:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        
      - name: Check PR Approvers
        uses: ./aprovadores  # ou seu-usuario/sua-action@v1
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          organization: ${{ github.repository_owner }}
          repository: ${{ github.event.repository.name }}
          pull-request-number: ${{ github.event.pull_request.number }}
```

### Exemplo com configurações customizadas

```yaml
- name: Check PR Approvers
  uses: ./aprovadores
  with:
    github-token: ${{ secrets.CUSTOM_TOKEN }}
    organization: 'br-next'
    repository: 'meu-repo'
    pull-request-number: '123'
    codeowners-path: 'docs/CODEOWNERS'
    required-approvals-main: '3'
    required-approvals-develop: '2'
    required-approvals-feature: '1'
    skip-branch-patterns: 'dependabot/*,renovate/*'
```

## 📥 Inputs

| Input | Descrição | Obrigatório | Padrão |
|-------|-----------|-------------|--------|
| `github-token` | Token do GitHub para acessar a API | ✅ | - |
| `organization` | Nome da organização do repositório | ✅ | - |
| `repository` | Nome do repositório | ✅ | - |
| `pull-request-number` | Número do pull request | ✅ | - |
| `codeowners-path` | Caminho para o arquivo CODEOWNERS | ❌ | `.github/CODEOWNERS` |
| `required-approvals-main` | Aprovações mínimas para branch main (fallback) | ❌ | `2` |
| `required-approvals-develop` | Aprovações mínimas para branches develop/hotfix (fallback) | ❌ | `1` |
| `required-approvals-feature` | Aprovações mínimas para feature branches (fallback) | ❌ | `1` |
| `skip-branch-patterns` | Padrões de branches a ignorar (separados por vírgula) | ❌ | - |

## 📤 Outputs

| Output | Descrição |
|--------|-----------|
| `approved-count` | Número de aprovações válidas encontradas |
| `required-count` | Número mínimo de aprovações necessárias |
| `status` | Status da verificação (`success`, `failed`, `skipped`) |

### Exemplo de uso dos outputs

```yaml
- name: Check PR Approvers
  id: check-approvers
  uses: ./aprovadores
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    organization: ${{ github.repository_owner }}
    repository: ${{ github.event.repository.name }}
    pull-request-number: ${{ github.event.pull_request.number }}

- name: Print results
  run: |
    echo "Status: ${{ steps.check-approvers.outputs.status }}"
    echo "Aprovações: ${{ steps.check-approvers.outputs.approved-count }}/${{ steps.check-approvers.outputs.required-count }}"
```

## 📁 Estrutura do CODEOWNERS

A action lê o arquivo CODEOWNERS e extrai os times definidos. Exemplo:

```
# CODEOWNERS
* @minha-org/backend-team @minha-org/devops-team
*.js @minha-org/frontend-team
docs/ @minha-org/docs-team
```

## 🎯 Estratégia de Detecção de Regras

A action utiliza uma abordagem **hierárquica** para determinar o número de aprovações necessárias:

### 1. 🔍 Branch Protection Rules (Prioridade Alta)
- Verifica regras específicas configuradas na branch
- API: `/repos/{org}/{repo}/branches/{branch}/protection`

### 2. 📋 Organization Rulesets (Prioridade Média)
- Busca rulesets da organização que se aplicam à branch
- API: `/orgs/{org}/rulesets`

### 3. 🎯 Configuração via Inputs (Prioridade Baixa)
- Usa valores definidos nos inputs da action
- Permite customização por organização

### 4. 📌 Fallback Padrão (Última Opção)
- **main/master**: 2 aprovações
- **develop/dev/hotfix**: 1 aprovação  
- **feature branches**: 1 aprovação

## 🔧 Requisitos

- GitHub token com as seguintes permissões:
  - `pull-requests: read`
  - `organization: read`
  - `members: read`
- Arquivo CODEOWNERS configurado no repositório
- Rulesets configurados na organização

## 🎨 Exemplo de Output

```
[INFO] Iniciando verificação de aprovadores...
[INFO] Organização: minha-org
[INFO] Repositório: meu-repo
[INFO] PR: #123
[INFO] Carregando teams do arquivo CODEOWNERS...
[INFO] Teams encontrados: backend-team devops-team
[INFO] Obtendo branch de destino do PR...
[INFO] Branch de destino: main
[INFO] Determinando ruleset baseado na branch: main
[INFO] Ruleset ID: 4598964
[INFO] Obtendo número mínimo de aprovações do ruleset...
[INFO] Aprovações mínimas necessárias: 2
[INFO] Obtendo membros do team: backend-team
[INFO] Obtendo membros do team: devops-team
[INFO] Total de membros dos teams: 8
[INFO] Obtendo aprovações do PR...
[INFO] Usuários que aprovaram: user1 user2
[INFO] Verificando aprovações válidas...
[INFO] ✓ Aprovação válida de: user1
[INFO] ✓ Aprovação válida de: user2
[SUCCESS] ✅ PR aprovado! 2 de 2 aprovações necessárias
```

## 🛠️ Desenvolvimento

### Estrutura do projeto

```
aprovadores/
├── action.yml              # Definição da action
├── scripts/
│   └── check-approvers.sh  # Script principal
├── examples/               # Exemplos de uso
│   ├── basic-usage.yml     # Uso básico
│   ├── custom-config.yml   # Configuração avançada
│   └── with-outputs.yml    # Usando outputs
├── tests/
│   └── demo-multi-org.sh   # Demonstração multi-org
├── docs/                   # Documentação detalhada
│   ├── MULTI-ORG.md        # Guia multi-organizações
│   ├── USAGE.md            # Exemplos de migração
│   └── DEPLOY.md           # Guia de publicação
└── README.md               # Esta documentação
```

### Executar localmente

```bash
# Executar demonstração multi-org
./tests/demo-multi-org.sh

# Definir variáveis de ambiente para teste manual
export INPUT_GITHUB_TOKEN="seu-token"
export INPUT_ORGANIZATION="sua-org"
export INPUT_REPOSITORY="seu-repo"
export INPUT_PULL_REQUEST_NUMBER="123"
export INPUT_CODEOWNERS_PATH=".github/CODEOWNERS"

# Executar script principal
./scripts/check-approvers.sh
```

## 🆘 Suporte

Para dúvidas ou problemas:

1. Verifique os [exemplos práticos](examples/)
2. Consulte a [documentação detalhada](docs/)
3. Execute a [demonstração](tests/demo-multi-org.sh)
4. Abra uma [issue](../../issues) no repositório

---

Desenvolvido com ❤️ pela Squad DevSecOps
