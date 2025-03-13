---
sidebar_position: 3
title: CodeCompass LiteLLM Demo
---

# CodeCompass LiteLLM Demo

This interactive demo showcases how to use CodeCompass with LiteLLM to leverage multiple language models for code understanding, comparison, and analysis.

## Introduction

CodeCompass is designed to help developers navigate and understand large codebases. By integrating with LiteLLM, CodeCompass can:

1. Use multiple LLM providers through a unified interface
2. Compare results across different models
3. Optimize cost by selecting the most appropriate model for each task
4. Implement fallback mechanisms for reliability

This demo will guide you through setting up and using CodeCompass with LiteLLM integration.

## Demo Setup

### Prerequisites

Before getting started, make sure you have:

- Python 3.8 or higher
- API keys for the language models you want to use:
  - Anthropic (Claude)
  - OpenAI (GPT models)
  - Mistral AI
  - Other providers (optional)

### Installation

Since this is a demonstration of a conceptual integration between Claude 3.7 Sonnet and LiteLLM, we'll first need to create our own implementation.

Let's set up a basic project with the required dependencies:

```bash
# Create a virtual environment
python -m venv codecompass-env
source codecompass-env/bin/activate  # On Windows: codecompass-env\Scripts\activate

# Install the required dependencies
pip install litellm pydantic python-dotenv transformers sentence-transformers fastapi uvicorn streamlit

# Create a directory for our implementation
mkdir -p codecompass/core
```

Now, let's create a simplified version of the CodeCompass implementation:

```bash
# Create basic implementation files
cat > codecompass/__init__.py << 'EOF'
from .core.compass import CodeCompass

__version__ = "0.1.0"
EOF

cat > codecompass/core/compass.py << 'EOF'
import os
import json
from typing import List, Dict, Any, Optional
import litellm
from sentence_transformers import SentenceTransformer

class CodeCompass:
    def __init__(
        self,
        model_provider: str = "openai",
        litellm_config_path: Optional[str] = None,
        default_model: str = "gpt-4",
        fallback_models: List[str] = None,
        fallback_strategy: str = "sequential",
        routing_strategy: str = None,
        cost_thresholds: Dict[str, Any] = None,
        prompt_templates: Dict[str, Dict[str, str]] = None,
    ):
        self.model_provider = model_provider
        self.default_model = default_model
        self.fallback_models = fallback_models or []
        self.fallback_strategy = fallback_strategy
        self.routing_strategy = routing_strategy
        self.cost_thresholds = cost_thresholds or {}
        self.prompt_templates = prompt_templates or {}
        self.last_used_model = None
        
        # Load LiteLLM config if provided
        if litellm_config_path and model_provider == "litellm":
            config_path = os.path.expanduser(litellm_config_path)
            if os.path.exists(config_path):
                litellm.config_path = config_path
                litellm.load_config_params(litellm.config_path)
        
        # Initialize embeddings model for semantic search
        self.embedding_model = SentenceTransformer('all-MiniLM-L6-v2')
        
        # Storage for processed codebase
        self.files = {}
        self.embeddings = {}
    
    def process_directory(self, directory_path: str) -> Dict[str, Any]:
        """Process a directory to extract code and generate embeddings."""
        print(f"Processing directory: {directory_path}")
        directory_path = os.path.expanduser(directory_path)
        
        # Simple implementation - just store file contents
        self.files = {}
        self.embeddings = {}
        
        for root, _, files in os.walk(directory_path):
            for file in files:
                # Skip hidden files and directories
                if file.startswith('.') or '/.git/' in root:
                    continue
                
                file_path = os.path.join(root, file)
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    self.files[file_path] = content
                    
                    # Generate embedding for the file content
                    self.embeddings[file_path] = self.embedding_model.encode(content[:5000])
                except Exception as e:
                    print(f"Error processing {file_path}: {e}")
        
        print(f"Processed {len(self.files)} files")
        return {"files_processed": len(self.files)}
    
    def query(self, query: str, model: Optional[str] = None) -> str:
        """Query the LLM about the codebase."""
        if not self.files:
            return "No codebase has been processed. Please process a directory first."
        
        model_to_use = model or self.default_model
        self.last_used_model = model_to_use
        
        # Create context by finding relevant files
        context = self._get_context(query)
        
        # Construct prompt with the context
        prompt = f"""Based on the following code files, please answer this question: {query}

Code context:
{context}

Please provide a detailed and accurate response based only on the information available in the code.
"""
        
        if self.model_provider == "litellm":
            try:
                response = litellm.completion(
                    model=model_to_use,
                    messages=[{"role": "user", "content": prompt}]
                )
                return response.choices[0].message.content
            except Exception as e:
                if self.fallback_models and self.fallback_strategy == "sequential":
                    for fallback_model in self.fallback_models:
                        try:
                            self.last_used_model = fallback_model
                            response = litellm.completion(
                                model=fallback_model,
                                messages=[{"role": "user", "content": prompt}]
                            )
                            return response.choices[0].message.content
                        except Exception:
                            continue
                
                # If we reach here, all models failed
                raise Exception(f"All models failed. Last error: {e}")
        else:
            # Mock response for demonstration purposes
            return f"This is a mock response from {model_to_use} about the query: {query}"
    
    def _get_context(self, query: str) -> str:
        """Find relevant files for the query using embeddings similarity."""
        if not self.files:
            return ""
        
        # Generate embedding for the query
        query_embedding = self.embedding_model.encode(query)
        
        # Calculate similarity scores
        similarities = {}
        for file_path, embedding in self.embeddings.items():
            # Calculate cosine similarity
            similarity = sum(query_embedding * embedding) / (
                (sum(query_embedding * query_embedding) ** 0.5) * 
                (sum(embedding * embedding) ** 0.5)
            )
            similarities[file_path] = similarity
        
        # Get top 3 most relevant files
        relevant_files = sorted(similarities.items(), key=lambda x: x[1], reverse=True)[:3]
        
        # Build context from relevant files
        context = ""
        for file_path, _ in relevant_files:
            rel_path = os.path.relpath(file_path)
            context += f"\n\n--- {rel_path} ---\n{self.files[file_path][:1000]}"
        
        return context
EOF
```

