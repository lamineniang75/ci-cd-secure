#!/bin/bash

# ============================================================================
# FICHIER: scripts/setup-github-secrets.sh
# DESCRIPTION: Script pour configurer les secrets GitHub Actions
# UTILISATION: bash scripts/setup-github-secrets.sh
# ============================================================================

set -euo pipefail

# Couleurs pour l'output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# FONCTIONS UTILITAIRES
# ============================================================================

print_header() {
    echo -e "\n${BLUE}========== $1 ==========${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Vérifier si gh CLI est installé
check_gh_cli() {
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI (gh) n'est pas installé"
        echo "Installation : https://cli.github.com/"
        exit 1
    fi
    print_success "GitHub CLI détecté"
}

# Vérifier l'authentification
check_auth() {
    if ! gh auth status > /dev/null 2>&1; then
        print_error "Non authentifié à GitHub"
        echo "Exécutez : gh auth login"
        exit 1
    fi
    print_success "Authentification GitHub OK"
}

# ============================================================================
# SECRETS À CONFIGURER
# ============================================================================

print_header "Configuration des GitHub Secrets"

check_gh_cli
check_auth

# Récupérer le repo depuis git
REPO=$(git config --get remote.origin.url | sed 's/.*\///' | sed 's/\.git$//')
OWNER=$(git config --get remote.origin.url | sed 's/.*[:/]\([^/]*\)\/.*/\1/')

print_success "Repository: $OWNER/$REPO"

# ============================================================================
# SECRETS DE NOTIFICATIONS EMAIL
# ============================================================================

print_header "Configuration - Secrets de Notification Email"

echo "Pour activer les notifications par email, fournissez :"
echo "- Serveur SMTP (ex: smtp.gmail.com, smtp.sendgrid.net)"
echo "- Port (ex: 587, 465)"
echo "- Nom d'utilisateur (adresse email ou user)"
echo "- Mot de passe (ou App-specific password)"
echo ""

read -p "Serveur SMTP [smtp.gmail.com]: " MAIL_SERVER
MAIL_SERVER=${MAIL_SERVER:-smtp.gmail.com}

read -p "Port SMTP [587]: " MAIL_PORT
MAIL_PORT=${MAIL_PORT:-587}

read -p "Nom d'utilisateur (email) []: " MAIL_USERNAME
if [ -z "$MAIL_USERNAME" ]; then
    print_error "Le nom d'utilisateur est requis"
    exit 1
fi

read -sp "Mot de passe/App-password []: " MAIL_PASSWORD
echo ""
if [ -z "$MAIL_PASSWORD" ]; then
    print_error "Le mot de passe est requis"
    exit 1
fi

read -p "Email à envoyer les notifications []: " NOTIFICATION_EMAIL
if [ -z "$NOTIFICATION_EMAIL" ]; then
    print_error "L'email de notification est requis"
    exit 1
fi

read -p "Email expéditeur [ci-pipeline@example.com]: " MAIL_FROM
MAIL_FROM=${MAIL_FROM:-ci-pipeline@example.com}

# ============================================================================
# DÉFINIR LES SECRETS
# ============================================================================

print_header "Ajout des secrets à GitHub"

# Email Notification
gh secret set MAIL_SERVER -b "$MAIL_SERVER" -R "$OWNER/$REPO"
print_success "Secret MAIL_SERVER ajouté"

gh secret set MAIL_PORT -b "$MAIL_PORT" -R "$OWNER/$REPO"
print_success "Secret MAIL_PORT ajouté"

gh secret set MAIL_USERNAME -b "$MAIL_USERNAME" -R "$OWNER/$REPO"
print_success "Secret MAIL_USERNAME ajouté"

gh secret set MAIL_PASSWORD -b "$MAIL_PASSWORD" -R "$OWNER/$REPO"
print_success "Secret MAIL_PASSWORD ajouté"

gh secret set NOTIFICATION_EMAIL -b "$NOTIFICATION_EMAIL" -R "$OWNER/$REPO"
print_success "Secret NOTIFICATION_EMAIL ajouté"

gh secret set MAIL_FROM -b "$MAIL_FROM" -R "$OWNER/$REPO"
print_success "Secret MAIL_FROM ajouté"

# ============================================================================
# SECRETS OPTIONNELS
# ============================================================================

print_header "Secrets Optionnels"

read -p "Ajouter secret CODECOV_TOKEN ? (y/n) [n]: " add_codecov
if [[ "$add_codecov" =~ ^[Yy]$ ]]; then
    read -sp "CODECOV_TOKEN: " CODECOV_TOKEN
    echo ""
    gh secret set CODECOV_TOKEN -b "$CODECOV_TOKEN" -R "$OWNER/$REPO"
    print_success "Secret CODECOV_TOKEN ajouté"
fi

read -p "Ajouter secret SLACK_WEBHOOK_URL ? (y/n) [n]: " add_slack
if [[ "$add_slack" =~ ^[Yy]$ ]]; then
    read -sp "SLACK_WEBHOOK_URL: " SLACK_WEBHOOK_URL
    echo ""
    gh secret set SLACK_WEBHOOK_URL -b "$SLACK_WEBHOOK_URL" -R "$OWNER/$REPO"
    print_success "Secret SLACK_WEBHOOK_URL ajouté"
fi

# ============================================================================
# RÉSUMÉ
# ============================================================================

print_header "Résumé de Configuration"

echo "✅ Secrets configurés pour: $OWNER/$REPO"
echo ""
echo "Secrets créés:"
echo "  - MAIL_SERVER"
echo "  - MAIL_PORT"
echo "  - MAIL_USERNAME"
echo "  - MAIL_PASSWORD"
echo "  - NOTIFICATION_EMAIL"
echo "  - MAIL_FROM"
echo ""

print_warning "Les secrets sont chiffrés dans GitHub. Vous ne pouvez pas les récupérer."
print_warning "Conservez une copie sécurisée de ces valeurs."

# ============================================================================
# VÉRIFICATION
# ============================================================================

print_header "Vérification des Secrets"

echo "Listing les secrets configurés :"
gh secret list -R "$OWNER/$REPO"

# ============================================================================
# RESSOURCES
# ============================================================================

print_header "Prochaines étapes"

echo "1. Vérifier que les secrets sont visibles dans Settings > Secrets and variables > Actions"
echo "2. Tester le pipeline en créant une PR ou un push"
echo "3. Consulter les logs du workflow dans Actions > CI workflow"
echo ""
echo "Documentation:"
echo "  - https://docs.github.com/en/actions/security-guides/encrypted-secrets"
echo "  - https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions"
echo ""

print_success "Configuration terminée ! ✨"
