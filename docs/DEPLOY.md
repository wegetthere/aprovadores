# Guia de Publicação da Action

## 📦 Como publicar esta action

### 1. Criar um novo repositório no GitHub

```bash
# Criar um novo repositório público no GitHub
# Nome sugerido: check-pr-approvers
```

### 2. Fazer push do código

```bash
# Copie todo o conteúdo da pasta 'aprovadores' para o repositório
cd /caminho/para/novo/repo
cp -r /home/reivson/projetos/gh-actions/action-ca/aprovadores/* .
cp -r /home/reivson/projetos/gh-actions/action-ca/aprovadores/.github .

# Inicializar git se necessário
git init
git add .
git commit -m "feat: initial release of check-pr-approvers action"
git branch -M main
git remote add origin https://github.com/SEU-USUARIO/check-pr-approvers.git
git push -u origin main
```

### 3. Criar uma tag de versão

```bash
# Criar tag para v1.0.0
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# Criar tag major para facilitar uso
git tag -a v1 -m "Release v1 (latest)"
git push origin v1
```

### 4. Publicar no GitHub Marketplace

1. Acesse o repositório no GitHub
2. Vá até a aba "Releases"
3. Clique em "Create a new release"
4. Selecione a tag `v1.0.0`
5. Marque "Publish this Action to the GitHub Marketplace"
6. Preencha as informações solicitadas

### 5. Como outros repositórios vão usar

```yaml
# .github/workflows/check-approvers.yml
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
        
      - name: Generate token (se necessário)
        uses: Bradesco-Actions/generate-token@v1
        id: generate-token
        with:
          org: ${{ github.repository_owner }}
          app-id: ${{ vars.AUTHENTICATION_AND_AUTHORIZATION_APP_ID }}
          app-private-key: ${{ secrets.AUTHENTICATION_AND_AUTHORIZATION_PRIVATE_KEY }}
        
      - name: Check PR Approvers
        uses: SEU-USUARIO/check-pr-approvers@v1
        with:
          github-token: ${{ steps.generate-token.outputs.token }}
          organization: ${{ github.repository_owner }}
          repository: ${{ github.event.repository.name }}
          pull-request-number: ${{ github.event.pull_request.number }}
```

### 6. Substituir o workflow atual

Para migrar do workflow reusável atual para a action:

1. **Remover** o job que usa o reusable workflow:
   ```yaml
   # REMOVER ISSO:
   jobs:
     check-approvers:
       uses: Bradesco-Next/reusable-workflows/.github/workflows/check-approvers.yaml@main
       with:
         organization: Bradesco-Next
         repository: ${{ github.event.repository.name }}
         pull-request-number: ${{ github.event.pull_request.number }}
       secrets: inherit
   ```

2. **Adicionar** o job com a action:
   ```yaml
   # ADICIONAR ISSO:
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
           uses: SEU-USUARIO/check-pr-approvers@v1
           with:
             github-token: ${{ steps.generate-token.outputs.token }}
             organization: ${{ github.repository_owner }}
             repository: ${{ github.event.repository.name }}
             pull-request-number: ${{ github.event.pull_request.number }}
   ```

## 🔧 Configurações necessárias

### No repositório da action:
- [ ] Secrets configurados para o workflow de teste (se aplicável)
- [ ] Branch protection rules configuradas
- [ ] Tags de versão criadas

### Nos repositórios que vão usar a action:
- [ ] Arquivo CODEOWNERS configurado em `.github/CODEOWNERS`
- [ ] Teams da organização configurados
- [ ] Rulesets configurados na organização (IDs: 4598964, 4599019)
- [ ] Secrets/vars necessários para geração de token

## 📊 Vantagens da migração

1. **Independência**: Não depende mais de repositório externo
2. **Performance**: Lógica otimizada e melhor tratamento de erros
3. **Flexibilidade**: Outputs disponíveis para outros steps
4. **Manutenibilidade**: Código mais limpo e organizado
5. **Reutilização**: Pode ser facilmente compartilhada
6. **Versionamento**: Tags semânticas para melhor controle

## 🚀 Próximos passos

1. Criar repositório no GitHub
2. Fazer upload dos arquivos
3. Criar tags de versão
4. Testar em um repositório piloto
5. Documentar a migração para os times
6. Aplicar gradualmente nos demais repositórios
