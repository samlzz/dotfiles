alias gs="git status"
alias gsa="git stash"
alias gf="git fetch --all"
alias gl="git log"
alias gd="git diff"
alias gcl="git clone"
alias ga="git add"
alias gaa="git add ."
alias gc="git commit"
alias gcm="git commit -m"
alias gca="git commit --amend"
alias gp="git push"
alias gpf="git push --force-with-lease"
alias ggraph="git log --oneline --graph --decorate --exclude=refs/stash --all"
alias gck="git checkout"
alias gifiles="git ls-files --others --ignored --exclude-standard"

convc() {

	read -r -d '' conv_doc <<EOF
# 📌 Conventional Commit Messages

Les commits conventionnels permettent de structurer les messages de commit de manière standardisée pour faciliter la compréhension, l'automatisation et la génération de changelogs.

## 🏗️ Format d'un message de commit :
\`\`\`
<type>(<scope>): <description>

<corps optionnel>

<footer optionnel>
\`\`\`

## 🏷️ Types possibles :
- **feat** : Ajout ou modification d'une fonctionnalité
- **fix** : Correction d'un bug
- **refactor** : Réorganisation du code sans modifier le comportement
- **style** : Modification du formatage (espaces, norme, ect...)
- **test** : Ajout ou modification de tests
- **docs** : Modifications de la documentation
- **build** : Changement affectant le système de build ou les dépendances
- **chore** : Tâches diverses sans impact sur le code

## ⚠️ Breaking Changes :
Un changement majeur doit être signalé avec \`!\` avant le \`:\`
Exemple : \`feat!: supprime l'ancienne API\`

## 🔍 Exemples :
- \`feat: ajoute la gestion des notifications\`
- \`fix(auth): corrige un bug d'authentification\`
- \`refactor(db): optimise les requêtes SQL\`
- \`docs: améliore la documentation de l'API\`
EOF
	if command -v glow &>/dev/null; then
		glow <<<$conv_doc
	elif command -v bat &>/dev/null; then
		bat -l md -p <<<$conv_doc
	else
		cat <<<$conv_doc
	fi
}
