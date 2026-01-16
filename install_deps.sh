#!/bin/bash

set -e

echo "==================================="
echo "Unit Work Dependencies Installer"
echo "==================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}✓${NC} $1"
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

# Install agent-browser
install_agent_browser() {
    echo "Installing agent-browser..."
    echo ""

    if command -v agent-browser &> /dev/null; then
        print_success "agent-browser already installed"
        return 0
    fi

    npm install -g agent-browser

    # Linux needs --with-deps for system dependencies
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        agent-browser install --with-deps
    else
        agent-browser install
    fi

    if command -v agent-browser &> /dev/null; then
        print_success "agent-browser installed"
    else
        print_error "Failed to install agent-browser"
        exit 1
    fi

    echo ""
}

# Start or print instructions for Hindsight Docker
setup_hindsight_docker() {
    echo "Setting up Hindsight Docker..."
    echo ""

    # Check if container already exists
    if docker ps -a --format '{{.Names}}' | grep -q '^hindsight$'; then
        if docker ps --format '{{.Names}}' | grep -q '^hindsight$'; then
            print_success "Hindsight container already running"
        else
            echo "Starting existing Hindsight container..."
            docker start hindsight
            print_success "Hindsight container started"
        fi
        return 0
    fi

    # Check if required env vars are set, prompt if not
    if [ -z "$HINDSIGHT_API_LLM_API_KEY" ]; then
        echo "Hindsight requires an LLM API key for memory operations."
        echo "Recommended: Use OpenRouter with Gemini 3 Flash (low cost, good performance)"
        echo "Get a key at: https://openrouter.ai/keys"
        echo ""
        read -p "Enter your OpenRouter API key: " api_key
        if [ -z "$api_key" ]; then
            print_error "API key is required"
            return 1
        fi
        HINDSIGHT_API_LLM_API_KEY="$api_key"
        HINDSIGHT_API_LLM_PROVIDER="openai"
        HINDSIGHT_API_LLM_BASE_URL="https://openrouter.ai/api/v1"
        HINDSIGHT_API_LLM_MODEL="google/gemini-3-flash-preview"

        echo ""
        echo "To avoid entering this again, add to ~/.bashrc or ~/.zshrc:"
        echo ""
        echo "  export HINDSIGHT_API_LLM_API_KEY=$api_key"
        echo "  export HINDSIGHT_API_LLM_PROVIDER=openai"
        echo "  export HINDSIGHT_API_LLM_BASE_URL=https://openrouter.ai/api/v1"
        echo "  export HINDSIGHT_API_LLM_MODEL=google/gemini-3-flash-preview"
        echo ""
    fi

    # Start the container
    echo "Starting Hindsight container..."
    docker run -d --name hindsight --pull always -p 8888:8888 -p 9999:9999 \
        -e HINDSIGHT_API_LLM_API_KEY=$HINDSIGHT_API_LLM_API_KEY \
        -e HINDSIGHT_API_LLM_PROVIDER=${HINDSIGHT_API_LLM_PROVIDER:-openai} \
        -e HINDSIGHT_API_LLM_BASE_URL=${HINDSIGHT_API_LLM_BASE_URL:-https://openrouter.ai/api/v1} \
        -e HINDSIGHT_API_LLM_MODEL=${HINDSIGHT_API_LLM_MODEL:-google/gemini-3-flash-preview} \
        -v $HOME/.hindsight-docker:/home/hindsight/.pg0 \
        ghcr.io/vectorize-io/hindsight:latest

    print_success "Hindsight container started"
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
    print_success "agent-browser installed"
    print_success "Hindsight container running"
    echo ""
    echo "Next step: Run /uw:bootstrap to configure your project"
    echo ""
}

# Main
main() {
    check_prerequisites
    install_agent_browser
    if setup_hindsight_docker; then
        print_success_message
    fi
}

main
