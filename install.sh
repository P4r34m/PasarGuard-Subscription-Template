#!/usr/bin/env bash
set -euo pipefail

# Installer for the custom PasarGuard subscription template.
# One-liner:
#   curl -fsSL https://raw.githubusercontent.com/P4r34m/PasarGuard-Subscription-Template/main/install.sh | sudo bash
# All terminal output is intentionally in English.

REPO_RAW="https://raw.githubusercontent.com/P4r34m/PasarGuard-Subscription-Template/main"
DEFAULT_URL="${REPO_RAW}/index.html"

DEST_DIR="/var/lib/pasarguard/templates/subscription"
DEST_FILE="${DEST_DIR}/index.html"
ENV_FILE="/opt/pasarguard/.env"

SRC_FILE=""
SRC_URL=""

# When run from a local checkout, prefer the index.html next to this script.
SCRIPT_SRC="${BASH_SOURCE[0]:-}"
if [[ -n "${SCRIPT_SRC}" && -f "${SCRIPT_SRC}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${SCRIPT_SRC}")" >/dev/null 2>&1 && pwd)"
  [[ -f "${SCRIPT_DIR}/index.html" ]] && SRC_FILE="${SCRIPT_DIR}/index.html"
fi

usage() {
  cat <<'EOF'
Usage: install.sh [--file <path>] [--url <url>] [--dest <path>] [--env <path>]

Options:
  --file <path>   Local index.html to install
  --url  <url>    Download the template from a specific URL
  --dest <path>   Destination file (default: /var/lib/pasarguard/templates/subscription/index.html)
  --env  <path>   PasarGuard .env file (default: /opt/pasarguard/.env)
  -h, --help      Show this help

With no --file/--url, it copies a local index.html if one sits next to this script,
otherwise it downloads the latest template from the GitHub repository.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --file) [[ $# -lt 2 ]] && { echo "Error: --file needs a value." >&2; exit 1; }; SRC_FILE="$2"; SRC_URL=""; shift 2;;
    --url)  [[ $# -lt 2 ]] && { echo "Error: --url needs a value." >&2; exit 1; }; SRC_URL="$2"; SRC_FILE=""; shift 2;;
    --dest) [[ $# -lt 2 ]] && { echo "Error: --dest needs a value." >&2; exit 1; }; DEST_FILE="$2"; DEST_DIR="$(dirname "$2")"; shift 2;;
    --env)  [[ $# -lt 2 ]] && { echo "Error: --env needs a value." >&2; exit 1; }; ENV_FILE="$2"; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "Error: unknown argument: $1" >&2; usage; exit 1;;
  esac
done

if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  echo "Warning: not running as root. You may need sudo to write to system directories." >&2
fi

download() {
  local url="$1" out="$2"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "${url}" -o "${out}"
  elif command -v wget >/dev/null 2>&1; then
    wget -q -O "${out}" "${url}"
  else
    echo "Error: neither curl nor wget is installed." >&2; exit 1
  fi
}

echo "==> Installing the custom PasarGuard subscription template"
mkdir -p "${DEST_DIR}"

if [[ -n "${SRC_URL}" ]]; then
  echo "--> Downloading template from: ${SRC_URL}"
  download "${SRC_URL}" "${DEST_FILE}"
elif [[ -n "${SRC_FILE}" ]]; then
  echo "--> Copying template from: ${SRC_FILE}"
  cp "${SRC_FILE}" "${DEST_FILE}"
else
  echo "--> Downloading template from: ${DEFAULT_URL}"
  download "${DEFAULT_URL}" "${DEST_FILE}"
fi

echo "--> Template installed at: ${DEST_FILE}"

echo "--> Updating environment file: ${ENV_FILE}"
mkdir -p "$(dirname "${ENV_FILE}")"
touch "${ENV_FILE}"

# Derive env values from the destination so a custom --dest stays consistent.
TEMPLATES_ROOT="$(dirname "${DEST_DIR}")/"
SUB_TEMPLATE="$(basename "${DEST_DIR}")/$(basename "${DEST_FILE}")"

if grep -q '^CUSTOM_TEMPLATES_DIRECTORY=' "${ENV_FILE}"; then
  sed -i "s|^CUSTOM_TEMPLATES_DIRECTORY=.*|CUSTOM_TEMPLATES_DIRECTORY=\"${TEMPLATES_ROOT}\"|" "${ENV_FILE}"
else
  echo "CUSTOM_TEMPLATES_DIRECTORY=\"${TEMPLATES_ROOT}\"" >> "${ENV_FILE}"
fi

if grep -q '^SUBSCRIPTION_PAGE_TEMPLATE=' "${ENV_FILE}"; then
  sed -i "s|^SUBSCRIPTION_PAGE_TEMPLATE=.*|SUBSCRIPTION_PAGE_TEMPLATE=\"${SUB_TEMPLATE}\"|" "${ENV_FILE}"
else
  echo "SUBSCRIPTION_PAGE_TEMPLATE=\"${SUB_TEMPLATE}\"" >> "${ENV_FILE}"
fi

echo "--> Environment variables set:"
echo "      CUSTOM_TEMPLATES_DIRECTORY=\"${TEMPLATES_ROOT}\""
echo "      SUBSCRIPTION_PAGE_TEMPLATE=\"${SUB_TEMPLATE}\""

if command -v pasarguard >/dev/null 2>&1; then
  echo "--> Restarting PasarGuard..."
  pasarguard restart
  echo "==> Done. Template installed and PasarGuard restarted."
else
  echo "==> Done. Template installed."
  echo "    'pasarguard' command not found - please restart the panel manually."
fi
