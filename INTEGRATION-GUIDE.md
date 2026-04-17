# 🚀 Guide d'Intégration du Pipeline CI/CD DevSecOps

Ce guide vous accompagne à travers chaque étape pour intégrer le pipeline CI/CD sécurisé à votre projet Python.

## 📋 Checklist d'Intégration

- [ ] Phase 1 : Préparation
- [ ] Phase 2 : Configuration Locale
- [ ] Phase 3 : Intégration GitHub
- [ ] Phase 4 : Tests & Validation
- [ ] Phase 5 : Activation & Monitoring
- [ ] Phase 6 : Amélioration Continue

---

## Phase 1️⃣ : Préparation (5 minutes)

### 1.1 Vérifier les Prérequis

```bash
# Python 3.9+
python --version
# Output: Python 3.11.x (ou supérieur)

# Git
git --version
# Output: git version 2.40.0 (ou supérieur)

# GitHub CLI (optionnel mais recommandé)
gh --version
# Output: gh version 2.45.0 (ou supérieur)
```

### 1.2 Créer une Branche de Travail

```bash
# Clone ou naviguez vers le repo
cd votre-repo

# Créer une branche pour les changements
git checkout -b setup/add-devsecops-pipeline
```

### 1.3 Créer la Structure des Répertoires

```bash
# Créer les répertoires nécessaires
mkdir -p .github/workflows
mkdir -p .github/
mkdir -p scripts
mkdir -p tests          # Si non existant

# Vérifier la structure
tree -L 2 .github
# Output:
# .github/
# ├── SECURITY.md
# ├── dependabot.yml
# └── workflows/
#     └── ci.yml
```

---

## Phase 2️⃣ : Configuration Locale (15 minutes)

### 2.1 Copier les Fichiers de Configuration

```bash
# Depuis le répertoire de ce projet, copier :

# Configuration pytest
cp pytest.ini votre-repo/

# Configuration flake8
cp .flake8 votre-repo/

# Configuration Black/isort
cp pyproject-config.toml votre-repo/pyproject.toml  # Ou merger

# Configuration pre-commit
cp .pre-commit-config.yaml votre-repo/

# Configuration .gitignore
cat .gitignore >> votre-repo/.gitignore

# Variables d'environnement
cp .env.example votre-repo/
```

### 2.2 Copier les Fichiers Workflow

```bash
# Workflow principal
cp ci.yml votre-repo/.github/workflows/ci.yml

# Configuration Dependabot
cp dependabot.yml votre-repo/.github/dependabot.yml

# Politique sécurité
cp SECURITY.md votre-repo/.github/SECURITY.md

# Documentation
cp PIPELINE-DOCUMENTATION.md votre-repo/docs/PIPELINE.md
cp README.md votre-repo/README-NEW.md  # À merger
```

### 2.3 Copier les Scripts de Setup

```bash
# Script de configuration des secrets
cp setup-github-secrets.sh votre-repo/scripts/
chmod +x votre-repo/scripts/setup-github-secrets.sh
```

### 2.4 Copier les Fichiers de Dépendances

```bash
# Dépendances de développement
cp requirements-dev.txt votre-repo/

# Vérifier/merger requirements.txt (dépendances production)
# Vous devez avoir requirements.txt avec les packages nécessaires
```

### 2.5 Mettre à Jour requirements-dev.txt

```bash
# Ajouter à votre requirements-dev.txt si non présent
cat requirements-dev.txt >> votre-repo/requirements-dev.txt

# Remover les doublons
sort -u votre-repo/requirements-dev.txt -o votre-repo/requirements-dev.txt
```

### 2.6 Créer des Tests de Base (si absent)

```bash
# Si vous n'avez pas de tests, en créer une structure
mkdir -p tests

# Créer tests/__init__.py (vide)
touch tests/__init__.py

# Créer tests/test_example.py
cat > tests/test_example.py << 'EOF'
"""Tests unitaires d'exemple."""

def test_basic():
    """Test basique pour vérifier le setup pytest."""
    assert 1 + 1 == 2
    assert "hello" in "hello world"

def test_failure_is_caught():
    """Test qui montre comment un échec est capturé."""
    try:
        assert False
    except AssertionError:
        pass  # Expected
EOF
```

