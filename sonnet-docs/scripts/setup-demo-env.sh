#!/bin/bash

# Script to set up the environment for testing the demo code
# This script sets up a Python virtual environment and installs the required packages

echo "Setting up environment for CodeCompass & Claude 3.7 Sonnet demos..."
echo "----------------------------------------------------------------"

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "Python 3 is not installed. Please install Python 3 and try again."
    exit 1
fi

# Create a virtual environment
echo "Creating Python virtual environment..."
python3 -m venv demo-venv

# Activate the virtual environment
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    # Windows
    echo "Activating virtual environment (Windows)..."
    source demo-venv/Scripts/activate
else
    # macOS/Linux
    echo "Activating virtual environment (Unix)..."
    source demo-venv/bin/activate
fi

# Install required packages
echo "Installing required packages..."
pip install anthropic litellm scikit-learn streamlit numpy pandas tabulate

# Create directory for demo code
mkdir -p demo-code

# Create demo code files
echo "Creating demo code files..."

# Claude 3.7 Sonnet demo
cat > demo-code/claude_demo.py << 'EOL'
"""
Claude 3.7 Sonnet Demo Script

This script demonstrates basic functionality showcased in the Claude 3.7 Sonnet demo.
Note: You need to set your Anthropic API key before running this script.
"""

import os
import anthropic
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

# Check for API key
if "ANTHROPIC_API_KEY" not in os.environ:
    print("Please set your Anthropic API key:")
    print("export ANTHROPIC_API_KEY=your_api_key_here")
    exit(1)

# Sample code chunks for demo purposes
sample_chunks = [
    {
        "file_path": "auth/auth_service.js",
        "content": """
class AuthService {
  constructor(userRepo, tokenService) {
    this.userRepo = userRepo;
    this.tokenService = tokenService;
  }
  
  async login(username, password) {
    const user = await this.userRepo.findByUsername(username);
    if (!user) return { success: false, message: "User not found" };
    
    const isValid = await this.verifyPassword(password, user.passwordHash);
    if (!isValid) return { success: false, message: "Invalid password" };
    
    const token = this.tokenService.generateToken(user.id);
    return { success: true, token, user };
  }
  
  async verifyPassword(password, passwordHash) {
    // Simplified for demo
    return password === "correct_password";
  }
}
"""
    },
    {
        "file_path": "auth/token_service.js",
        "content": """
class TokenService {
  constructor(secret, expiresIn = '24h') {
    this.secret = secret;
    this.expiresIn = expiresIn;
  }
  
  generateToken(userId) {
    // Simplified for demo
    return `token_for_${userId}_valid_for_${this.expiresIn}`;
  }
  
  verifyToken(token) {
    // Simplified for demo
    if (token.startsWith('token_for_')) {
      const userId = token.split('_')[2];
      return { valid: true, userId };
    }
    return { valid: false };
  }
}
"""
    },
    {
        "file_path": "models/user.js",
        "content": """
class User {
  constructor(id, username, email, passwordHash) {
    this.id = id;
    this.username = username;
    this.email = email;
    this.passwordHash = passwordHash;
    this.createdAt = new Date();
    this.lastLogin = null;
  }
  
  updateLastLogin() {
    this.lastLogin = new Date();
  }
}

class UserRepository {
  constructor(db) {
    this.db = db;
    this.users = []; // Simplified for demo
  }
  
  async findByUsername(username) {
    // Simplified for demo
    return this.users.find(u => u.username === username);
  }
  
  async findById(id) {
    // Simplified for demo
    return this.users.find(u => u.id === id);
  }
}
"""
    }
]

def select_relevant_chunks(chunks, question, top_n=2):
    """Select the most relevant chunks based on the question."""
    # Create a combined list of all chunks and the question
    texts = [chunk['content'] for chunk in chunks]
    texts.append(question)
    
    # Create TF-IDF vectors
    vectorizer = TfidfVectorizer(stop_words='english')
    tfidf_matrix = vectorizer.fit_transform(texts)
    
    # Calculate similarity between question and each chunk
    question_vector = tfidf_matrix[-1]
    chunk_vectors = tfidf_matrix[:-1]
    similarities = cosine_similarity(question_vector, chunk_vectors).flatten()
    
    # Get indices of top N most similar chunks
    top_indices = np.argsort(similarities)[-top_n:][::-1]
    
    return [chunks[i] for i in top_indices]

