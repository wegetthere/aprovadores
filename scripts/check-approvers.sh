#!/bin/bash
set -euo pipefail

# =============================================================================
# Check PR Approvers - GitHub Action Script
# =============================================================================
# Verifica se um pull request possui o número mínimo de aprovações de membros
# dos times definidos no CODEOWNERS conforme as regras do repositório.
# =============================================================================

# Cores para output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Variáveis globais
GITHUB_TOKEN="${INPUT_GITHUB_TOKEN}"
ORGANIZATION="${INPUT_ORGANIZATION}"
REPOSITORY="${INPUT_REPOSITORY}"
PULL_REQUEST_NUMBER="${INPUT_PULL_REQUEST_NUMBER}"
CODEOWNERS_PATH="${INPUT_CODEOWNERS_PATH}"
REQUIRED_APPROVALS_MAIN="${INPUT_REQUIRED_APPROVALS_MAIN:-2}"
REQUIRED_APPROVALS_DEVELOP="${INPUT_REQUIRED_APPROVALS_DEVELOP:-1}"
REQUIRED_APPROVALS_FEATURE="${INPUT_REQUIRED_APPROVALS_FEATURE:-1}"
SKIP_BRANCH_PATTERNS="${INPUT_SKIP_BRANCH_PATTERNS:-}"

# URLs da API GitHub
readonly GITHUB_API_BASE="https://api.github.com"
readonly REVIEWS_URL="${GITHUB_API_BASE}/repos/${ORGANIZATION}/${REPOSITORY}/pulls/${PULL_REQUEST_NUMBER}/reviews"
readonly PR_URL="${GITHUB_API_BASE}/repos/${ORGANIZATION}/${REPOSITORY}/pulls/${PULL_REQUEST_NUMBER}"

# =============================================================================
# Funções Utilitárias
# =============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

set_output() {
    echo "$1=$2" >> "${GITHUB_OUTPUT:-/dev/stdout}"
}

github_api_call() {
    local url="$1"
    local result
    
    result=$(curl -s -L \
        -H "Authorization: token ${GITHUB_TOKEN}" \
        -H "Accept: application/vnd.github+json" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "${url}")
    
    echo "${result}"
}

# =============================================================================
# Funções Principais
# =============================================================================

