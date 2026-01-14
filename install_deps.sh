#!/bin/bash

set -e

echo "==================================="
echo "Unit Work Dependencies Installer"
echo "==================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check for required commands
check_prerequisites() {
    echo "Checking prerequisites..."
    echo ""

    # Check Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        echo ""
        echo "Install Docker from: https://docs.docker.com/get-docker/"
        echo ""
        echo "  macOS:  brew install --cask docker"
        echo "  Linux:  https://docs.docker.com/engine/install/"
        echo ""
        exit 1
    fi
    print_success "Docker found"

    # Check if Docker daemon is running
    if ! docker info &> /dev/null; then
        print_error "Docker daemon is not running"
        echo ""
        echo "Start Docker Desktop or run: sudo systemctl start docker"
        echo ""
        exit 1
    fi
    print_success "Docker daemon running"

    # Check Node.js
    if ! command -v node &> /dev/null; then
        print_error "Node.js is not installed"
        echo ""
        echo "Install Node.js 18+ from: https://nodejs.org/"
        echo ""
        echo "  macOS:  brew install node"
        echo "  Linux:  https://nodejs.org/en/download/"
        echo ""
        exit 1
    fi

    # Check Node.js version (need 18+)
    NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -lt 18 ]; then
        print_error "Node.js 18+ required (found v$NODE_VERSION)"
        echo ""
        echo "Upgrade Node.js from: https://nodejs.org/"
        echo ""
        exit 1
    fi
    print_success "Node.js v$(node -v | cut -d'v' -f2) found"

    echo ""
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
    else
        print_error "Unsupported OS: $OSTYPE"
        echo "This script supports macOS and Linux only."
        exit 1
    fi
}

# Install Hindsight CLI
install_hindsight_cli() {
    echo "Installing Hindsight CLI..."
    echo ""

    if command -v hindsight &> /dev/null; then
        print_success "Hindsight CLI already installed ($(hindsight --version 2>/dev/null || echo 'version unknown'))"
        return 0
    fi

    if [ "$OS" == "macos" ]; then
        if command -v brew &> /dev/null; then
            echo "Installing via Homebrew..."
            brew install vectorize-io/tap/hindsight
        else
            print_warning "Homebrew not found, using direct download..."
            curl -fsSL https://github.com/vectorize-io/hindsight/releases/latest/download/hindsight-darwin-arm64 -o /tmp/hindsight
            chmod +x /tmp/hindsight
            sudo mv /tmp/hindsight /usr/local/bin/hindsight
        fi
    elif [ "$OS" == "linux" ]; then
        echo "Downloading Hindsight CLI..."
        curl -fsSL https://github.com/vectorize-io/hindsight/releases/latest/download/hindsight-linux-x86_64 -o /tmp/hindsight
        chmod +x /tmp/hindsight
        sudo mv /tmp/hindsight /usr/local/bin/hindsight
    fi

    if command -v hindsight &> /dev/null; then
        print_success "Hindsight CLI installed"
    else
        print_error "Failed to install Hindsight CLI"
        exit 1
    fi

    echo ""
}

# Install agent-browser
install_agent_browser() {
    echo "Installing agent-browser..."
    echo ""

    if command -v agent-browser &> /dev/null; then
        print_success "agent-browser already installed"
        return 0
    fi

    npm install -g @anthropic/agent-browser
    agent-browser install

    if command -v agent-browser &> /dev/null; then
        print_success "agent-browser installed"
    else
        print_error "Failed to install agent-browser"
        exit 1
    fi

    echo ""
}

# Print Hindsight Docker setup instructions
print_docker_setup() {
    echo "==================================="
    echo "Hindsight Docker Setup"
    echo "==================================="
    echo ""
    echo "Set these environment variables (add to ~/.bashrc or ~/.zshrc):"
    echo ""
    echo "  export HINDSIGHT_API_LLM_PROVIDER=openai"
    echo "  export HINDSIGHT_API_LLM_BASE_URL=https://openrouter.ai/api/v1"
    echo "  export HINDSIGHT_API_LLM_API_KEY=<your-openrouter-key>"
    echo "  export HINDSIGHT_API_LLM_MODEL=google/gemini-3-flash-preview"
    echo ""
    echo "Then start the Hindsight container:"
    echo ""
    echo '  docker run -d --name hindsight --pull always -p 8888:8888 -p 9999:9999 \'
    echo '    -e HINDSIGHT_API_LLM_API_KEY=$HINDSIGHT_API_LLM_API_KEY \'
    echo '    -e HINDSIGHT_API_LLM_PROVIDER=$HINDSIGHT_API_LLM_PROVIDER \'
    echo '    -e HINDSIGHT_API_LLM_BASE_URL=$HINDSIGHT_API_LLM_BASE_URL \'
    echo '    -e HINDSIGHT_API_LLM_MODEL=$HINDSIGHT_API_LLM_MODEL \'
    echo '    -v $HOME/.hindsight-docker:/home/hindsight/.pg0 \'
    echo '    ghcr.io/vectorize-io/hindsight:latest'
    echo ""
    echo "Manage the container:"
    echo "  docker stop hindsight    # Stop"
    echo "  docker start hindsight   # Start again"
    echo "  docker logs hindsight    # View logs"
    echo ""
}

# Print success message
print_success_message() {
    echo "==================================="
    echo "Installation Complete!"
    echo "==================================="
    echo ""
    print_success "Hindsight CLI installed"
    print_success "agent-browser installed"
    echo ""
    echo "Next steps:"
    echo "  1. Set up Hindsight environment variables (see above)"
    echo "  2. Start the Hindsight Docker container"
    echo "  3. Run /uw:bootstrap to configure your project"
    echo ""
}

# Main
main() {
    check_prerequisites
    detect_os
    install_hindsight_cli
    install_agent_browser
    print_docker_setup
    print_success_message
}

main
