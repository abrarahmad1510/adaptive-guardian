#!/bin/bash

# =============================================================================
# Adaptive Guardian - STAGED Installation Script for macOS M1
# Resolves dependency conflicts by installing in specific order
# =============================================================================

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}==================================================================${NC}"
echo -e "${BLUE}   Adaptive Guardian - Staged Installation (Conflict-Free)      ${NC}"
echo -e "${BLUE}==================================================================${NC}"
echo ""

# Check macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}Error: macOS only${NC}"
    exit 1
fi

# Check virtual environment
if [[ -z "$VIRTUAL_ENV" ]]; then
    echo -e "${RED}Error: Activate virtual environment first!${NC}"
    echo -e "${YELLOW}Run: source ~/Developer/projects/adaptive-guardian-venv/bin/activate${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Virtual environment: $VIRTUAL_ENV${NC}"
echo -e "${GREEN}✓ Architecture: $(uname -m)${NC}"
echo ""

# Step 0: Upgrade pip
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 0: Upgrading pip, setuptools, wheel${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
pip install --upgrade pip setuptools wheel
echo -e "${GREEN}✓ Build tools upgraded${NC}"
echo ""

# Step 1: Core dependencies
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 1: Installing core dependencies (NumPy, Pandas, SciPy)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
pip install --no-cache-dir \
    numpy==1.26.3 \
    pandas==2.1.4 \
    scipy==1.11.4
echo -e "${GREEN}✓ Core dependencies installed${NC}"
echo ""

# Step 2: PyTorch
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 2: Installing PyTorch (this will take a few minutes)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
pip install --no-cache-dir \
    torch==2.1.2 \
    torchvision==0.16.2
echo -e "${GREEN}✓ PyTorch installed${NC}"
echo ""

# Step 3: Protobuf (CRITICAL - must be installed before TensorFlow and Flower)
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 3: Installing Protobuf (critical compatibility layer)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
pip install --no-cache-dir protobuf==4.24.4
echo -e "${GREEN}✓ Protobuf 4.24.4 installed${NC}"
echo ""

# Step 4: TensorFlow for Apple Silicon
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 4: Installing TensorFlow with Metal GPU support${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
pip install --no-cache-dir \
    tensorflow-macos==2.15.0 \
    tensorflow-metal==1.1.0
echo -e "${GREEN}✓ TensorFlow installed${NC}"
echo ""

# Step 5: Flower (Federated Learning)
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 5: Installing Flower for Federated Learning${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
# Try Flower 1.7.0 first (supports protobuf 4.x)
pip install --no-cache-dir flwr==1.7.0 || {
    echo -e "${YELLOW}⚠ Flower 1.7.0 not available, trying 1.6.0...${NC}"
    # If 1.7.0 not available, downgrade to compatible versions
    pip uninstall -y protobuf tensorflow-macos tensorflow-metal
    pip install --no-cache-dir protobuf==3.20.3
    pip install --no-cache-dir tensorflow-macos==2.13.0 tensorflow-metal==1.0.0
    pip install --no-cache-dir flwr==1.6.0
}
echo -e "${GREEN}✓ Flower installed${NC}"
echo ""

# Step 6: ML libraries
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 6: Installing ML libraries${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
pip install --no-cache-dir \
    scikit-learn==1.3.2 \
    xgboost==2.0.3
echo -e "${GREEN}✓ ML libraries installed${NC}"
echo ""

# Step 7: MLOps
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 7: Installing MLOps tools${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
pip install --no-cache-dir \
    mlflow==2.9.2 \
    kfp==2.5.0 \
    prefect==2.14.11
echo -e "${GREEN}✓ MLOps tools installed${NC}"
echo ""

# Step 8: Optimization
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 8: Installing optimization libraries${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
pip install --no-cache-dir \
    ortools==9.8.3296 \
    cvxpy==1.4.1 \
    pulp==2.7.0
echo -e "${GREEN}✓ Optimization libraries installed${NC}"
echo ""

# Step 9: Web frameworks
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 9: Installing web frameworks${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
pip install --no-cache-dir \
    fastapi==0.108.0 \
    "uvicorn[standard]==0.25.0" \
    pydantic==2.5.3 \
    httpx==0.26.0 \
    requests==2.31.0
echo -e "${GREEN}✓ Web frameworks installed${NC}"
echo ""

# Step 10: Data processing
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 10: Installing data processing tools${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
pip install --no-cache-dir pyspark==3.5.0
echo -e "${GREEN}✓ Data processing installed${NC}"
echo ""

# Step 11: Messaging
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 11: Installing messaging libraries${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
pip install --no-cache-dir \
    kafka-python==2.0.2 \
    paho-mqtt==1.6.1 \
    pyzmq==25.1.2
echo -e "${GREEN}✓ Messaging libraries installed${NC}"
echo ""

# Step 12: Testing
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 12: Installing testing frameworks${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
pip install --no-cache-dir \
    pytest==7.4.3 \
    pytest-cov==4.1.0 \
    pytest-asyncio==0.23.2 \
    pytest-mock==3.12.0 \
    hypothesis==6.92.2
echo -e "${GREEN}✓ Testing frameworks installed${NC}"
echo ""

# Step 13: Code quality
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 13: Installing code quality tools${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
pip install --no-cache-dir \
    black==23.12.1 \
    pylint==3.0.3 \
    mypy==1.7.1 \
    isort==5.13.2 \
    flake8==7.0.0
echo -e "${GREEN}✓ Code quality tools installed${NC}"
echo ""

# Step 14: Documentation
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 14: Installing documentation tools${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
pip install --no-cache-dir \
    sphinx==7.2.6 \
    sphinx-rtd-theme==2.0.0 \
    myst-parser==2.0.0 \
    sphinx-autodoc-typehints==1.25.2
echo -e "${GREEN}✓ Documentation tools installed${NC}"
echo ""

# Step 15: Utilities
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 15: Installing utilities${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
pip install --no-cache-dir \
    click==8.1.7 \
    rich==13.7.0 \
    tqdm==4.66.1 \
    loguru==0.7.2 \
    python-dotenv==1.0.0 \
    pyyaml==6.0.1
echo -e "${GREEN}✓ Utilities installed${NC}"
echo ""

# Step 16: Security
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 16: Installing security libraries${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
pip install --no-cache-dir \
    cryptography==41.0.7 \
    pyjwt==2.8.0 \
    bcrypt==4.1.2 \
    "python-jose[cryptography]==3.3.0"
echo -e "${GREEN}✓ Security libraries installed${NC}"
echo ""

# Step 17: Database
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 17: Installing database libraries${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
pip install --no-cache-dir \
    sqlalchemy==2.0.25 \
    psycopg2-binary==2.9.9 \
    redis==5.0.1 \
    pymongo==4.6.1
echo -e "${GREEN}✓ Database libraries installed${NC}"
echo ""

# Step 18: Monitoring
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 18: Installing monitoring tools${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
pip install --no-cache-dir \
    prometheus-client==0.19.0 \
    opentelemetry-api==1.22.0 \
    opentelemetry-sdk==1.22.0
echo -e "${GREEN}✓ Monitoring tools installed${NC}"
echo ""

# Step 19: Serialization
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 19: Installing serialization libraries${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
pip install --no-cache-dir \
    msgpack==1.0.7 \
    avro==1.11.3
echo -e "${GREEN}✓ Serialization libraries installed${NC}"
echo ""

# Step 20: Image processing
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 20: Installing image processing${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
pip install --no-cache-dir \
    pillow==10.1.0 \
    opencv-python==4.9.0.80
echo -e "${GREEN}✓ Image processing installed${NC}"
echo ""

# Step 21: Jupyter
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 21: Installing Jupyter${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
pip install --no-cache-dir \
    jupyter==1.0.0 \
    jupyterlab==4.0.10 \
    ipykernel==6.28.0 \
    ipywidgets==8.1.1 \
    notebook==7.0.6
echo -e "${GREEN}✓ Jupyter installed${NC}"
echo ""

# Step 22: Development tools
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 22: Installing development tools${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
pip install --no-cache-dir \
    pre-commit==3.6.0 \
    bump2version==1.0.1
echo -e "${GREEN}✓ Development tools installed${NC}"
echo ""

# Verification
echo -e "${BLUE}==================================================================${NC}"
echo -e "${BLUE}   Verifying Installation                                        ${NC}"
echo -e "${BLUE}==================================================================${NC}"
echo ""

python3 << 'VERIFY'
import sys

packages = {
    'numpy': 'NumPy',
    'pandas': 'Pandas',
    'torch': 'PyTorch',
    'tensorflow': 'TensorFlow',
    'sklearn': 'scikit-learn',
    'xgboost': 'XGBoost',
    'flwr': 'Flower',
    'mlflow': 'MLflow',
    'fastapi': 'FastAPI',
    'pytest': 'pytest',
}

print("Package Verification:")
print("=" * 60)
all_ok = True
for module, name in packages.items():
    try:
        mod = __import__(module)
        version = getattr(mod, '__version__', 'unknown')
        print(f"✓ {name:20s} {version}")
    except ImportError as e:
        print(f"✗ {name:20s} FAILED")
        all_ok = False

print("=" * 60)

# Check GPU
print("\nGPU Support:")
print("=" * 60)
try:
    import tensorflow as tf
    gpus = tf.config.list_physical_devices('GPU')
    print(f"TensorFlow GPUs: {len(gpus)}")
    if len(gpus) > 0:
        print("✓ Metal GPU support available!")
except Exception as e:
    print(f"⚠ TensorFlow GPU check failed: {e}")

try:
    import torch
    if torch.backends.mps.is_available():
        print("✓ PyTorch MPS available!")
    else:
        print("⚠ PyTorch MPS not available")
except Exception as e:
    print(f"⚠ PyTorch MPS check failed: {e}")

print("=" * 60)

if not all_ok:
    sys.exit(1)
VERIFY

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}==================================================================${NC}"
    echo -e "${GREEN}   ✓ Installation Successful!                                   ${NC}"
    echo -e "${GREEN}==================================================================${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "  1. Test TensorFlow GPU:"
    echo "     python -c 'import tensorflow as tf; print(tf.config.list_physical_devices())'"
    echo ""
    echo "  2. Test PyTorch MPS:"
    echo "     python -c 'import torch; print(torch.backends.mps.is_available())'"
    echo ""
    echo "  3. Start coding:"
    echo "     cd ~/Developer/projects/adaptive-guardian"
    echo ""
else
    echo -e "${RED}Installation had errors. Check output above.${NC}"
    exit 1
fi