load_codeowners_teams() {
    log_info "Carregando teams do arquivo CODEOWNERS..."
    
    local teams=()
    
    if [[ ! -f "${CODEOWNERS_PATH}" ]]; then
        log_warning "Arquivo CODEOWNERS não encontrado em: ${CODEOWNERS_PATH}"
        echo ""
        return 0
    fi
    
    while IFS= read -r line; do
        # Ignora linhas vazias e comentários
        [[ -z "${line// }" || "${line:0:1}" == "#" ]] && continue
        
        # Processa linhas que começam com *
        if [[ "${line:0:1}" == "*" ]]; then
            local groups="${line#* }"
            
            for group in ${groups}; do
                if [[ "${group}" =~ ^@[^/]+/(.+)$ ]]; then
                    local team="${BASH_REMATCH[1]}"
                    teams+=("${team}")
                fi
            done
        fi
    done < "${CODEOWNERS_PATH}"
    
    if [[ ${#teams[@]} -eq 0 ]]; then
        log_warning "Nenhum team encontrado no CODEOWNERS"
        echo ""
        return 0
    fi
    
    log_info "Teams encontrados: ${teams[*]}"
    echo "${teams[*]}"
}

get_pr_target_branch() {
    log_info "Obtendo branch de destino do PR..."
    
    local pr_data
    pr_data=$(github_api_call "${PR_URL}")
    
    local target_branch
    target_branch=$(echo "${pr_data}" | jq -r '.base.ref')
    
    if [[ "${target_branch}" == "null" || -z "${target_branch}" ]]; then
        log_error "Não foi possível obter a branch de destino do PR"
        exit 1
    fi
    
    log_info "Branch de destino: ${target_branch}"
    echo "${target_branch}"
}

get_branch_protection_rules() {
    local target_branch="$1"
    
    log_info "Obtendo regras de proteção para a branch: ${target_branch}"
    
    # Verifica se a branch deve ser ignorada
    if [[ -n "${SKIP_BRANCH_PATTERNS}" ]]; then
        IFS=',' read -ra patterns <<< "${SKIP_BRANCH_PATTERNS}"
        for pattern in "${patterns[@]}"; do
            pattern=$(echo "${pattern}" | xargs)  # Remove espaços
            if [[ "${target_branch}" =~ ${pattern} ]]; then
                log_info "Branch corresponde ao padrão de skip: ${pattern}"
                return 1
            fi
        done
    fi
    
    # Primeiro tenta obter regras específicas da branch
    local branch_protection_url="${GITHUB_API_BASE}/repos/${ORGANIZATION}/${REPOSITORY}/branches/${target_branch}/protection"
    local protection_data
    protection_data=$(github_api_call "${branch_protection_url}" 2>/dev/null || echo "null")
    
    if [[ "${protection_data}" != "null" ]] && [[ "$(echo "${protection_data}" | jq -r '.required_pull_request_reviews.required_approving_review_count // "null"')" != "null" ]]; then
        local required_count
        required_count=$(echo "${protection_data}" | jq -r '.required_pull_request_reviews.required_approving_review_count')
        log_info "Regras de branch protection encontradas - Aprovações necessárias: ${required_count}"
        echo "${required_count}"
        return 0
    fi
    
    # Se não encontrar regras específicas, tenta buscar rulesets da organização
    log_info "Regras de branch protection não encontradas, buscando rulesets da organização..."
    local rulesets_url="${GITHUB_API_BASE}/orgs/${ORGANIZATION}/rulesets"
    local rulesets_data
    rulesets_data=$(github_api_call "${rulesets_url}" 2>/dev/null || echo "[]")
    
    # Procura por rulesets que se aplicam à branch atual
    local matching_ruleset
    matching_ruleset=$(echo "${rulesets_data}" | jq -r --arg branch "${target_branch}" '
        .[] | select(
            (.target == "branch" and (.conditions.ref_name.include[] | test($branch))) or
            (.target == "branch" and .conditions.ref_name.include[] == $branch) or
            (.target == "branch" and (.conditions.ref_name.include[] | test("^" + $branch + "$")))
        ) | .id' | head -n1)
    
    if [[ -n "${matching_ruleset}" && "${matching_ruleset}" != "null" ]]; then
        log_info "Ruleset encontrado: ${matching_ruleset}"
        echo "ruleset:${matching_ruleset}"
        return 0
    fi
    
    # Fallback: define regras padrão baseadas em convenções e inputs
    log_info "Usando regras padrão baseadas na branch"
    case "${target_branch}" in
        main | master)
            echo "${REQUIRED_APPROVALS_MAIN}"
            ;;
        develop | dev/* | hotfix | hotfix/*)
            echo "${REQUIRED_APPROVALS_DEVELOP}"
            ;;
        *)
            if [[ "${target_branch}" =~ ^(BG|CE|IN|TASK|TS)/S[0-9]{2}/NEXT2-[0-9]{5,7}(-[0-9]+)?$ ]]; then
                echo "${REQUIRED_APPROVALS_FEATURE}"
            else
                log_info "Branch não requer verificação de aprovadores"
                return 1
            fi
            ;;
    esac
}

get_required_approvals_count() {
    local protection_info="$1"
    
    # Se é um número direto (fallback), retorna diretamente
    if [[ "${protection_info}" =~ ^[0-9]+$ ]]; then
        log_info "Usando valor padrão de aprovações: ${protection_info}"
        echo "${protection_info}"
        return 0
    fi
    
    # Se é um ruleset, busca os detalhes
    if [[ "${protection_info}" =~ ^ruleset:(.+)$ ]]; then
        local ruleset_id="${BASH_REMATCH[1]}"
        log_info "Obtendo número mínimo de aprovações do ruleset: ${ruleset_id}"
        
        local ruleset_url="${GITHUB_API_BASE}/orgs/${ORGANIZATION}/rulesets/${ruleset_id}"
        local ruleset_data
        ruleset_data=$(github_api_call "${ruleset_url}")
        
        local required_count
        required_count=$(echo "${ruleset_data}" | jq -r '.rules[] | select(.type == "pull_request") | .parameters.required_approving_review_count // empty')
        
        if [[ -n "${required_count}" && "${required_count}" != "null" ]]; then
            log_info "Aprovações mínimas necessárias (ruleset): ${required_count}"
            echo "${required_count}"
            return 0
        fi
    fi
    
    # Fallback: se não conseguir obter, usa 1 como padrão
    log_warning "Não foi possível obter número específico de aprovações, usando padrão: 1"
    echo "1"
}

get_team_members() {
    local team="$1"
    local members=()
    local page=1
    
    log_info "Obtendo membros do team: ${team}"
    
    while true; do
        local team_url="${GITHUB_API_BASE}/orgs/${ORGANIZATION}/teams/${team}/members?page=${page}&per_page=100"
        local response
        response=$(github_api_call "${team_url}")
        
        local page_members
        page_members=$(echo "${response}" | jq -r '.[].login' 2>/dev/null || echo "")
        
        [[ -z "${page_members}" ]] && break
        
        while IFS= read -r member; do
            [[ -n "${member}" ]] && members+=("${member}")
        done <<< "${page_members}"
        
        ((page++))
    done
    
    echo "${members[*]}"
}

get_all_team_members() {
    local teams="$1"
    local all_members=()
    
    if [[ -z "${teams}" ]]; then
        echo ""
        return 0
    fi
    
    for team in ${teams}; do
        local team_members
        team_members=$(get_team_members "${team}")
        
        for member in ${team_members}; do
            all_members+=("${member}")
        done
    done
    
    # Remove duplicatas
    local unique_members
    unique_members=$(printf '%s\n' "${all_members[@]}" | sort -u | tr '\n' ' ')
    
    log_info "Total de membros dos teams: $(echo ${unique_members} | wc -w)"
    echo "${unique_members}"
}

get_pr_approvals() {
    log_info "Obtendo aprovações do PR..."
    
    local reviews_data
    reviews_data=$(github_api_call "${REVIEWS_URL}")
    
    local approvals
    approvals=$(echo "${reviews_data}" | jq -r '.[] | select(.state == "APPROVED") | .user.login' | sort -u | tr '\n' ' ')
    
    if [[ -n "${approvals// }" ]]; then
        log_info "Usuários que aprovaram: ${approvals}"
    else
        log_warning "Nenhuma aprovação encontrada"
    fi
    
    echo "${approvals}"
}

count_valid_approvals() {
    local approvals="$1"
    local team_members="$2"
    local valid_count=0
    
    if [[ -z "${approvals// }" || -z "${team_members// }" ]]; then
        echo "0"
        return 0
    fi
    
    log_info "Verificando aprovações válidas..."
    
    for approval in ${approvals}; do
        for member in ${team_members}; do
            if [[ "${member}" == "${approval}" ]]; then
                log_info "✓ Aprovação válida de: ${approval}"
                ((valid_count++))
                break
            fi
        done
    done
    
    echo "${valid_count}"
}

# =============================================================================
# Função Principal
# =============================================================================

main() {
    log_info "Iniciando verificação de aprovadores..."
    log_info "Organização: ${ORGANIZATION}"
    log_info "Repositório: ${REPOSITORY}"
    log_info "PR: #${PULL_REQUEST_NUMBER}"
    
    # Carrega teams do CODEOWNERS
    local teams
    teams=$(load_codeowners_teams)
    
    if [[ -z "${teams// }" ]]; then
        log_error "Nenhum team encontrado no CODEOWNERS. Verificação cancelada."
        set_output "status" "failed"
        exit 1
    fi
    
    # Obtém branch de destino
    local target_branch
    target_branch=$(get_pr_target_branch)
    
    # Obtém regras de proteção
    local protection_info
    if ! protection_info=$(get_branch_protection_rules "${target_branch}"); then
        log_success "Verificação de aprovadores não necessária para esta branch"
        set_output "status" "skipped"
        exit 0
    fi
    
    # Obtém número mínimo de aprovações
    local required_count
    required_count=$(get_required_approvals_count "${protection_info}")
    
    # Obtém membros dos teams
    local team_members
    team_members=$(get_all_team_members "${teams}")
    
    if [[ -z "${team_members// }" ]]; then
        log_error "Nenhum membro encontrado nos teams especificados"
        set_output "status" "failed"
        exit 1
    fi
    
    # Obtém aprovações do PR
    local approvals
    approvals=$(get_pr_approvals)
    
    # Conta aprovações válidas
    local valid_count
    valid_count=$(count_valid_approvals "${approvals}" "${team_members}")
    
    # Define outputs
    set_output "approved-count" "${valid_count}"
    set_output "required-count" "${required_count}"
    
    # Verifica se atende aos requisitos
    if [[ ${valid_count} -ge ${required_count} ]]; then
        log_success "✅ PR aprovado! ${valid_count} de ${required_count} aprovações necessárias"
        set_output "status" "success"
        exit 0
    else
        log_error "❌ PR não possui aprovações suficientes! ${valid_count} de ${required_count} aprovações necessárias"
        set_output "status" "failed"
        exit 1
    fi
}

# =============================================================================
# Execução
# =============================================================================

main "$@"
