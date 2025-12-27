# Installation

Git hook commit-msg

```bash
git config --global ollama.url "https://ollama.fr"
git config --global ollama.model "mistral-large-3:675b-cloud"

mkdir -p ~/.git-global-hooks
cp commit-msg ~/.git-global-hooks
chmod +x ~/.git-global-hooks/commit-msg
git config --global core.hooksPath ~/.git-global-hooks
```