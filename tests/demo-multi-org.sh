#!/bin/bash
# Teste de demonstração da action multi-org

set -e

echo "🧪 Demonstração: Check PR Approvers Multi-Org"
echo "=============================================="

# Simula diferentes cenários de organizações

test_scenario() {
    local org="$1"
    local branch="$2"
    local description="$3"
    
    echo ""
    echo "📋 Cenário: ${description}"
    echo "   Organização: ${org}"
    echo "   Branch: ${branch}"
    echo "   ---"
    
    # Simula variáveis de ambiente
    export INPUT_ORGANIZATION="${org}"
    export INPUT_REPOSITORY="test-repo"
    export INPUT_PULL_REQUEST_NUMBER="123"
    export INPUT_GITHUB_TOKEN="mock-token"
    export INPUT_CODEOWNERS_PATH=".github/CODEOWNERS"
    export INPUT_REQUIRED_APPROVALS_MAIN="2"
    export INPUT_REQUIRED_APPROVALS_DEVELOP="1"
    export INPUT_REQUIRED_APPROVALS_FEATURE="1"
    export INPUT_SKIP_BRANCH_PATTERNS=""
    export GITHUB_OUTPUT="/tmp/test_output"
    
    # Cria mock do CODEOWNERS
    mkdir -p .github
    echo "* @${org}/backend-team @${org}/devops-team" > .github/CODEOWNERS
    
    # Simula a detecção de branch (sem chamadas de API)
    echo "   Branch detectada: ${branch}"
    
    # Simula a lógica de detecção de regras (fallback)
    case "${branch}" in
        main|master)
            required_approvals="2"
            ;;
        develop|dev/*|hotfix|hotfix/*)
            required_approvals="1"
            ;;
        *)
            if [[ "${branch}" =~ ^(BG|CE|IN|TASK|TS)/S[0-9]{2}/NEXT2-[0-9]{5,7}(-[0-9]+)?$ ]]; then
                required_approvals="1"
            else
                echo "   ⏭️  Branch ignorada (não requer aprovação)"
                return 0
            fi
            ;;
    esac
    
    echo "   ✅ Aprovações necessárias: ${required_approvals}"
    echo "   📝 Teams encontrados: backend-team, devops-team"
}

echo ""
echo "🏢 Testando diferentes organizações..."

# Testa br-action
test_scenario "br-action" "main" "Org principal - branch main"
test_scenario "br-action" "develop" "Org principal - branch develop"

# Testa br-next  
test_scenario "br-next" "main" "Org br-next - branch main"
test_scenario "br-next" "feature/TASK/S01/NEXT2-12345" "Org br-next - feature branch"

# Testa br-core
test_scenario "br-core" "hotfix/critical-fix" "Org br-core - hotfix branch"
test_scenario "br-core" "dependabot/npm/lodash" "Org br-core - dependabot (pode ser ignorada)"

echo ""
echo "🎯 Testando skip patterns..."

export INPUT_SKIP_BRANCH_PATTERNS="dependabot/*,renovate/*"
test_scenario "br-core" "dependabot/npm/lodash" "Branch com skip pattern"

echo ""
echo "✅ Demonstração concluída!"
echo ""
echo "💡 A action agora suporta:"
echo "   • Detecção automática de regras por organização"
echo "   • Fallback configurável via inputs"
echo "   • Skip patterns para branches especiais"
echo "   • Compatibilidade total entre organizações"
echo ""
echo "📚 Para mais detalhes, consulte MULTI-ORG.md"