def get_language_from_path(file_path):
    """Determine language based on file extension."""
    ext = file_path.split('.')[-1].lower()
    language_map = {
        'py': 'python',
        'js': 'javascript',
        'ts': 'typescript',
        'jsx': 'jsx',
        'tsx': 'tsx',
        'java': 'java',
        'cpp': 'cpp',
        'c': 'c',
        'cs': 'csharp',
        'go': 'go',
        'rb': 'ruby',
        'php': 'php',
        'rs': 'rust'
    }
    return language_map.get(ext, '')

def analyze_codebase(chunks, question):
    """Send code chunks to Claude 3.7 Sonnet and get analysis."""
    client = anthropic.Anthropic()
    
    context = ""
    for chunk in select_relevant_chunks(chunks, question):
        context += f"File: {chunk['file_path']}\n"
        context += f"```{get_language_from_path(chunk['file_path'])}\n"
        context += chunk['content'] + "\n```\n\n"
    
    message = client.messages.create(
        model="claude-3-sonnet-20240229",
        max_tokens=1000,
        temperature=0.0,
        system="You are a senior software engineer with expertise in analyzing and explaining code.",
        messages=[
            {
                "role": "user",
                "content": f"I'm analyzing a codebase and need your help understanding it. Here are relevant parts of the code:\n\n{context}\n\n{question}\n\nPlease analyze the code and provide a detailed answer."
            }
        ]
    )
    
    return message.content[0].text

# Demo usage
questions = [
    "Explain the authentication flow in this application. How are user credentials validated?",
    "What is the responsibility of the TokenService class?",
    "How are user details stored and retrieved in this system?"
]

print("Claude 3.7 Sonnet Code Analysis Demo")
print("===================================\n")

for question in questions:
    print(f"\n--- QUESTION: {question} ---\n")
    analysis = analyze_codebase(sample_chunks, question)
    print(analysis)
    print("\n" + "-" * 80 + "\n")

print("\nDemo completed! You've seen Claude 3.7 Sonnet analyze code.")
print("Check the documentation for more advanced usage examples.")
EOL

# CodeCompass LiteLLM demo
cat > demo-code/codecompass_demo.py << 'EOL'
"""
CodeCompass LiteLLM Demo Script

This script demonstrates a simplified version of the CodeCompass multi-model demo.
Note: You need to set API keys for the models you want to use.

Required environment variables:
- ANTHROPIC_API_KEY (for Claude models)
- OPENAI_API_KEY (for GPT models)
- MISTRAL_API_KEY (for Mistral models)
"""

import streamlit as st
import os
import anthropic
import litellm

# Configure page title
st.set_page_config(page_title="CodeCompass Multi-Model Demo", page_icon="🧭")

st.title("CodeCompass Multi-Model Demo")
st.markdown("This demo shows how to use different language models for code analysis.")

# Setup sidebar for configuration
st.sidebar.header("Configuration")

# API keys input
anthropic_api_key = st.sidebar.text_input("Anthropic API Key", type="password")
openai_api_key = st.sidebar.text_input("OpenAI API Key", type="password")
mistral_api_key = st.sidebar.text_input("Mistral API Key", type="password")

# Set environment variables if provided
if anthropic_api_key:
    os.environ["ANTHROPIC_API_KEY"] = anthropic_api_key

if openai_api_key:
    os.environ["OPENAI_API_KEY"] = openai_api_key

if mistral_api_key:
    os.environ["MISTRAL_API_KEY"] = mistral_api_key

# Available models based on provided API keys
available_models = []
if anthropic_api_key:
    available_models.append({"name": "Claude 3 Sonnet", "id": "anthropic/claude-3-sonnet-20240229"})

