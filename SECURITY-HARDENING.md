# 🔐 Guide Avancé : Sécurité & Hardening du Pipeline CI/CD

Ce guide couvre les meilleures pratiques de sécurité avancée pour durcir votre pipeline CI/CD.

## Table des Matières

1. [Permissions & Accès](#permissions--accès)
2. [Gestion des Secrets](#gestion-des-secrets)
3. [Workflow Security](#workflow-security)
4. [Dépendances & Supply Chain](#dépendances--supply-chain)
5. [Audit & Compliance](#audit--compliance)
6. [Response à Incidents](#response-à-incidents)

---

## 🔑 Permissions & Accès

### Principe du Moindre Privilège (PoLP)

Tous les workflows doivent fonctionner avec les permissions minimales requises.

#### ✅ BON : Permissions Explicites

```yaml
permissions:
  contents: read           # Lire le code
  checks: write            # Écrire les résultats des tests
  pull-requests: write     # Commenter les PRs
  security-events: write   # Rapporter les alertes sécurité
  
  # NON utilisées:
  # actions: none
  # deployments: none
  # issues: none
  # packages: none
```

#### ❌ MAUVAIS : Permissions Permissives

```yaml
# ❌ À ÉVITER ABSOLUMENT
permissions: write-all  # Donne accès à TOUT !

# Ou pas de restriction du tout :
# (permissions héritées par défaut - trop permissif)
```

#### Configuration au Niveau du Job

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read    # Spécifique à ce job
      
  deploy:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      deployments: write
```

### Gestion des Accès Administrateurs

```yaml
# ✅ N'utiliser les permissions admin que si strictement nécessaire

# Exemple : Utiliser un compte de service dédié
jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      contents: write     # Seulement pour ce job
    steps:
      - uses: actions/checkout@v4
      - name: Deploy
        # Utiliser un token scoped (déployment-specific)
        env:
          DEPLOY_TOKEN: ${{ secrets.DEPLOY_TOKEN }}
        run: ./deploy.sh
```

### Protection des Secrets

```bash
# Vérifier les permissions des secrets
# Settings > Secrets and variables > Actions

# Pour chaque secret :
# ☑️ Seulement visible dans les workflows
# ☑️ Pas accessible via l'interface Web
# ☑️ Jamais affiché dans les logs
```

---

## 🔐 Gestion des Secrets

### 1. Création Sécurisée

```bash
# ✅ BON : Créer via GitHub CLI (chiffré immédiatement)
gh secret set MY_API_KEY -b "sk_live_abc123" \
  --repo YOUR_ORG/YOUR_REPO

# ❌ MAUVAIS : Copier/coller dans l'interface
# Visible temporairement en mémoire
```

### 2. Rotation Régulière

```bash
# Chaque 90 jours minimum
# Créer nouvelle clé
# Remplacer l'ancienne dans GitHub Secrets
# Vérifier que le workflow utilise la nouvelle

# Script de rotation (à scheduler)
#!/bin/bash
# rotation-secrets.sh

# 1. Générer nouvelle clé
NEW_API_KEY=$(openssl rand -hex 32)

# 2. Tester la nouvelle clé dans un environnement de test
curl https://api.example.com/test \
  -H "Authorization: Bearer $NEW_API_KEY"

# 3. Mettre à jour le secret
gh secret set API_KEY -b "$NEW_API_KEY"

# 4. Logger l'action
echo "Secret rotated on $(date)" >> rotation-log.txt
```

### 3. Audit des Secrets

```bash
# Archiver les anciens secrets chiffrés
# Format: SECRET_NAME | DATE | STATUS

# Exemple audit log (chiffré dans un vault sécurisé):
# API_KEY | 2024-04-17 | active
# API_KEY_OLD | 2024-01-17 | rotated
# DB_PASSWORD | 2024-04-17 | active

# Ne JAMAIS stocker le contenu des secrets !
# Juste les métadonnées (nom, date, status)
```

### 4. Scanning de Secrets Committes

```bash
# Utiliser plusieurs outils

# 1. TruffleHog (entropy-based)
docker run trufflesecurity/trufflehog:latest \
  filesystem --json /workspace | \
  grep -i "verified: true"  # Seulement les vrais secrets

# 2. GitLeaks
gitleaks detect --source github --verbose

# 3. GitHub Native (Secret Scanning)
# Settings > Code security and analysis > Secret scanning
# ☑️ Activer "Push protection"
# ☑️ Empêcher le push si secret détecté
```

---

## ⚙️ Workflow Security

### 1. Versions Épinglées (Pin Versions)

#### ✅ BON : Utiliser SHA au lieu de tags mutables

```yaml
# ❌ RISQUÉ : Tag peut être changé par l'auteur
- uses: actions/checkout@v4

# ✅ SÛRE : Impossible de changer
- uses: actions/checkout@a81bea1b9c6f2f1d4e936cdc00a81a7fde38f11d
```

**Comment obtenir le SHA :**
```bash
# Via le web
# https://github.com/actions/checkout/releases/tag/v4
# Copier le full commit SHA

# Ou via CLI
gh api repos/actions/checkout/commits \
  --jq '.[0].commit.author.date' | head -1
```

#### Mettre à Jour Automatiquement

```bash
# pre-commit hook pour vérifier les versions
#!/bin/bash
if grep '@v[0-9]' .github/workflows/*.yml; then
  echo "❌ Workflows contiennent des versions mutables!"
  echo "Utiliser les SHAs à la place"
  exit 1
fi
```

### 2. Contexts Sécurisés

#### ✅ BON : Contexts Sûrs

```yaml
# Contexts sûrs (GitHub-trusted)
- name: Print safe context
  run: |
    echo "Ref: ${{ github.ref }}"
    echo "SHA: ${{ github.sha }}"
    echo "Actor: ${{ github.actor }}"  # ← User qui a triggé
```

#### ❌ RISQUÉ : Contexts Non-Vérifiés

```yaml
# ❌ JAMAIS utiliser les contexts PR non-vérifiés
# dans les environnements sensibles

- name: Use PR context (dangerous)
  if: github.event_name == 'pull_request'
  run: |
    # ❌ Le contenu vient d'une PR (code non-vérifiée)
    echo "PR body: ${{ github.event.pull_request.body }}"
```

#### Séparer les Workflows PR et Push

```yaml
# ✅ BON : Workflows distincts

# workflow-pr-tests.yml (sandbox)
on:
  pull_request:
    branches: [main]
jobs:
  test:
    runs-on: ubuntu-latest
    permissions:
      contents: read
    # Pas d'accès aux secrets!

# workflow-ci-push.yml (production)
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    # Accès complet aux secrets
```

### 3. Actions Vérifiées

```yaml
# ✅ Utiliser uniquement les actions officielles/vérifiées
- uses: actions/checkout@v4           # ✅ Official
- uses: actions/setup-python@v5       # ✅ Official
- uses: dawidd6/action-send-mail@v3   # ⚠️ Community (vérifiée)

# ❌ Éviter les actions inconnues/non-vérifiées
# - uses: random-user/sketchy-action@v1

# Vérifier:
# 1. Nombre de stars/forks
# 2. Dernière mise à jour (active?)
# 3. Nombre de contributeurs
# 4. Code review du source
```

### 4. Isolation des Environnements

```yaml
jobs:
  # ✅ Tests : environnement sandbox
  test:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      checks: write
    # Pas de secrets disponibles
    
  # ✅ Deploy : environnement protégé
  deploy:
    runs-on: ubuntu-latest
    needs: test  # Dépend du succès de test
    if: github.ref == 'refs/heads/main'
    permissions:
      contents: read
      deployments: write
    environment:
      name: production
      url: https://api.example.com
    # Secrets disponibles seulement ici
```

---

## 📦 Dépendances & Supply Chain

### 1. Vérifier les Dépendances

```yaml
# ✅ Dans le workflow
- name: Check dependencies
  run: |
    safety check --json > safety-report.json
    
    # Fail si vulnérabilités CRÍTICA
    jq -e '.vulnerability_count > 0' safety-report.json && \
      echo "❌ Critical vulnerabilities found" && exit 1
    
    echo "✅ No critical vulnerabilities"
```

### 2. Allowlist de Dépendances

```yaml
# policies/allowed-dependencies.yaml
allowed:
  # Core
  - flask>=2.0.0,<3.0.0
  - sqlalchemy>=1.4,<2.0
  - requests>=2.31.0
  
  # Testing
  - pytest>=7.0
  - pytest-cov>=4.0
  
denied:
  # Packages à éviter
  - old-package
  - unmaintained-lib
  
  # Versioning known-vulnerable
  - requests==2.25.0  # CVE-2021-1234
```

### 3. SBOM (Software Bill of Materials)

```bash
# Générer SBOM pour audit supply chain
pip install cyclonedx-bom

cyclonedx-bom -o requirements.txt -F json -O sbom.json

# Output: sbom.json
# {
#   "bomFormat": "CycloneDX",
#   "specVersion": "1.4",
#   "components": [
#     {
#       "type": "library",
#       "name": "requests",
#       "version": "2.31.0",
#       "purl": "pkg:pypi/requests@2.31.0"
#     }
#   ]
# }
```

### 4. Lockfile (Reproducibilité)

```bash
# ✅ BON : Utiliser pip-tools pour générer lockfile
pip install pip-tools

# Créer requirements.txt (haut niveau)
# requests==2.31.*
# flask==2.3.*

# Générer lockfile avec versions exactes
pip-compile requirements.txt \
  --output-file requirements.lock

# requirements.lock contient les versions exactes
# Garantit la reproductibilité
```

---

## 📊 Audit & Compliance

### 1. Logs & Audit Trail

```yaml
# Chaque job doit logger ses actions

- name: Log security events
  run: |
    # Format: TIMESTAMP|USER|ACTION|RESULT|DETAILS
    
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ)|${{ github.actor }}|SECURITY_SCAN_START|OK|CodeQL" >> audit.log
    
    # Scan...
    
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ)|${{ github.actor }}|SECURITY_SCAN_END|OK|Found 0 critical issues" >> audit.log

- name: Archive audit log
  if: always()
  uses: actions/upload-artifact@v4
  with:
    name: audit-logs
    path: audit.log
    retention-days: 90  # Conformité GDPR
```

### 2. Compliance Checks

```bash
# Vérifier la conformité avec standards

# ✅ OWASP Top 10
# ✅ CWE Top 25
# ✅ SANS Top 25
# ✅ NIST Cybersecurity Framework

# Scripts de vérification
#!/bin/bash
echo "=== Compliance Checks ==="

# 1. OWASP Top 10
bandit -r src/ --severity-level high

# 2. Dépendances vulnérables
safety check

# 3. Secrets exposés
detect-secrets scan

# 4. Couverture de tests
pytest --cov=src --cov-fail-under=70

echo "✅ All compliance checks passed"
```

### 3. Rapport d'Audit

```bash
# Générer rapport trimestriel

#!/bin/bash
QUARTER=$(date +%q)
YEAR=$(date +%Y)

cat > compliance-report-${YEAR}-Q${QUARTER}.md << EOF
# Compliance Report - Q${QUARTER} ${YEAR}

## Security Events
- Total incidents: X
- Resolved: Y
- Pending: Z

## Vulnerabilities Found
- CRÍTICA: 0
- HAUTE: 2 (resolved)
- MOYENNE: 5 (in progress)

## Dependency Updates
- Automated: 28
- Manual: 5
- Failed: 0

## Code Coverage
- Target: 70%
- Actual: 82%
- Trend: ↑ 2%

## Compliance
- OWASP Top 10: ✅ Passed
- CWE Top 25: ✅ Passed
- GDPR: ✅ Compliant
EOF
```

---

## 🚨 Response à Incidents

### 1. Découverte d'une Vulnérabilité

```bash
#!/bin/bash
# incident-response.sh

set -euo pipefail

SEVERITY=$1  # CRÍTICA | HAUTE | MOYENNE | BASSE
CVE=$2       # CVE-2024-XXXX
PACKAGE=$3   # package-name

echo "🚨 Security Incident Response"
echo "CVE: $CVE"
echo "Severity: $SEVERITY"
echo "Package: $PACKAGE"

# Phase 1: Containment (< 1 hour)
echo "Phase 1: CONTAINMENT"
# - Disable the vulnerable service (if exposed)
# - Create emergency branch
git checkout -b hotfix/security-$CVE

# Phase 2: Investigation (< 2 hours)
echo "Phase 2: INVESTIGATION"
# - Identify impact scope
# - Who uses this package?
grep -r "import $PACKAGE" src/ || true
grep -r "$PACKAGE" requirements.txt || true

# Phase 3: Remediation (depends on severity)
echo "Phase 3: REMEDIATION"
# Update to patched version
pip install --upgrade $PACKAGE

# Commit fix
git add requirements.txt
git commit -m "security: fix $CVE in $PACKAGE"

# Phase 4: Verification
echo "Phase 4: VERIFICATION"
safety check
bandit -r src/

# Phase 5: Communication
echo "Phase 5: COMMUNICATION"
echo "Notifying stakeholders..."
# Send email/Slack notification

# Phase 6: Post-Incident
echo "Phase 6: POST-INCIDENT"
# Write incident report
# Update processes to prevent
# Schedule post-mortem
```

### 2. Communication aux Utilisateurs

```markdown
# Security Advisory

## Issue
A critical vulnerability (CVE-2024-XXXX) was discovered in dependency `package-name` v1.0.0.

## Impact
Applications using version 1.0.0 are vulnerable to remote code execution.

## Action Required
- **Immediate**: Upgrade to version 1.0.1 or later
  ```bash
  pip install --upgrade package-name
  ```
- **Timeline**: Patch available now
- **Workaround**: None available, upgrade required

## Timeline
- 2024-04-17 12:00 UTC: Vulnerability discovered
- 2024-04-17 12:30 UTC: Patch released
- 2024-04-17 13:00 UTC: Advisory published
- 2024-04-24 23:59 UTC: Support for v1.0.0 ends

## More Information
- CVE Details: https://nvd.nist.gov/vuln/detail/CVE-2024-XXXX
- GitHub Advisory: https://github.com/advisories/GHSA-XXXX
```

### 3. Post-Mortem

```markdown
# Incident Post-Mortem: CVE-2024-XXXX

## Timeline
- **2024-04-17 12:00** : Vulnérabilité détectée par routine monitoring
- **2024-04-17 12:15** : Assigné à équipe sécurité
- **2024-04-17 12:30** : Patch provider publié v1.0.1
- **2024-04-17 13:00** : Mis à jour dans notre repo et déployé
- **2024-04-17 13:15** : Advisory publié
- **2024-04-17 16:00** : Tous les clients notifiés

## Root Cause
La dépendance `package-name` avait une injection de code non-corrigée.

## How We Detected It
- Automated dependency scanning (Safety)
- GitHub Dependabot alerts
- Upstream project notice

## What Went Well
- ✅ Quick detection (< 2 minutes after public disclosure)
- ✅ Patch available immediately
- ✅ Automated testing caught impact
- ✅ Clear communication to users

## What Could Be Better
- Plan to add signature verification for dependencies
- Consider source-based verification (not just binary)
- Implement rate-limiting on vulnerable code paths

## Action Items
- [ ] Enable GitHub Secret Scanning
- [ ] Add signature verification to build
- [ ] Increase test coverage for vulnerable code paths
- [ ] Schedule quarterly security audit
```

---

## 📋 Checklist de Sécurité

### Avant Production

- [ ] Tous les secrets sont dans GitHub Secrets (pas hardcodés)
- [ ] Permissions workflow au minimum requis
- [ ] Actions épinglées à des SHAs (pas de tags mutables)
- [ ] Tests de sécurité passent (CodeQL, Bandit, Safety)
- [ ] Pas de dépendances CRÍTICA vulnérables
- [ ] Couverture de code ≥ 70%
- [ ] Secrets scanning activé
- [ ] Branche main protégée
- [ ] Email notifications configurées
- [ ] Audit trail en place

### Après Production

- [ ] Monitoring continu des vulnérabilités
- [ ] Logs archivés de façon sécurisée
- [ ] Rotation des secrets tous les 90 jours
- [ ] Audit trimestriel de compliance
- [ ] Post-mortem si incident
- [ ] Communication proactive aux utilisateurs

---

## 🔗 Ressources Avancées

- [GitHub Actions Security Hardening](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)
- [OWASP Secure Coding](https://owasp.org/www-project-secure-coding-dojo/)
- [CIS Controls](https://www.cisecurity.org/cis-controls)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework/)
- [Supply Chain Security](https://slsa.dev/)

---

**Version** : 1.0
**Date** : 2024-04-17
**Mainteneur** : Security Team
