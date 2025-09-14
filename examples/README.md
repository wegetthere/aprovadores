# 📁 Exemplos de Uso

Esta pasta contém exemplos práticos de como usar a action Check PR Approvers em diferentes cenários.

## 📋 Lista de Exemplos

### [`basic-usage.yml`](./basic-usage.yml)
**Uso básico** - Configuração mínima para começar a usar a action.
- ✅ Detecção automática de regras
- ✅ Configuração padrão
- ✅ Ideal para primeiros testes

### [`custom-config.yml`](./custom-config.yml) 
**Configuração customizada** - Exemplo com todas as opções disponíveis.
- ✅ Autenticação com app token
- ✅ Aprovações customizadas por tipo de branch
- ✅ Skip patterns para branches especiais
- ✅ Ideal para ambientes de produção

### [`with-outputs.yml`](./with-outputs.yml)
**Usando outputs** - Como usar os dados retornados pela action.
- ✅ Acesso aos resultados da verificação
- ✅ Lógica condicional baseada no status
- ✅ Comentários automáticos no PR
- ✅ Ideal para workflows complexos

## 🚀 Como usar

1. **Escolha o exemplo** mais próximo do seu caso de uso
2. **Copie o conteúdo** para `.github/workflows/` no seu repositório
3. **Ajuste os parâmetros** conforme necessário
4. **Configure o CODEOWNERS** em `.github/CODEOWNERS`
5. **Teste** criando um PR

## 🔧 Configuração Necessária

### CODEOWNERS
```
# .github/CODEOWNERS
* @sua-org/backend-team @sua-org/devops-team
*.js @sua-org/frontend-team
docs/ @sua-org/docs-team
```

### Permissions
```yaml
permissions:
  pull-requests: read
  contents: read
```

### Secrets/Variables (se usando app token)
- `AUTHENTICATION_AND_AUTHORIZATION_APP_ID`
- `AUTHENTICATION_AND_AUTHORIZATION_PRIVATE_KEY`

## ❓ Dúvidas?

- Consulte o [README.md](../README.md) principal
- Veja o [guia multi-org](../MULTI-ORG.md) para múltiplas organizações
- Execute o [demo](../tests/demo-multi-org.sh) para ver funcionamento