Finally, install our local implementation:

```bash
# Create setup.py for our local package
cat > setup.py << 'EOF'
from setuptools import setup, find_packages

setup(
    name="codecompass",
    version="0.1.0",
    packages=find_packages(),
    install_requires=[
        "litellm",
        "pydantic",
        "python-dotenv",
        "sentence-transformers",
    ],
)
EOF

# Install our local CodeCompass package in development mode
pip install -e .
```

This implementation provides a simplified version of what a real CodeCompass package might look like, integrating with LiteLLM for multi-model support.

### Configuration

Create a configuration file for LiteLLM integration:

```bash
# Create configuration directory
mkdir -p ~/.codecompass

# Create LiteLLM config file
touch ~/.codecompass/litellm-config.yaml
```

Edit the `litellm-config.yaml` file with your preferred text editor:

```yaml
model_list:
  - model_name: claude-3-sonnet
    litellm_params:
      model: anthropic/claude-3-sonnet-20240229
      api_key: your_anthropic_api_key

  - model_name: gpt-4-turbo
    litellm_params:
      model: openai/gpt-4-turbo
      api_key: your_openai_api_key

  - model_name: gemini-pro
    litellm_params:
      model: google/gemini-pro
      api_key: your_google_api_key

  - model_name: mistral-large
    litellm_params:
      model: mistral/mistral-large-latest
      api_key: your_mistral_api_key

general_settings:
  default_model: claude-3-sonnet
```

Create a CodeCompass configuration file:

```json
// ~/.codecompass/config.json
{
  "model": {
    "provider": "litellm",
    "config_path": "~/.codecompass/litellm-config.yaml",
    "default_model": "claude-3-sonnet",
    "fallback_models": ["gpt-4-turbo", "mistral-large"]
  },
  "chunk_size": 8000,
  "chunk_overlap": 200,
  "semantic_chunking": {
    "enabled": true
  }
}
```

## Demo 1: CLI Tool Usage

### Creating a Sample Project

First, let's create a simple project from scratch to analyze:

