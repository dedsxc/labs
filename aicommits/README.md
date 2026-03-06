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

## OpenAI

Git hook commit-msg with openai api compatible `commit-msg-openai`.

```bash
git config --global openai.url "https://api.openai.com/v1/chat/completions"
git config --global openai.model "gpt-4o-mini"
git config --global openai.apiKey "<YOUR_API_KEY>"

mkdir -p ~/.git-global-hooks
cp commit-msg-openai ~/.git-global-hooks/commit-msg
chmod +x ~/.git-global-hooks/commit-msg
git config --global core.hooksPath ~/.git-global-hooks
```