---

## Phase 3️⃣ : Intégration GitHub (20 minutes)

### 3.1 Pousser les Changements Locaux

```bash
# Vérifier les changements
git status

# Ajouter tous les fichiers
git add .github/ scripts/ tests/ \
  pytest.ini .flake8 pyproject.toml \
  requirements-dev.txt .gitignore .env.example \
  .pre-commit-config.yaml PIPELINE-DOCUMENTATION.md

# Commit
git commit -m "chore: add DevSecOps CI/CD pipeline"

# Pousser
git push origin setup/add-devsecops-pipeline
```

### 3.2 Créer une Pull Request

```bash
# Via GitHub CLI
gh pr create --title "Add DevSecOps CI/CD Pipeline" \
  --body "
  This PR introduces a comprehensive CI/CD pipeline with:
  - Automated testing (pytest)
  - Code linting (flake8, Black)
  - Security scanning (CodeQL, Bandit)
  - Dependency scanning (Safety, pip-audit)
  - Secret detection (TruffleHog, GitLeaks)
  - Email notifications
  
  See PIPELINE-DOCUMENTATION.md for details.
  " \
  --base main \
  --head setup/add-devsecops-pipeline

# Ou manuellement via GitHub Web UI:
# 1. Repository > Pull requests > New pull request
# 2. Sélectionner main comme base
# 3. Sélectionner setup/add-devsecops-pipeline comme compare
# 4. Remplir titre et description
# 5. Create pull request
```

### 3.3 Configurer les Secrets GitHub

```bash
# Exécuter le script de setup
bash scripts/setup-github-secrets.sh

# Le script vous demandera:
# - MAIL_SERVER (ex: smtp.gmail.com)
# - MAIL_PORT (ex: 587)
# - MAIL_USERNAME (votre email)
# - MAIL_PASSWORD (app password)
# - NOTIFICATION_EMAIL (où recevoir les emails)
# - MAIL_FROM (email expéditeur)

# Vérifier via Settings > Secrets and variables > Actions
```

### 3.4 Activer les Features de Sécurité

```bash
# Via l'interface GitHub:
# Settings > Code security and analysis

# Activer:
# ☑️ Dependency graph
# ☑️ Dependabot alerts
# ☑️ Dependabot security updates
# ☑️ Code scanning (CodeQL)
# ☑️ Secret scanning (optionnel avec GitHub Pro+)
```

### 3.5 Protéger la Branche Main

```bash
# Via Settings > Branches > Add rule

# Configure:
Branch pattern: main

# ☑️ Require a pull request before merging
    # ☑️ Require approvals: 1
    # ☑️ Dismiss stale pull request approvals
    # ☑️ Require review from code owners

# ☑️ Require status checks to pass before merging
    # ☑️ Require branches to be up to date

# ☑️ Require conversation resolution before merging

# ☑️ Include administrators
```

### 3.6 Approuver et Merger la PR

```bash
# Attendre que le pipeline CI/CD passe
# GitHub Actions > CI - Build & Test > ✅ All checks passed

# Approuver la PR (si nécessaire)
gh pr review <PR_NUMBER> --approve

# Merger
gh pr merge <PR_NUMBER> --merge  # ou --squash / --rebase
```

---

## Phase 4️⃣ : Tests & Validation (10 minutes)

### 4.1 Vérifier l'Exécution Locale

```bash
# Installer les dépendances de développement
pip install -r requirements-dev.txt

# Exécuter les tests
pytest tests/ -v --cov=src

# Exécuter le linting
flake8 src/
black --check .

# Exécuter la sécurité
bandit -r src/
safety check
detect-secrets scan
```

### 4.2 Vérifier les Workflows GitHub