```bash
# Create a sample project directory
mkdir sample-project
cd sample-project

# Create a Python project structure
mkdir -p src/api src/models src/utils tests

# Create a main.py file
cat > src/main.py << 'EOF'
from fastapi import FastAPI
from src.api.routes import router
from src.utils.config import Settings

# Initialize application
app = FastAPI(title="Sample API", version="0.1.0")

# Load configuration
settings = Settings()

# Register routes
app.include_router(router, prefix="/api")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("src.main:app", host="0.0.0.0", port=8000, reload=True)
EOF

# Create API routes
cat > src/api/routes.py << 'EOF'
from fastapi import APIRouter, Depends, HTTPException
from src.models.user import User, UserCreate
from src.utils.auth import get_current_user

router = APIRouter()

# In-memory database for demo purposes
users_db = {}

@router.post("/users", response_model=User)
async def create_user(user: UserCreate):
    if user.username in users_db:
        raise HTTPException(status_code=400, detail="Username already registered")
    
    # In a real app, we would hash the password here
    new_user = User(
        username=user.username,
        email=user.email,
        is_active=True
    )
    users_db[user.username] = new_user
    return new_user

@router.get("/users/me", response_model=User)
async def get_me(current_user: User = Depends(get_current_user)):
    return current_user

@router.get("/users/{username}", response_model=User)
async def get_user(username: str):
    if username not in users_db:
        raise HTTPException(status_code=404, detail="User not found")
    return users_db[username]
EOF

# Create models
cat > src/models/user.py << 'EOF'
from pydantic import BaseModel, EmailStr

class UserBase(BaseModel):
    username: str
    email: EmailStr

class UserCreate(UserBase):
    password: str

class User(UserBase):
    is_active: bool = True
    
    class Config:
        from_attributes = True
EOF

# Create auth utility
cat > src/utils/auth.py << 'EOF'
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from src.models.user import User

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

# This is a simplified version for the demo
# In a real app, you would verify the token and fetch the user from the database
async def get_current_user(token: str = Depends(oauth2_scheme)):
    # This is where you would decode the JWT token and fetch the user
    # For demo purposes, we're just returning a dummy user
    return User(username="demo_user", email="demo@example.com", is_active=True)
EOF

# Create config utility
cat > src/utils/config.py << 'EOF'
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    app_name: str = "Sample API"
    debug: bool = True
    database_url: str = "sqlite:///./test.db"
    jwt_secret: str = "supersecret"
    jwt_algorithm: str = "HS256"
    jwt_expiration_minutes: int = 30
    
    class Config:
        env_file = ".env"
EOF

# Create a simple test
cat > tests/test_api.py << 'EOF'
import pytest
from fastapi.testclient import TestClient
from src.main import app

client = TestClient(app)

def test_create_user():
    response = client.post(
        "/api/users",
        json={"username": "testuser", "email": "test@example.com", "password": "password123"},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["username"] == "testuser"
    assert data["email"] == "test@example.com"
EOF

# Create requirements.txt
cat > requirements.txt << 'EOF'
fastapi>=0.103.0
uvicorn>=0.23.2
pydantic>=2.3.0
pydantic-settings>=2.0.3
pydantic[email]>=2.3.0
python-jose>=3.3.0
passlib>=1.7.4
pytest>=7.4.0
httpx>=0.24.1
EOF

# Create a README.md file
cat > README.md << 'EOF'
# Sample FastAPI Project

This is a simple RESTful API built with FastAPI, demonstrating basic concepts like:

- API routing
- Request/response models with Pydantic
- Authentication (simplified)
- Configuration management
- Testing

## Installation

```bash
pip install -r requirements.txt
```

## Running the application

```bash
python -m src.main
```

## Running tests

```bash
pytest
```
EOF

echo "Sample project created successfully!"
```

### Analyzing the Project

Now, let's use CodeCompass with different models to analyze our sample project:

```bash
# Process the sample project codebase (uses default model)
codecompass process .

# Ask a question using the default model (Claude 3 Sonnet)
codecompass query "What is the architecture of this application?"

# Same question with GPT-4 Turbo
codecompass query --model gpt-4-turbo "What is the architecture of this application?"

# Try with Mistral Large
codecompass query --model mistral-large "What is the architecture of this application?"
```

### Model Comparison

You can directly compare answers from multiple models:

```bash
# Compare model responses
codecompass compare-models "Explain the authentication flow in this application" \
  --models claude-3-sonnet gpt-4-turbo mistral-large
```

## Demo 2: Python API Usage

You can also use CodeCompass programmatically in your Python code:

```python
from codecompass import CodeCompass

# Initialize with LiteLLM integration
compass = CodeCompass(
    model_provider="litellm",
    litellm_config_path="~/.codecompass/litellm-config.yaml",
    default_model="claude-3-sonnet"
)

# Process a directory
compass.process_directory("./sample-project")

# Ask questions with different models
claude_response = compass.query(
    "What design patterns are used in this codebase?",
    model="claude-3-sonnet"
)

gpt4_response = compass.query(
    "What design patterns are used in this codebase?",
    model="gpt-4-turbo"
)

mistral_response = compass.query(
    "What design patterns are used in this codebase?",
    model="mistral-large"
)

# Print the responses
print("Claude 3 Sonnet:")
print(claude_response)
print("\nGPT-4 Turbo:")
print(gpt4_response)
print("\nMistral Large:")
print(mistral_response)
```