if openai_api_key:
    available_models.append({"name": "GPT-4 Turbo", "id": "openai/gpt-4-turbo"})

if mistral_api_key:
    available_models.append({"name": "Mistral Large", "id": "mistral/mistral-large-latest"})

# Sample code for analysis
sample_code = '''
def fibonacci(n):
    """
    Calculate the Fibonacci number for a given index using recursion.
    
    Args:
        n (int): The index in the Fibonacci sequence
        
    Returns:
        int: The Fibonacci number at index n
    """
    if n <= 0:
        return 0
    elif n == 1:
        return 1
    else:
        return fibonacci(n-1) + fibonacci(n-2)

def fibonacci_optimized(n):
    """
    Calculate the Fibonacci number for a given index using dynamic programming.
    
    Args:
        n (int): The index in the Fibonacci sequence
        
    Returns:
        int: The Fibonacci number at index n
    """
    if n <= 0:
        return 0
    
    fib = [0, 1]
    for i in range(2, n+1):
        fib.append(fib[i-1] + fib[i-2])
    
    return fib[n]
'''

# Code input 
st.header("Code to Analyze")
code = st.text_area("Enter code to analyze:", sample_code, height=300)

# Query input
st.header("Ask a Question")
query = st.text_area("What would you like to know about this code?", 
                    "Compare the time and space complexity of these two Fibonacci implementations.")

# Model selection
selected_models = []
if available_models:
    model_options = [model["name"] for model in available_models]
    selected_model_names = st.multiselect(
        "Select models for comparison",
        model_options,
        default=model_options[:1] if model_options else []
    )
    
    # Map selected names to model objects
    for model in available_models:
        if model["name"] in selected_model_names:
            selected_models.append(model)
else:
    st.warning("Please provide at least one API key to use the demo.")

def analyze_with_model(model_id, code, question):
    """Analyze code using the specified model via LiteLLM."""
    prompt = f"""
    Please analyze this code:
    
    ```
    {code}
    ```
    
    {question}
    """
    
    try:
        response = litellm.completion(
            model=model_id,
            messages=[{"role": "user", "content": prompt}],
            temperature=0,
            max_tokens=1000
        )
        return response.choices[0].message.content
    except Exception as e:
        return f"Error: {str(e)}"

# Analyze button
if st.button("Analyze Code") and selected_models:
    for model in selected_models:
        with st.spinner(f"Analyzing with {model['name']}..."):
            st.subheader(f"Response from {model['name']}")
            response = analyze_with_model(model["id"], code, query)
            st.markdown(response)
            st.divider()
else:
    if not available_models:
        st.info("Please add API keys in the sidebar to enable model selection.")
    elif not selected_models:
        st.info("Please select at least one model for analysis.")

st.sidebar.markdown("---")
st.sidebar.markdown("""
## About This Demo

This is a simplified version of the CodeCompass demo showcasing multi-model support through LiteLLM integration.

For the full version with more advanced features like:
- Semantic chunking
- Cost optimization
- Fallback mechanisms
- More complex code analysis

Check out the complete documentation.
""")
EOL

echo "----------------------------------------------------------------"
echo "Setup complete! You can now run the demos with:"
echo ""
echo "# Activate the virtual environment"
echo "source demo-venv/bin/activate  # On Windows: demo-venv\\Scripts\\activate"
echo ""
echo "# Run the Claude 3.7 Sonnet demo"
echo "python demo-code/claude_demo.py"
echo ""
echo "# Run the CodeCompass LiteLLM demo"
echo "streamlit run demo-code/codecompass_demo.py"
echo ""
echo "Note: Make sure to set your API keys before running the demos:"
echo "export ANTHROPIC_API_KEY=your_anthropic_api_key"
echo "export OPENAI_API_KEY=your_openai_api_key  # Optional for LiteLLM demo"
echo "export MISTRAL_API_KEY=your_mistral_api_key  # Optional for LiteLLM demo"
echo "----------------------------------------------------------------" 