```bash
# Via GitHub Web UI:
# Repository > Actions

# Vérifier:
# ✅ Workflow "CI - Build & Test" présent
# ✅ Badges affichés
# ✅ Historique des runs

# Cliquer sur le dernier run:
# - ✅ Setup & Validate
# - ✅ Build & Test (Python 3.9-3.12)
# - ✅ Dependency Scan
# - ✅ Secret Scan
# - ✅ Code Analysis (SAST)
# - ✅ Code Quality
# - ✅ Security Summary
# - ✅ Email Notification
```

### 4.3 Vérifier les Secrets

```bash
# Via GitHub CLI
gh secret list --repo YOUR_ORG/YOUR_REPO

# Output:
# MAIL_FROM      Updated 2024-04-17 14:30:00
# MAIL_PASSWORD  Updated 2024-04-17 14:30:00
# MAIL_PORT      Updated 2024-04-17 14:30:00
# MAIL_SERVER    Updated 2024-04-17 14:30:00
# MAIL_USERNAME  Updated 2024-04-17 14:30:00
# NOTIFICATION_EMAIL Updated 2024-04-17 14:30:00
```

### 4.4 Tester une Notification Email

```bash
# Créer un commit de test
echo "# Test" >> README.md
git add README.md
git commit -m "test: trigger CI pipeline"
git push

# Attendre la fin du workflow (~10 minutes)
# Vérifier que vous avez reçu un email de notification

# Supprimer le commit de test (optionnel)
git revert HEAD
git push
```

---

## Phase 5️⃣ : Activation & Monitoring (5 minutes)

### 5.1 Activer Pre-commit Hooks Locaux

```bash
# Installer pre-commit
pip install pre-commit

# Setup les hooks
pre-commit install

# Test sur les fichiers existants
pre-commit run --all-files

# À partir de maintenant, les hooks s'exécutent avant chaque commit
```

### 5.2 Configurer Notifications Slack (Optionnel)

Si vous utilisez Slack, ajouter notification :

```yaml
# .github/workflows/ci.yml - ajouter après notify-email job

  notify-slack:
    name: 📱 Slack Notification
    runs-on: ubuntu-latest
    needs: [build-and-test, security-summary]
    if: always()
    steps:
      - name: Send Slack Message
        uses: slackapi/slack-github-action@v1.24.0
        with:
          webhook-url: ${{ secrets.SLACK_WEBHOOK }}
          payload: |
            {
              "text": "Pipeline Status: ${{ needs.security-summary.result }}",
              "blocks": [
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "*CI Pipeline Result*\nRepository: ${{ github.repository }}\nBranch: ${{ github.ref_name }}\nStatus: ${{ needs.security-summary.result }}"
                  }
                }
              ]
            }
```

### 5.3 Ajouter Badge de Statut au README

```markdown
# Top du README

![CI Pipeline Status](https://github.com/YOUR_ORG/YOUR_REPO/actions/workflows/ci.yml/badge.svg?branch=main)
![Python Version](https://img.shields.io/badge/python-3.9%2B-blue)
![License](https://img.shields.io/badge/license-MIT-green)

# ... reste du README
```

### 5.4 Configurer CodeCov (Optionnel)

```bash
# Créer compte sur https://codecov.io
# Connecter GitHub
# Repository sera créé automatiquement

# (Pas besoin de token si repo public)
# Pour repo privé, ajouter CODECOV_TOKEN secret
gh secret set CODECOV_TOKEN -b "your_token"

# Vérifier: https://codecov.io/gh/YOUR_ORG/YOUR_REPO
```

---

## Phase 6️⃣ : Amélioration Continue (Ongoing)

### 6.1 Monitoring Hebdomadaire

```bash
# Chaque lundi matin :

# 1. Vérifier les alertes Dependabot
# GitHub > Security > Dependabot alerts

# 2. Examiner le rapport de couverture
# https://codecov.io/gh/YOUR_ORG/YOUR_REPO

# 3. Vérifier les tendances CodeQL
# GitHub > Security > Code scanning

# 4. Consulter les logs du pipeline
# GitHub > Actions > Workflows
```

### 6.2 Améliorer la Couverture de Code

```bash
# Identifier les lignes non couvertes
pytest --cov=src --cov-report=html tests/

# Ouvrir htmlcov/index.html
# Ajouter des tests pour les lignes manquantes

# Target: 70% (minimum) → 80% (bon) → 90% (excellent)
```