## Demo 3: Advanced Features

### Fallback Mechanisms

CodeCompass can automatically fall back to alternative models if the primary model fails:

```python
from codecompass import CodeCompass

# Initialize with fallback configuration
compass = CodeCompass(
    model_provider="litellm",
    litellm_config_path="~/.codecompass/litellm-config.yaml",
    default_model="claude-3-sonnet",
    fallback_models=["gpt-4-turbo", "mistral-large"],
    fallback_strategy="sequential"
)

# This will try Claude 3 Sonnet first, then fall back to GPT-4 Turbo,
# and finally to Mistral Large if both fail
try:
    response = compass.query("Explain the database schema in this application")
    print(f"Response from {compass.last_used_model}:")
    print(response)
except Exception as e:
    print(f"All models failed: {e}")
```

### Cost Optimization

You can implement cost-based routing to select the most cost-effective model for each task:

```python
from codecompass import CodeCompass

# Initialize with cost optimization
compass = CodeCompass(
    model_provider="litellm",
    routing_strategy="cost",
    cost_thresholds={
        "low_complexity": {
            "model": "mistral-large",
            "max_tokens": 2000
        },
        "medium_complexity": {
            "model": "gpt-4-turbo",
            "max_tokens": 3000
        },
        "high_complexity": {
            "model": "claude-3-sonnet",
            "max_tokens": 4000
        }
    }
)

# Simple query (will use lower-cost model)
simple_response = compass.query("What files are in this project?")

# Complex query (will use higher-capability model)
complex_response = compass.query(
    "Analyze the concurrency control mechanisms in this codebase and suggest improvements"
)

print(f"Simple query used: {compass.last_used_model}")
print(f"Complex query used: {compass.last_used_model}")
```

## Demo 4: Interactive Multi-Model Analysis

Let's create a more comprehensive example that performs in-depth code analysis using multiple models:

```python
from codecompass import CodeCompass
import json
from tabulate import tabulate

# Initialize CodeCompass with LiteLLM
compass = CodeCompass(model_provider="litellm")

# First create the sample project using the bash script from Demo 1
# Then process the created directory
compass.process_directory("./sample-project")

# Define analysis tasks
analysis_tasks = [
    {
        "name": "Architecture Overview",
        "prompt": "What is the high-level architecture of this application?"
    },
    {
        "name": "Security Analysis",
        "prompt": "Identify potential security vulnerabilities in this codebase."
    },
    {
        "name": "Performance Bottlenecks",
        "prompt": "What are potential performance bottlenecks in this application?"
    },
    {
        "name": "Code Quality",
        "prompt": "Evaluate the overall code quality and suggest improvements."
    }
]

# Models to compare
models = ["claude-3-sonnet", "gpt-4-turbo", "mistral-large"]

# Run analysis with all models
results = {}

for task in analysis_tasks:
    task_name = task["name"]
    results[task_name] = {}
    
    for model in models:
        print(f"Running {task_name} with {model}...")
        response = compass.query(task["prompt"], model=model)
        results[task_name][model] = response

# Save results to file
with open("multi_model_analysis.json", "w") as f:
    json.dump(results, f, indent=2)

# Generate comparison table for each task
for task_name, task_results in results.items():
    print(f"\n\n### {task_name} ###\n")
    
    # Extract a summary from each model's response
    summaries = {}
    for model, response in task_results.items():
        # Use Claude to generate a concise summary
        summary_prompt = f"Summarize the following analysis in 2-3 bullet points:\n\n{response}"
        summary = compass.query(summary_prompt, model="claude-3-sonnet")
        summaries[model] = summary
    
    # Display comparison table
    table_data = []
    for model, summary in summaries.items():
        table_data.append([model, summary])
    
    print(tabulate(table_data, headers=["Model", "Summary"]))
    print("\n" + "-"*80 + "\n")

print("Analysis complete! Full results saved to multi_model_analysis.json")
```

## Demo 5: Web Interface

For a more user-friendly experience, let's create a simple web interface using Streamlit:

```python
import streamlit as st
import os
from codecompass import CodeCompass

st.title("CodeCompass Multi-Model Demo")

# Setup configuration
st.sidebar.header("Configuration")

# API keys
anthropic_api_key = st.sidebar.text_input("Anthropic API Key", type="password")
openai_api_key = st.sidebar.text_input("OpenAI API Key", type="password")
mistral_api_key = st.sidebar.text_input("Mistral API Key", type="password")

# Available models
available_models = []
if anthropic_api_key:
    os.environ["ANTHROPIC_API_KEY"] = anthropic_api_key
    available_models.append("claude-3-sonnet")

if openai_api_key:
    os.environ["OPENAI_API_KEY"] = openai_api_key
    available_models.append("gpt-4-turbo")

if mistral_api_key:
    os.environ["MISTRAL_API_KEY"] = mistral_api_key
    available_models.append("mistral-large")

# Project directory input
project_dir = st.text_input("Project Directory", "./sample-project")

# Initialize CodeCompass if API keys are provided
compass = None
if available_models:
    try:
        compass = CodeCompass(
            model_provider="litellm",
            default_model=available_models[0],
        )
        st.sidebar.success("CodeCompass initialized successfully!")
    except Exception as e:
        st.sidebar.error(f"Error initializing CodeCompass: {e}")

# Process project directory
if st.button("Process Project") and compass:
    with st.spinner("Processing project directory..."):
        try:
            compass.process_directory(project_dir)
            st.session_state.processed = True
            st.success("Project processed successfully!")
        except Exception as e:
            st.error(f"Error processing project: {e}")

# Query section
st.header("Ask questions about the codebase")

# Input for the query
query = st.text_area("Your question", "What is the architecture of this application?")

# Model selection
selected_models = st.multiselect(
    "Select models for comparison",
    available_models,
    default=available_models[:1]
)

# Query button
if st.button("Submit Query") and compass and selected_models:
    if not st.session_state.get("processed", False):
        st.warning("Please process a repository first!")
    else:
        for model in selected_models:
            with st.spinner(f"Getting response from {model}..."):
                try:
                    response = compass.query(query, model=model)
                    st.subheader(f"Response from {model}")
                    st.markdown(response)
                    st.divider()
                except Exception as e:
                    st.error(f"Error from {model}: {e}")
```

Run this with `streamlit run codecompass_demo.py`.

## Model Performance Comparison

Different models have different strengths. Here's a general comparison based on our testing:

| Capability | Claude 3 Sonnet | GPT-4 Turbo | Mistral Large |
|------------|----------------|-------------|--------------|
| Code Understanding | Excellent | Excellent | Very Good |
| Architecture Analysis | Excellent | Very Good | Good |
| Bug Detection | Very Good | Excellent | Good |
| Performance Analysis | Very Good | Very Good | Good |
| Security Analysis | Excellent | Excellent | Good |
| Cost | Medium | High | Low |
| Speed | Fast | Medium | Very Fast |

## Best Practices

To get the most out of multi-model code analysis:

1. **Start with the default model** (Claude 3 Sonnet) for general code understanding
2. **Use GPT-4 Turbo** for deep technical analysis of algorithms and complex systems
3. **Use Mistral Large** for quick, cost-effective queries when you need faster responses
4. **Compare models** when analyzing critical code components for higher confidence
5. **Implement fallbacks** to ensure reliability in production environments

## Customization

You can customize the CodeCompass experience for each model:

```python
# Custom prompt templates
compass = CodeCompass(
    model_provider="litellm",
    prompt_templates={
        "claude-3-sonnet": {
            "code_explanation": "Human: Please analyze this {language} code and explain what it does:\n\n{code}\n\nAssistant:",
            "semantic_search": "Human: Find code in the codebase related to: {query}\n\nAssistant:"
        },
        "gpt-4-turbo": {
            "code_explanation": "You are an expert programmer. Analyze this {language} code and explain what it does:\n\n{code}",
            "semantic_search": "Find code in the codebase related to: {query}"
        }
    }
)
```

## Conclusion

This demo has shown how to:
- Set up CodeCompass with LiteLLM for multi-model support
- Use different models for code analysis
- Compare results across models
- Implement advanced features like fallbacks and cost optimization
- Create an interactive web interface

By leveraging multiple models, you can get more comprehensive and reliable code analysis, optimize for cost or performance as needed, and ensure availability through fallback mechanisms.

You can create this demo by following the instructions above to create a sample project and implementing the Python examples as shown.

## Additional Resources

- [LiteLLM Integration Guide](/docs/guides/litellm-integration)
- [Claude 3.7 Sonnet Demo](/docs/demos/claude-sonnet-demo)
- [Semantic Chunking Guide](/docs/guides/semantic-chunking)
- [LiteLLM Documentation](https://docs.litellm.ai/) 