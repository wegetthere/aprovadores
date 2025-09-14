# Check PR Approvers Action

Uma GitHub Action para verificar se um pull request possui o número mínimo de aprovações de membros dos times definidos no arquivo CODEOWNERS, seguindo as regras de branch protection configuradas no repositório.

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
    organization: 'minha-org'
    repository: 'meu-repo'
    pull-request-number: '123'
    codeowners-path: 'docs/CODEOWNERS'
```

## 📥 Inputs

| Input | Descrição | Obrigatório | Padrão |
|-------|-----------|-------------|--------|
| `github-token` | Token do GitHub para acessar a API | ✅ | - |
| `organization` | Nome da organização do repositório | ✅ | - |
| `repository` | Nome do repositório | ✅ | - |
| `pull-request-number` | Número do pull request | ✅ | - |
| `codeowners-path` | Caminho para o arquivo CODEOWNERS | ❌ | `.github/CODEOWNERS` |

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

## 🎯 Regras por Branch

A action aplica diferentes rulesets baseados na branch de destino:

- **main**: Ruleset ID `4598964`
- **develop, dev/*, hotfix, hotfix/***: Ruleset ID `4599019`
- **Branches de feature** (padrão: `(BG|CE|IN|TASK|TS)/S[0-9]{2}/NEXT2-[0-9]{5,7}(-[0-9]+)?`): Ruleset ID `4598964`
- **Outras branches**: Verificação ignorada

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
└── README.md               # Esta documentação
```

### Executar localmente

```bash
# Definir variáveis de ambiente
export INPUT_GITHUB_TOKEN="seu-token"
export INPUT_ORGANIZATION="sua-org"
export INPUT_REPOSITORY="seu-repo"
export INPUT_PULL_REQUEST_NUMBER="123"
export INPUT_CODEOWNERS_PATH=".github/CODEOWNERS"

# Executar script
./scripts/check-approvers.sh
```

## 🤝 Contribuindo

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -am 'Add nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 🆘 Suporte

Para dúvidas ou problemas:

1. Verifique a [documentação](#-como-usar)
2. Consulte os [exemplos](#exemplo-básico)
3. Abra uma [issue](../../issues) no repositório

---

Desenvolvido com ❤️ pela Squad DevSecOps