### 6.3 Réduire Faux Positifs

```bash
# Si bandit détecte des faux positifs
# .bandit (créer si nécessaire)
[bandit]
exclude_dirs = ['/venv/', '/tests/', '/docs/']
skips = B101  # assert_used

# Ou dans le code:
# noinspection Bandit
password = user_input  # nosec
```

### 6.4 Automatiser les Dépendances

Dependabot créera automatiquement des PRs :
- Chaque lundi pour les dépendances Python
- Chaque mardi pour les GitHub Actions

```yaml
# Ces PRs :
# - Ont un review automatique (optionnel)
# - Peuvent être mergées automatiquement (optionnel)
# - Suivent les règles de branche protection

# Configuration: .github/dependabot.yml
automerge-strategy: auto  # Auto-merge les mises à jour de sécurité
```

---

## 🎯 Checkpoints de Validation

### Après Phase 1
- [ ] Repo créé/actualisé
- [ ] Branche de travail créée

### Après Phase 2
- [ ] Fichiers de config copiés
- [ ] Dépendances installées localement
- [ ] Tests locaux passent

### Après Phase 3
- [ ] PR créée et approved
- [ ] Secrets configurés
- [ ] Branche main protégée

### Après Phase 4
- [ ] Pipeline s'exécute avec succès
- [ ] Email reçu
- [ ] Artifacts uploadés

### Après Phase 5
- [ ] Pre-commit hooks actifs
- [ ] Badge affiché sur README
- [ ] CodeCov connecté (optionnel)

### Après Phase 6
- [ ] Monitoring hebdomadaire en place
- [ ] Processus de review automatisé
- [ ] Dépendances mises à jour automatiquement

---

## 🆘 Troubleshooting

### Problème 1 : Workflow ne se déclenche pas

```bash
# Vérifier:
# 1. Fichier .github/workflows/ci.yml existe
# 2. Syntaxe YAML correcte
#    yamllint .github/workflows/ci.yml
# 3. Branche main existe et est protégée
# 4. GitHub Actions activés dans Settings > Actions
```

### Problème 2 : Secrets non reconnus

```bash
# Vérifier:
# 1. Secrets sont dans Settings > Secrets
# 2. Nom exact dans workflow matches secret name
# 3. Pas d'espaces extra dans le nom
# 4. Réintégrez le secret si doute
gh secret delete MAIL_SERVER
gh secret set MAIL_SERVER -b "value"
```

### Problème 3 : Email ne s'envoie pas

```bash
# Tester la configuration SMTP:
python3 << 'EOF'
import smtplib
from email.mime.text import MIMEText

smtp_server = "smtp.gmail.com"
smtp_port = 587
username = "your_email@gmail.com"
password = "your_app_password"

try:
    server = smtplib.SMTP(smtp_server, smtp_port)
    server.starttls()
    server.login(username, password)
    print("✅ SMTP connection successful")
    server.quit()
except Exception as e:
    print(f"❌ Error: {e}")
EOF
```

### Problème 4 : Dépendance non trouvée

```bash
# Vérifier requirements.txt
pip install -r requirements.txt

# Ou installer manuellement
pip install missing-package

# Ajouter à requirements.txt
echo "missing-package==1.0.0" >> requirements.txt
```

---

## 📞 Support & Ressources

- 📖 [Documentation du Pipeline](./PIPELINE-DOCUMENTATION.md)
- 🛡️ [Politique de Sécurité](./.github/SECURITY.md)
- 🔗 [GitHub Actions Docs](https://docs.github.com/en/actions)
- 🐍 [Python Best Practices](https://pep8.org/)
- 🐛 Issues: Créer une issue avec label `setup-help`

---

**Durée totale estimée** : ~60 minutes

**Prochaines étapes** : Consulter [PIPELINE-DOCUMENTATION.md](./PIPELINE-DOCUMENTATION.md) pour détails avancés.

🎉 **Félicitations!** Votre pipeline CI/CD DevSecOps est prêt!
