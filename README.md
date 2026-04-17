# 🚀 Application Python - Pipeline CI/CD DevSecOps

![CI Pipeline Status](https://github.com/YOUR_ORG/YOUR_REPO/actions/workflows/ci.yml/badge.svg?branch=main)
![Python Version](https://img.shields.io/badge/python-3.9%2B-blue)
![Code Coverage](https://codecov.io/gh/YOUR_ORG/YOUR_REPO/branch/main/graph/badge.svg)
![Security Scan](https://img.shields.io/badge/security-scanned-brightgreen)
![License](https://img.shields.io/badge/license-MIT-green)

## 📋 Table des Matières

- [À propos](#à-propos)
- [Installation](#installation)
- [Utilisation](#utilisation)
- [Pipeline CI/CD](#pipeline-cicd)
- [Sécurité](#sécurité)
- [Contribution](#contribution)
- [Support](#support)

---

## 📖 À propos

Application Python professionnel avec **pipeline CI/CD sécurisé** intégrant :

✅ **Tests automatisés** (pytest)
✅ **Linting & Formatage** (flake8, Black)
✅ **Analyse de code** (CodeQL, Bandit)
✅ **Scan de dépendances** (Safety, pip-audit)
✅ **Détection de secrets** (TruffleHog, GitLeaks)
✅ **Notifications par email**

---

## 🚀 Installation

### Prérequis

- Python 3.9+
- pip (Python package manager)
- Git
- (Optionnel) GitHub CLI (`gh`)

### Setup Local

```bash
# 1. Cloner le repository
git clone https://github.com/YOUR_ORG/YOUR_REPO.git
cd YOUR_REPO

# 2. Créer un environnement virtuel
python3.11 -m venv venv

# 3. Activer l'environnement
# Linux/Mac:
source venv/bin/activate
# Windows:
venv\Scripts\activate

# 4. Installer les dépendances
pip install --upgrade pip
pip install -r requirements.txt
pip install -r requirements-dev.txt

# 5. Configurer les variables d'environnement
cp .env.example .env
# Éditer .env avec vos valeurs
nano .env

# 6. Tester l'installation
python -c "import app; print('✅ Installation OK')"
```

---

## 🔧 Utilisation

### Tests Locaux

```bash
# Exécuter tous les tests
pytest tests/ -v

# Tests avec couverture
pytest tests/ --cov=src --cov-report=html
# Ouvrir htmlcov/index.html dans le navigateur

# Tests spécifiques
pytest tests/test_auth.py::test_login -v

# Tests en parallèle
pytest tests/ -n auto
```

### Vérification du Code

```bash
# Linting (PEP 8)
flake8 src/

# Formatage (vérifier)
black --check .

# Formatage (appliquer)
black .

# Analyse avancée
pylint src/

# Type checking
mypy src/
```

### Sécurité Locale

```bash
# Vérifier les secrets exposés
detect-secrets scan

# Analyser les vulnérabilités des dépendances
safety check
pip-audit

# Analyse de sécurité du code
bandit -r src/
```

---

## 🔒 Pipeline CI/CD

### Architecture

Le pipeline s'exécute automatiquement sur chaque **push** ou **pull request** vers `main`.

```
CODE → LINT → TEST → SCA → SAST → SECRET SCAN → QUALITY → REPORT → EMAIL
```

### Jobs

| Job | Durée | Objectif |
|-----|-------|----------|
| **Setup** | 30s | Validation du repo |
| **Build & Test** | 3-5 min | Pytest sur Python 3.9-3.12 |
| **Dependency Scan** | 1-2 min | Safety + pip-audit |
| **Secret Scan** | 1-2 min | TruffleHog + GitLeaks |
| **Code Analysis** | 2-3 min | CodeQL + Bandit |
| **Code Quality** | 1-2 min | radon + pylint |
| **Security Summary** | 1 min | Report consolidation |
| **Email** | <1 min | Notification |

**Durée totale** : ~8-15 minutes

### Statut du Pipeline

Consulter le statut en direct :
- 🟢 **Passing** : Tous les checks OK
- 🔴 **Failing** : Un check ou plus a échoué
- 🟡 **In Progress** : Pipeline en cours
- ⚪ **Queued** : En attente d'exécution

**Accès** : Repository > Actions > Workflows > CI - Build & Test Python Application

### Échecs & Debugging

#### Cas 1 : Test échoue
```bash
# Reproduire localement
pytest tests/test_failing.py -v

# Ou dans le même environnement Python
python3.11 -m venv venv-test
source venv-test/bin/activate
pip install -r requirements.txt
pytest tests/
```

#### Cas 2 : Couverture insuffisante
```bash
# Consulter les ligne non couvertes
pytest --cov=src --cov-report=html
# Ouvrir htmlcov/index.html
# Ajouter des tests pour les lignes manquantes
```

#### Cas 3 : Linting échoue
```bash
# Voir les erreurs
flake8 src/

# Fixer automatiquement
black .
autopep8 --in-place -r .
```

#### Cas 4 : Vulnérabilité détectée
```bash
# Identifier la vulnérabilité
safety check --json

# Mettre à jour le package
pip install --upgrade vulnerable-package

# Vérifier la fix
safety check
```

#### Cas 5 : Secret détecté
```bash
# 🚨 ALERTE SÉCURITÉ !

# 1. Déterminer le secret
cat trufflehog-report.json | grep -i "secret"

# 2. Rotate la clé compromise IMMÉDIATEMENT
# Ex: Changer le mot de passe DB, regenerer API key, etc.

# 3. Supprimer le secret du git
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch <secret-file>' \
  --prune-empty --tag-name-filter cat -- --all

# 4. Force push
git push --force --all

# 5. Investiguer post-mortem
# Qui a committé?
# Comment s'est-ce passé?
# Comment l'éviter?
```

---

## 🛡️ Sécurité

### Bonnes Pratiques

✅ **Secrets** : Jamais hardcodés, toujours dans `.env` ou GitHub Secrets
✅ **Dépendances** : Mises à jour automatiques via Dependabot
✅ **Tests** : Coverage ≥ 70%, tous les tests doivent passer
✅ **Code** : Scan CodeQL + Bandit obligatoires
✅ **Logs** : Pas de données sensibles dans les logs

### Gestion des Secrets

```python
# ✅ BON
import os
from dotenv import load_dotenv

load_dotenv()
api_key = os.getenv("API_KEY")
```

```python
# ❌ MAUVAIS
api_key = "sk_live_abc123"  # JAMAIS !
```

### Signaler une Vulnérabilité

**⚠️ NE PAS créer une issue publique !**

Envoyer un email confidentiel à : `security@example.com`

Voir [SECURITY.md](./SECURITY.md) pour plus de détails.

---

## 🤝 Contribution

### Processus de Contribution

1. **Fork** le repository
2. **Créer une branche** : `git checkout -b feature/ma-feature`
3. **Committer** les changements : `git commit -m "feat: add new feature"`
4. **Pousser** : `git push origin feature/ma-feature`
5. **Créer une Pull Request**

### Avant de Soumettre

```bash
# 1. Passer tous les checks locaux
pytest tests/ -v --cov=src
flake8 src/
black --check .
bandit -r src/
safety check

# 2. Mettre à jour la documentation
# 3. Ajouter des tests pour les nouvelles fonctionnalités
# 4. S'assurer que la couverture > 70%
```

### Checklist PR

- [ ] Tests ajoutés/mis à jour
- [ ] Couverture > 70%
- [ ] Linting passe
- [ ] Pas de secrets committes
- [ ] Documentation à jour
- [ ] Changelog mis à jour

---

## 📊 Badges & Métriques

### Status Badges

Ajouter ces badges à votre README :

```markdown
# GitHub Actions
![CI](https://github.com/YOUR_ORG/YOUR_REPO/actions/workflows/ci.yml/badge.svg?branch=main)

# CodeCov
[![codecov](https://codecov.io/gh/YOUR_ORG/YOUR_REPO/branch/main/graph/badge.svg)](https://codecov.io/gh/YOUR_ORG/YOUR_REPO)

# Python Version
![Python](https://img.shields.io/badge/python-3.9%2B-blue)

# License
![License](https://img.shields.io/badge/license-MIT-green)

# Security
![Security Scan](https://img.shields.io/badge/security-scanned-brightgreen)
```

### Liens Utiles

- [Workflow Status](https://github.com/YOUR_ORG/YOUR_REPO/actions)
- [Code Coverage](https://codecov.io/gh/YOUR_ORG/YOUR_REPO)
- [Security Alerts](https://github.com/YOUR_ORG/YOUR_REPO/security/alerts)
- [Dependabot](https://github.com/YOUR_ORG/YOUR_REPO/dependabot)

---

## 📚 Documentation

- [Pipeline CI/CD](./PIPELINE-DOCUMENTATION.md) - Guide détaillé du pipeline
- [Politique de Sécurité](./SECURITY.md) - Politique sécurité & incident response
- [Configuration](./docs/CONFIGURATION.md) - Setup avancé
- [API](./docs/API.md) - Documentation API

---

## 🐛 Signaler un Bug

Créer une issue avec :
1. **Title** : Courte description du bug
2. **Description** : Reproduction steps, comportement attendu, logs
3. **Environnement** : OS, Python version, config
4. **Priorité** : Critical/High/Medium/Low

Exemple :
```
Title: Login fails with special characters

Description:
When attempting to login with special characters in password (e.g., @#$%),
the authentication fails with HTTP 500.

Steps to Reproduce:
1. Go to login page
2. Enter username: test@example.com
3. Enter password: p@ssw0rd!
4. Click Login
5. See error

Expected: Successful login
Actual: HTTP 500 error

Environment:
- OS: Ubuntu 22.04
- Python: 3.11
- Browser: Chrome 121
```

---

## 📞 Support

- 📧 **Email** : support@example.com
- 💬 **Slack** : [Workspace](https://slack.com)
- 🐛 **Issues** : [GitHub Issues](https://github.com/YOUR_ORG/YOUR_REPO/issues)
- 📖 **Docs** : [Documentation](./docs)

---

## 📄 License

MIT License - voir [LICENSE](./LICENSE) pour détails

---

## 👥 Contributors

- [Your Name](https://github.com/yourname)
- [Other Contributors](https://github.com/YOUR_ORG/YOUR_REPO/graphs/contributors)

---

## 🙏 Remerciements

- [GitHub Actions](https://github.com/features/actions)
- [OWASP](https://owasp.org/)
- [Python Community](https://python.org)

---

## 📈 Roadmap

- [ ] Performance testing
- [ ] Load testing
- [ ] SonarQube integration
- [ ] SBOM generation
- [ ] Kubernetes deployment
- [ ] Multi-region setup

---

**Dernière mise à jour** : 2024-04-17
**Mainteneur** : DevSecOps Team
# test pipeline
test ci
trigger pipeline
trigger ci test
