# 📖 Índice de Documentação

Bem-vindo à documentação completa da **Check PR Approvers Action**!

## 🚀 Início Rápido

| Documento | Descrição | Para quem |
|-----------|-----------|-----------|
| [README.md](../README.md) | **Documentação principal** | Todos os usuários |
| [examples/](../examples/) | **Exemplos práticos** | Iniciantes |
| [tests/demo-multi-org.sh](../tests/demo-multi-org.sh) | **Demonstração interativa** | Desenvolvedores |

## 📚 Documentação Detalhada

### Para Usuários

| Documento | Descrição |
|-----------|-----------|
| [USAGE.md](./USAGE.md) | Como migrar do workflow reusável |
| [examples/basic-usage.yml](../examples/basic-usage.yml) | Configuração básica |
| [examples/custom-config.yml](../examples/custom-config.yml) | Configuração avançada |

### Para Administradores

| Documento | Descrição |
|-----------|-----------|
| [MULTI-ORG.md](./MULTI-ORG.md) | **Configuração para múltiplas organizações** |
| [DEPLOY.md](./DEPLOY.md) | Como publicar a action |

### Para Desenvolvedores

| Documento | Descrição |
|-----------|-----------|
| [scripts/check-approvers.sh](../scripts/check-approvers.sh) | Código principal |
| [tests/](../tests/) | Scripts de teste |
| [CHANGELOG.md](../CHANGELOG.md) | Histórico de versões |

## 🎯 Fluxos de Uso Comuns

### 1. **Primeiro uso**
```
README.md → examples/basic-usage.yml → Configurar CODEOWNERS
```

### 2. **Configuração avançada**
```
examples/custom-config.yml → MULTI-ORG.md → Teste em staging
```

### 3. **Múltiplas organizações**
```
MULTI-ORG.md → examples/ → DEPLOY.md
```

### 4. **Migração do workflow atual**
```
USAGE.md → examples/ → Teste paralelo → Migração
```

### 5. **Desenvolvimento/Debug**
```
tests/demo-multi-org.sh → scripts/check-approvers.sh → Logs
```

## 🔍 FAQ Rápido

**P: Como começar?**  
R: Veja [examples/basic-usage.yml](../examples/basic-usage.yml)

**P: Como configurar múltiplas orgs?**  
R: Consulte [MULTI-ORG.md](./MULTI-ORG.md)

**P: Como migrar do workflow atual?**  
R: Siga [USAGE.md](./USAGE.md)

**P: Como publicar a action?**  
R: Veja [DEPLOY.md](./DEPLOY.md)

**P: Como testar localmente?**  
R: Execute [tests/demo-multi-org.sh](../tests/demo-multi-org.sh)

---

💡 **Dica**: Comece sempre pelo README principal e depois navegue para documentação específica conforme sua necessidade!
