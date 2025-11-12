#!/bin/bash
set -e

MODULE_NAME="$1"
VERSION="$2"
BACKUP_PATH="backups/${MODULE_NAME}/v${VERSION}"

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "Verifying backup: ${BACKUP_PATH}"

# Check directory exists
if [[ ! -d "$BACKUP_PATH" ]]; then
  echo -e "${RED}❌ Backup not found${NC}"
  exit 1
fi

# Check critical files
CRITICAL_FILES=(
  "plugin.json"
  "Makefile"
)

for file in "${CRITICAL_FILES[@]}"; do
  if [[ ! -f "${BACKUP_PATH}/${file}" ]]; then
    echo -e "${RED}❌ Missing: ${file}${NC}"
    exit 1
  else
    echo -e "${GREEN}✓${NC} ${file}"
  fi
done

# Verify plugin.json is valid JSON
if jq empty "${BACKUP_PATH}/plugin.json" 2>/dev/null; then
  echo -e "${GREEN}✓${NC} plugin.json valid JSON"
else
  echo -e "${RED}❌ plugin.json invalid JSON${NC}"
  exit 1
fi

# Verify plugin slug format (alphanumeric, underscore, hyphen only)
SLUG=$(jq -r '.slug // empty' "${BACKUP_PATH}/plugin.json" 2>/dev/null)
if [[ -z "$SLUG" ]]; then
  echo -e "${RED}❌ plugin.json missing slug field${NC}"
  exit 1
fi

if [[ ! "$SLUG" =~ ^[a-zA-Z0-9_-]+$ ]]; then
  echo -e "${RED}❌ Invalid slug format: ${SLUG} (must be alphanumeric with _ or -)${NC}"
  exit 1
else
  echo -e "${GREEN}✓${NC} slug format valid: ${SLUG}"
fi

# Check src/ directory exists and has .cpp files
if [[ ! -d "${BACKUP_PATH}/src" ]]; then
  echo -e "${RED}❌ Missing src/ directory${NC}"
  exit 1
fi

CPP_FILES=$(find "${BACKUP_PATH}/src" -name "*.cpp" | wc -l)
if [[ $CPP_FILES -eq 0 ]]; then
  echo -e "${RED}❌ No .cpp files found in src/${NC}"
  exit 1
else
  echo -e "${GREEN}✓${NC} src/ directory (${CPP_FILES} .cpp files)"
fi

# Check res/ directory exists (panel SVG)
if [[ ! -d "${BACKUP_PATH}/res" ]]; then
  echo -e "${YELLOW}⚠️${NC} Missing res/ directory (no panel graphics)"
else
  SVG_FILES=$(find "${BACKUP_PATH}/res" -name "*.svg" | wc -l)
  echo -e "${GREEN}✓${NC} res/ directory (${SVG_FILES} SVG files)"
fi

# Check if module was installed (check for binary in Rack plugins folder)
if [[ -n "$RACK_DIR" ]]; then
  PLUGIN_DIR="${RACK_DIR}/plugins/${SLUG}"
  if [[ -d "$PLUGIN_DIR" ]]; then
    echo -e "${GREEN}✓${NC} Module installed at ${PLUGIN_DIR}"

    # Check for plugin binary
    if [[ -f "${PLUGIN_DIR}/plugin.dylib" ]] || [[ -f "${PLUGIN_DIR}/plugin.so" ]] || [[ -f "${PLUGIN_DIR}/plugin.dll" ]]; then
      echo -e "${GREEN}✓${NC} Plugin binary found"
    else
      echo -e "${YELLOW}⚠️${NC} Plugin binary not found (may need rebuild)"
    fi
  else
    echo -e "${YELLOW}⚠️${NC} Module not installed (source backup only)"
  fi
else
  echo -e "${YELLOW}⚠️${NC} RACK_DIR not set (cannot verify installation)"
fi

# Check for git tag (version tracking)
cd "${BACKUP_PATH}"
if git rev-parse "v${VERSION}" >/dev/null 2>&1; then
  echo -e "${GREEN}✓${NC} Git tag v${VERSION} exists"
else
  echo -e "${YELLOW}⚠️${NC} Git tag v${VERSION} not found (backup may not be version-tagged)"
fi

# Verify Makefile can be parsed (check for critical targets)
if grep -q "^include.*plugin.mk" "${BACKUP_PATH}/Makefile"; then
  echo -e "${GREEN}✓${NC} Makefile includes plugin.mk"
else
  echo -e "${RED}❌ Makefile missing plugin.mk include${NC}"
  exit 1
fi

# Check for module entry point (plugin.cpp or similar)
if [[ -f "${BACKUP_PATH}/src/plugin.cpp" ]]; then
  echo -e "${GREEN}✓${NC} plugin.cpp entry point found"
elif ls "${BACKUP_PATH}/src/"*plugin*.cpp >/dev/null 2>&1; then
  echo -e "${GREEN}✓${NC} Plugin entry point found"
else
  echo -e "${YELLOW}⚠️${NC} No standard plugin.cpp entry point (may use custom structure)"
fi

echo -e "${GREEN}✓ Backup verification complete${NC}"
exit 0
