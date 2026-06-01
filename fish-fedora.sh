#!/bin/bash

# Encerra o script imediatamente se algum comando falhar
set -e

echo "🚀 Iniciando a configuração do ambiente de desenvolvimento no Fedora..."

echo "📦 1/7 - Instalando dependências do sistema e ferramentas de build..."
sudo dnf install -y fish curl git unzip wget util-linux fontconfig
sudo dnf install -y @development-tools zlib-devel bzip2 bzip2-devel readline-devel \
    sqlite-devel openssl-devel xz-devel libffi-devel tk-devel tcl-devel

echo "🔤 2/7 - Baixando e instalando a JetBrains Mono Nerd Font..."
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
wget -q --show-progress -O /tmp/JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -q -o /tmp/JetBrainsMono.zip -d "$FONT_DIR"
rm /tmp/JetBrainsMono.zip
fc-cache -f -v

echo "⭐ 3/7 - Instalando e configurando o Starship (Prompt)..."
curl -sS https://starship.rs/install.sh | sh -s -- -y
mkdir -p ~/.config
starship preset nerd-font-symbols -o ~/.config/starship.toml

echo "🐍 4/7 - Instalando o Pyenv (Gerenciador de versões Python)..."
rm -rf ~/.pyenv # Limpa instalações antigas para evitar conflitos
curl -sL https://pyenv.run | bash

echo "📦 5/7 - Instalando o Mise (Gerenciador de Node.js, Bun, etc)..."
curl -sL https://mise.jdx.dev/install.sh | sh

echo "🐟 6/7 - Configurando o Fish Shell (Aliases, Pyenv e Mise)..."
mkdir -p ~/.config/fish
cat << 'EOF' > ~/.config/fish/config.fish
if status is-interactive
    # --- 1. Pyenv (Python) ---
    set -gx PYENV_ROOT $HOME/.pyenv
    fish_add_path $PYENV_ROOT/bin
    if command -v pyenv > /dev/null
        pyenv init - | source
    end

    # --- 2. Mise (Node/JS) ---
    fish_add_path ~/.local/bin
    if command -v mise > /dev/null
        mise activate fish | source
    end

    # --- 3. Abreviações de Produtividade ---
    abbr -a g git
    abbr -a pnp pnpm
    abbr -a px pnpx
    abbr -a nrd "npm run dev"
    abbr -a venv "python3 -m venv .venv; source .venv/bin/activate.fish"
    abbr -a va "source .venv/bin/activate.fish"
    abbr -a .. "cd .."
    abbr -a cls clear
end

# --- 4. Inicializa o Starship (Sempre no final) ---
if command -v starship > /dev/null
    starship init fish | source
end
EOF

echo "⚙️ 7/7 - Definindo o Fish como shell padrão..."
# Fallback seguro para o COSMIC Term via .bashrc
if ! grep -q "exec /usr/bin/fish" ~/.bashrc; then
    echo -e "\n# Força a inicialização do Fish no COSMIC Term\nif [ -f /usr/bin/fish ]; then\n  exec /usr/bin/fish\nfi" >> ~/.bashrc
fi

# Tenta mudar via usermod
sudo usermod -s $(which fish) $USER

echo ""
echo "✅ Instalação concluída com sucesso!"
echo "⚠️  IMPORTANTE: Faça LOGOUT do sistema e entre novamente para aplicar todas as mudanças."
echo "Após retornar, abra o terminal e instale suas linguagens com:"
echo "  -> pyenv install 3.13.1 && pyenv global 3.13.1"
echo "  -> mise use --global node@lts"