---
sidebar_position: 1
title: Claude 3.7 Sonnet Demo
---

# Claude 3.7 Sonnet Demo: Understanding Large Codebases

This interactive demo showcases how Claude 3.7 Sonnet can comprehend and analyze large codebases, providing developers with powerful tools for code navigation, understanding, and documentation.

## Introduction

Claude 3.7 Sonnet is the first AI model capable of truly understanding entire codebases at scale. This demo will guide you through:

1. How to prepare your codebase for analysis
2. Effective semantic chunking techniques
3. Crafting prompts for code understanding
4. Real-world examples and use cases

## Why Claude 3.7 Sonnet Excels at Code Understanding

Claude 3.7 Sonnet offers several advantages for code analysis:

- **100K context window**: Able to process large portions of code at once
- **Advanced semantic understanding**: Comprehends relationships between different code components
- **Language-agnostic**: Works across multiple programming languages
- **Excellent code generation**: Can create, modify, and explain code with high accuracy

## Demo 1: Setting Up Your Environment

Before diving into code analysis, you'll need to set up your environment:

```bash
# Install required packages
pip install anthropic requests beautifulsoup4 scikit-learn numpy

# Set your API key
export ANTHROPIC_API_KEY=your_api_key_here

# Create a project directory
mkdir claude-cli-study-demo
cd claude-cli-study-demo

# Create initial files
touch semantic_chunker.py code_analyzer.py sample_code.py requirements.txt
```

## Demo 2: Implementing Semantic Chunking

The key to effective code analysis with Claude 3.7 Sonnet is proper semantic chunking. Let's implement a basic chunker:

```python
import os
import re
import ast
from typing import List, Dict, Any

class SemanticChunker:
    """A class for semantically chunking code files."""
    
    def __init__(self):
        self.language_handlers = {
            '.py': self._chunk_python,
            '.js': self._chunk_javascript,
            '.ts': self._chunk_typescript,
            '.java': self._chunk_java,
            '.cpp': self._chunk_cpp,
            '.c': self._chunk_c
        }
    
    def chunk_file(self, file_path):
        """Chunk a file based on its extension."""
        _, ext = os.path.splitext(file_path)
        
        if ext not in self.language_handlers:
            # Default basic chunking for unsupported languages
            return self._basic_chunk(file_path)
        
        return self.language_handlers[ext](file_path)
    
    def _chunk_python(self, file_path):
        """Semantically chunk a Python file using the ast module."""
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        try:
            tree = ast.parse(content)
            chunks = []
            
            # Extract imports as a chunk
            imports = []
            for node in ast.walk(tree):
                if isinstance(node, (ast.Import, ast.ImportFrom)):
                    imports.append(ast.get_source_segment(content, node))
            
            if imports:
                chunks.append({
                    'file_path': file_path,
                    'type': 'imports',
                    'content': '\n'.join(imports)
                })
            
            # Extract classes and functions
            for node in tree.body:
                if isinstance(node, ast.ClassDef):
                    chunks.append({
                        'file_path': file_path,
                        'type': 'class',
                        'name': node.name,
                        'content': ast.get_source_segment(content, node)
                    })
                elif isinstance(node, ast.FunctionDef):
                    chunks.append({
                        'file_path': file_path,
                        'type': 'function',
                        'name': node.name,
                        'content': ast.get_source_segment(content, node)
                    })
            
            return chunks
            
        except SyntaxError:
            # Fall back to basic chunking if parsing fails
            return self._basic_chunk(file_path)
    
    def _basic_chunk(self, file_path):
        """Basic chunking for files that can't be parsed."""
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        return [{
            'file_path': file_path,
            'type': 'content',
            'content': content
        }]
    
    # Other language handlers would be implemented similarly
    def _chunk_javascript(self, file_path):
        return self._basic_chunk(file_path)
        
    def _chunk_typescript(self, file_path):
        return self._basic_chunk(file_path)
        
    def _chunk_java(self, file_path):
        return self._basic_chunk(file_path)
        
    def _chunk_cpp(self, file_path):
        return self._basic_chunk(file_path)
        
    def _chunk_c(self, file_path):
        return self._basic_chunk(file_path)

def process_codebase(repo_path):
    """Process a codebase using semantic chunking."""
    chunker = SemanticChunker()
    chunks = []
    
    for file_path in get_source_files(repo_path):
        file_chunks = chunker.chunk_file(file_path)
        chunks.extend(file_chunks)
    
    return chunks

def get_source_files(repo_path):
    """Get all source code files in the repository."""
    source_files = []
    
    for root, _, files in os.walk(repo_path):
        for file in files:
            # Skip hidden files and directories
            if file.startswith('.'):
                continue
                
            # Skip common non-source directories
            if any(part.startswith('.') or part in ['node_modules', 'venv', 'build', 'dist'] 
                  for part in root.split(os.sep)):
                continue
                
            # Check file extensions for code files
            _, ext = os.path.splitext(file)
            if ext in ['.py', '.js', '.ts', '.jsx', '.tsx', '.java', '.c', '.cpp', '.h', '.hpp', '.cs', '.go', '.rb']:
                file_path = os.path.join(root, file)
                source_files.append(file_path)
    
    return source_files
```

### The Importance of Semantic Boundaries

Unlike naive chunking based on character count, semantic chunking respects code structure:

<div className="comparison-container">
  <div className="naive-chunking">
    <h4>Naive Chunking</h4>
    <pre>
{`// Chunk 1
class UserService {
  constructor(private userRepo: UserRepository) {}
  
  async getUserById(id: string): Promise<User | null> {
    return this.userRepo.findById(id);
  }
  
  async createUser(userData: UserInput): Promise<User> {
    // Validate user data
    if (!userData.email || !userData.name) {
      throw new Error('Invalid us`}
    </pre>
    <pre>
{`// Chunk 2
er data');
    }
    
    const existingUser = await this.userRepo.findByEmail(userData.email);
    if (existingUser) {
      throw new Error('User with this email already exists');
    }
    
    return this.userRepo.create(userData);
  }
}`}
    </pre>
  </div>
  
  <div className="semantic-chunking">
    <h4>Semantic Chunking</h4>
    <pre>
{`// Chunk 1
class UserService {
  constructor(private userRepo: UserRepository) {}
  
  async getUserById(id: string): Promise<User | null> {
    return this.userRepo.findById(id);
  }
}`}
    </pre>
    <pre>
{`// Chunk 2
class UserService {
  // ... constructor and other methods ...
  
  async createUser(userData: UserInput): Promise<User> {
    // Validate user data
    if (!userData.email || !userData.name) {
      throw new Error('Invalid user data');
    }
    
    const existingUser = await this.userRepo.findByEmail(userData.email);
    if (existingUser) {
      throw new Error('User with this email already exists');
    }
    
    return this.userRepo.create(userData);
  }
}`}
    </pre>
  </div>
</div>

## Demo 3: Interacting with Claude 3.7 Sonnet

Now that we have our chunked codebase, let's see how to interact with Claude 3.7 Sonnet:

```python
import anthropic
import os
from typing import List, Dict, Any
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

def select_relevant_chunks(chunks: List[Dict[str, Any]], question: str, top_n: int = 5) -> List[Dict[str, Any]]:
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

def create_sample_code():
    """Create a sample code file to demonstrate the chunking."""
    sample_code = '''
import os
import json
from datetime import datetime
from typing import Dict, List, Optional, Union

class UserAuthenticator:
    """Handles user authentication and session management."""
    
    def __init__(self, config_path: str):
        """Initialize the authenticator with configuration."""
        self.config = self._load_config(config_path)
        self.active_sessions = {}
        self.token_expiry = self.config.get("token_expiry", 3600)  # Default 1 hour
        
    def _load_config(self, config_path: str) -> Dict:
        """Load configuration from a JSON file."""
        try:
            with open(config_path, 'r') as f:
                return json.load(f)
        except (FileNotFoundError, json.JSONDecodeError) as e:
            print(f"Error loading config: {e}")
            return {"database_path": "users.db", "token_expiry": 3600}
            
    def authenticate(self, username: str, password: str) -> Optional[str]:
        """Authenticate a user and return a session token."""
        user = self._verify_credentials(username, password)
        if not user:
            return None
            
        # Generate session token
        token = self._generate_token(user["id"])
        self.active_sessions[token] = {
            "user_id": user["id"],
            "expires_at": datetime.now().timestamp() + self.token_expiry
        }
        
        return token
        
    def _verify_credentials(self, username: str, password: str) -> Optional[Dict]:
        """Verify user credentials against the database."""
        # In a real implementation, this would check against a secure database
        # This is a simplified example
        if username == "admin" and password == "secure_password":
            return {"id": "usr_123", "username": "admin", "role": "admin"}
        return None
        
    def _generate_token(self, user_id: str) -> str:
        """Generate a unique session token."""
        # In a real implementation, this would use a secure method
        # This is a simplified example
        timestamp = datetime.now().timestamp()
        return f"token_{user_id}_{timestamp}"
        
    def validate_token(self, token: str) -> bool:
        """Validate a session token."""
        if token not in self.active_sessions:
            return False
            
        session = self.active_sessions[token]
        if session["expires_at"] < datetime.now().timestamp():
            # Token has expired
            del self.active_sessions[token]
            return False
            
        return True
        
    def logout(self, token: str) -> bool:
        """Log out a user by invalidating their session token."""
        if token in self.active_sessions:
            del self.active_sessions[token]
            return True
        return False

class UserManager:
    """Manages user accounts and profiles."""
    
    def __init__(self, database_path: str):
        """Initialize the user manager with a database path."""
        self.database_path = database_path
        
    def create_user(self, username: str, password: str, email: str) -> bool:
        """Create a new user account."""
        # In a real implementation, this would add to a database
        # This is a simplified example
        print(f"Creating user: {username}, {email}")
        return True
        
    def update_profile(self, user_id: str, profile_data: Dict) -> bool:
        """Update a user's profile information."""
        # In a real implementation, this would update a database
        # This is a simplified example
        print(f"Updating profile for user {user_id}: {profile_data}")
        return True
        
    def get_user(self, user_id: str) -> Optional[Dict]:
        """Get user information by ID."""
        # In a real implementation, this would query a database
        # This is a simplified example
        if user_id == "usr_123":
            return {
                "id": "usr_123",
                "username": "admin",
                "email": "admin@example.com",
                "created_at": "2023-01-01T00:00:00Z"
            }
        return None
    '''
    
    with open('sample_code.py', 'w') as f:
        f.write(sample_code)

def get_language_from_path(file_path: str) -> str:
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

def analyze_codebase(chunks: List[Dict[str, Any]], question: str) -> str:
    """Send code chunks to Claude 3.7 Sonnet and get analysis."""
    client = anthropic.Anthropic(api_key=os.environ.get("ANTHROPIC_API_KEY"))
    
    context = ""
    for chunk in select_relevant_chunks(chunks, question):
        context += f"File: {chunk['file_path']}\n"
        context += f"```{get_language_from_path(chunk['file_path'])}\n"
        context += chunk['content'] + "\n```\n\n"
    
    message = client.messages.create(
        model="claude-3-sonnet-20240229",
        max_tokens=4000,
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

def main():
    """Main function to run the demo."""
    print("Claude 3.7 Sonnet Code Understanding Demo")
    print("----------------------------------------")
    
    # Create sample code file
    print("\nCreating sample code file...")
    create_sample_code()
    print("Sample code created in sample_code.py")
    
    # Process the codebase
    print("\nProcessing codebase...")
    chunks = process_codebase(".")
    print(f"Found {len(chunks)} code chunks")
    
    # Ask questions about the code
    questions = [
        "Explain the authentication flow in this code. How are user credentials validated?",
        "What security concerns exist in the current implementation?",
        "How does the token expiration mechanism work?",
        "What improvements would you suggest to make this code more secure?"
    ]
    
    for i, question in enumerate(questions, 1):
        print(f"\n\nQuestion {i}: {question}")
        print("-" * 80)
        
        try:
            answer = analyze_codebase(chunks, question)
            print("\nClaude's Analysis:")
            print(answer)
        except Exception as e:
            print(f"Error getting analysis: {e}")
            print("Make sure you've set the ANTHROPIC_API_KEY environment variable correctly.")

# Example usage
if __name__ == "__main__":
    main()
```

## Demo 4: Real-World Use Cases

Let's explore some practical applications of Claude 3.7 Sonnet for code understanding.

### Architecture Discovery

When joining a new project, Claude can help you understand the overall architecture:

```python
questions = [
    "What's the high-level architecture of this application?",
    "Identify the main components and how they interact with each other.",
    "Where is the entry point of this application?",
    "Explain the data flow from user request to database and back."
]

for question in questions:
    print(f"\n--- {question} ---\n")
    print(analyze_codebase(chunks, question))
```

### Bug Investigation

When tracking down a bug, Claude can help analyze the relevant code:

```python
bug_description = """
We're seeing an intermittent error where users get logged out unexpectedly.
The error seems to occur when multiple requests are made simultaneously.
Error message: "Token validation failed: signature expired"
"""

questions = [
    f"Based on this bug description, what could be causing the issue? {bug_description}",
    "How is the authentication token being validated in the codebase?",
    "Are there any race conditions or thread safety issues in the token validation code?",
    "How is token expiration handled in this application?"
]

for question in questions:
    print(f"\n--- {question} ---\n")
    print(analyze_codebase(chunks, question))
```

### Code Refactoring

Claude can help identify areas for improvement and suggest refactoring strategies:

```python
refactoring_questions = [
    "Which parts of this codebase would benefit most from refactoring?",
    "Are there any code smells or anti-patterns in the authentication service?",
    "How could we improve error handling throughout the application?",
    "Suggest ways to make the UserService more testable."
]

for question in refactoring_questions:
    print(f"\n--- {question} ---\n")
    print(analyze_codebase(chunks, question))
```

## Demo 5: Interactive Web Interface

For a more user-friendly experience, let's create a simple web interface using Streamlit:

```python
# Save this as code_analysis_app.py
import streamlit as st
import os
import sys
import json
import time
import tempfile
import shutil
from pathlib import Path
import anthropic
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
import ast
from typing import List, Dict, Any, Optional

# Import our code analysis functions
# Make sure to save the semantic chunker and analysis code first
from semantic_chunker import SemanticChunker, process_codebase, select_relevant_chunks
from sample_code import generate_sample_code

# Set page config
st.set_page_config(
    page_title="Claude 3.7 Sonnet Code Understanding",
    page_icon="🧠",
    layout="wide"
)

st.title("Code Understanding with Claude 3.7 Sonnet")
st.markdown("Analyze and understand code with Claude 3.7 Sonnet's semantic code understanding capabilities")

# Create tabs for different modes
tab1, tab2 = st.tabs(["Analyze Sample Code", "Analyze Custom Code"])

with tab1:
    st.header("Analyze Sample Authentication System")
    
    # API key input
    api_key = st.text_input("Anthropic API Key", type="password", key="api_key1")
    
    if not api_key:
        st.warning("Please enter your Anthropic API key to proceed")
    else:
        os.environ["ANTHROPIC_API_KEY"] = api_key
        
        # Generate sample code if needed
        if st.button("Load Sample Code"):
            with st.spinner("Generating sample code..."):
                # Create a temp directory for sample code
                temp_dir = tempfile.mkdtemp()
                sample_file = Path(temp_dir) / "auth_system.py"
                
                # Write sample code
                with open(sample_file, "w") as f:
                    f.write(generate_sample_code())
                
                # Process the codebase
                chunks = process_codebase(temp_dir)
                st.session_state.sample_chunks = chunks
                st.session_state.sample_code_path = temp_dir
                
                st.success(f"Sample code loaded with {len(chunks)} semantic chunks!")
                
                # Display sample code
                with st.expander("View Sample Code"):
                    st.code(generate_sample_code(), language="python")
        
        # Only show analysis options if code is loaded
        if "sample_chunks" in st.session_state:
            # Predefined questions
            questions = [
                "Explain the authentication flow in this code",
                "What security concerns exist in the current implementation?",
                "How does the token expiration mechanism work?",
                "What improvements would you suggest for this code?",
                "Custom question..."
            ]
            
            selected_question = st.selectbox("Select a question", questions)
            
            if selected_question == "Custom question...":
                question = st.text_area("Enter your question about the code")
            else:
                question = selected_question
                
            if question and st.button("Analyze Code", key="analyze1"):
                with st.spinner("Claude is analyzing the code..."):
                    try:
                        # Analyze the code
                        client = anthropic.Anthropic(api_key=api_key)
                        
                        # Prepare context
                        context = ""
                        for chunk in select_relevant_chunks(st.session_state.sample_chunks, question):
                            context += f"File: {chunk['file_path']}\n"
                            context += f"```python\n{chunk['content']}\n```\n\n"
                        
                        # Generate response
                        message = client.messages.create(
                            model="claude-3-sonnet-20240229",
                            max_tokens=4000,
                            temperature=0.0,
                            system="You are a senior software engineer with expertise in analyzing and explaining code.",
                            messages=[
                                {
                                    "role": "user",
                                    "content": f"I'm analyzing a codebase and need your help understanding it. Here are relevant parts of the code:\n\n{context}\n\n{question}\n\nPlease analyze the code and provide a detailed answer."
                                }
                            ]
                        )
                        
                        st.markdown("### Claude's Analysis")
                        st.markdown(message.content[0].text)
                        
                    except Exception as e:
                        st.error(f"Error analyzing code: {str(e)}")
                        st.info("Make sure your API key is correct and you have the necessary permissions.")

with tab2:
    st.header("Analyze Your Own Code")
    
    # API key input
    api_key = st.text_input("Anthropic API Key", type="password", key="api_key2")
    
    if not api_key:
        st.warning("Please enter your Anthropic API key to proceed")
    else:
        os.environ["ANTHROPIC_API_KEY"] = api_key
        
        # Code input
        user_code = st.text_area("Paste your code here", height=300, placeholder="Paste your Python code here...", key="user_code")
        
        if user_code and st.button("Process Code"):
            with st.spinner("Processing code..."):
                # Create a temp directory for user code
                temp_dir = tempfile.mkdtemp()
                user_file = Path(temp_dir) / "user_code.py"
                
                # Write user code
                with open(user_file, "w") as f:
                    f.write(user_code)
                
                # Process the codebase
                chunks = process_codebase(temp_dir)
                st.session_state.user_chunks = chunks
                st.session_state.user_code_path = temp_dir
                
                st.success(f"Code processed with {len(chunks)} semantic chunks!")
                
                # Show chunks
                with st.expander("View Semantic Chunks"):
                    for i, chunk in enumerate(chunks):
                        st.code(chunk['content'], language="python")
                        st.write(f"Chunk Type: {chunk.get('type', 'Unknown')}")
                        st.write("---")
        
        # Only show analysis options if code is processed
        if "user_chunks" in st.session_state:
            question = st.text_area("What would you like to know about this code?", 
                                   "Explain what this code does and how it works.")
            
            if st.button("Analyze", key="analyze2"):
                with st.spinner("Claude is analyzing the code..."):
                    try:
                        # Analyze the code
                        client = anthropic.Anthropic(api_key=api_key)
                        
                        # Prepare context
                        context = ""
                        for chunk in select_relevant_chunks(st.session_state.user_chunks, question):
                            context += f"File: {chunk['file_path']}\n"
                            context += f"```python\n{chunk['content']}\n```\n\n"
                        
                        # Generate response
                        message = client.messages.create(
                            model="claude-3-sonnet-20240229",
                            max_tokens=4000,
                            temperature=0.0,
                            system="You are a senior software engineer with expertise in analyzing and explaining code.",
                            messages=[
                                {
                                    "role": "user",
                                    "content": f"I'm analyzing a codebase and need your help understanding it. Here are relevant parts of the code:\n\n{context}\n\n{question}\n\nPlease analyze the code and provide a detailed answer."
                                }
                            ]
                        )
                        
                        st.markdown("### Claude's Analysis")
                        st.markdown(message.content[0].text)
                        
                    except Exception as e:
                        st.error(f"Error analyzing code: {str(e)}")
                        st.info("Make sure your API key is correct and you have the necessary permissions.")

# Clean up temp directories on exit
def cleanup():
    if "sample_code_path" in st.session_state and os.path.exists(st.session_state.sample_code_path):
        shutil.rmtree(st.session_state.sample_code_path)
    
    if "user_code_path" in st.session_state and os.path.exists(st.session_state.user_code_path):
        shutil.rmtree(st.session_state.user_code_path)

# Register cleanup
import atexit
atexit.register(cleanup)
```

To create the supporting modules, save the following files:

**semantic_chunker.py**:
```python
import os
import re
import ast
from typing import List, Dict, Any
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

class SemanticChunker:
    """A class for semantically chunking code files."""
    
    def __init__(self):
        self.language_handlers = {
            '.py': self._chunk_python,
            '.js': self._chunk_javascript,
            '.ts': self._chunk_typescript,
            '.java': self._chunk_java,
            '.cpp': self._chunk_cpp,
            '.c': self._chunk_c
        }
    
    def chunk_file(self, file_path):
        """Chunk a file based on its extension."""
        _, ext = os.path.splitext(file_path)
        
        if ext not in self.language_handlers:
            # Default basic chunking for unsupported languages
            return self._basic_chunk(file_path)
        
        return self.language_handlers[ext](file_path)
    
    def _chunk_python(self, file_path):
        """Semantically chunk a Python file using the ast module."""
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        try:
            tree = ast.parse(content)
            chunks = []
            
            # Extract imports as a chunk
            imports = []
            for node in ast.walk(tree):
                if isinstance(node, (ast.Import, ast.ImportFrom)):
                    imports.append(ast.get_source_segment(content, node))
            
            if imports:
                chunks.append({
                    'file_path': file_path,
                    'type': 'imports',
                    'content': '\n'.join(imports)
                })
            
            # Extract classes and functions
            for node in tree.body:
                if isinstance(node, ast.ClassDef):
                    chunks.append({
                        'file_path': file_path,
                        'type': 'class',
                        'name': node.name,
                        'content': ast.get_source_segment(content, node)
                    })
                elif isinstance(node, ast.FunctionDef):
                    chunks.append({
                        'file_path': file_path,
                        'type': 'function',
                        'name': node.name,
                        'content': ast.get_source_segment(content, node)
                    })
            
            return chunks
            
        except SyntaxError:
            # Fall back to basic chunking if parsing fails
            return self._basic_chunk(file_path)
    
    def _basic_chunk(self, file_path):
        """Basic chunking for files that can't be parsed."""
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        return [{
            'file_path': file_path,
            'type': 'content',
            'content': content
        }]
    
    # Other language handlers would be implemented similarly
    def _chunk_javascript(self, file_path):
        return self._basic_chunk(file_path)
        
    def _chunk_typescript(self, file_path):
        return self._basic_chunk(file_path)
        
    def _chunk_java(self, file_path):
        return self._basic_chunk(file_path)
        
    def _chunk_cpp(self, file_path):
        return self._basic_chunk(file_path)
        
    def _chunk_c(self, file_path):
        return self._basic_chunk(file_path)

def process_codebase(repo_path):
    """Process a codebase using semantic chunking."""
    chunker = SemanticChunker()
    chunks = []
    
    for file_path in get_source_files(repo_path):
        file_chunks = chunker.chunk_file(file_path)
        chunks.extend(file_chunks)
    
    return chunks

def get_source_files(repo_path):
    """Get all source code files in the repository."""
    source_files = []
    
    for root, _, files in os.walk(repo_path):
        for file in files:
            # Skip hidden files and directories
            if file.startswith('.'):
                continue
                
            # Skip common non-source directories
            if any(part.startswith('.') or part in ['node_modules', 'venv', 'build', 'dist'] 
                  for part in root.split(os.sep)):
                continue
                
            # Check file extensions for code files
            _, ext = os.path.splitext(file)
            if ext in ['.py', '.js', '.ts', '.jsx', '.tsx', '.java', '.c', '.cpp', '.h', '.hpp', '.cs', '.go', '.rb']:
                file_path = os.path.join(root, file)
                source_files.append(file_path)
    
    return source_files

def select_relevant_chunks(chunks: List[Dict[str, Any]], question: str, top_n: int = 5) -> List[Dict[str, Any]]:
    """Select the most relevant chunks based on the question."""
    if not chunks:
        return []
        
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
    top_n = min(top_n, len(chunks))  # Make sure we don't ask for more chunks than exist
    top_indices = np.argsort(similarities)[-top_n:][::-1]
    
    return [chunks[i] for i in top_indices]
```

**sample_code.py**:
```python
def generate_sample_code():
    """Generate sample authentication code for demonstration."""
    return '''
import os
import json
import hashlib
import secrets
from datetime import datetime
from typing import Dict, List, Optional, Union

class UserAuthenticator:
    """Handles user authentication and session management."""
    
    def __init__(self, config_path: str):
        """Initialize the authenticator with configuration."""
        self.config = self._load_config(config_path)
        self.active_sessions = {}
        self.token_expiry = self.config.get("token_expiry", 3600)  # Default 1 hour
        self.max_failed_attempts = self.config.get("max_failed_attempts", 5)
        self.lockout_period = self.config.get("lockout_period", 3600)  # Default 1 hour
        self.failed_attempts = {}
        
    def _load_config(self, config_path: str) -> Dict:
        """Load configuration from a JSON file."""
        try:
            with open(config_path, 'r') as f:
                return json.load(f)
        except (FileNotFoundError, json.JSONDecodeError) as e:
            print(f"Error loading config: {e}")
            return {"database_path": "users.db", "token_expiry": 3600}
            
    def authenticate(self, username: str, password: str) -> Optional[str]:
        """Authenticate a user and return a session token."""
        # Check if user is locked out
        if self._is_locked_out(username):
            print(f"User {username} is locked out due to too many failed attempts")
            return None
            
        user = self._verify_credentials(username, password)
        if not user:
            self._record_failed_attempt(username)
            return None
            
        # Reset failed attempts on successful login
        if username in self.failed_attempts:
            del self.failed_attempts[username]
            
        # Generate session token
        token = self._generate_token(user["id"])
        self.active_sessions[token] = {
            "user_id": user["id"],
            "expires_at": datetime.now().timestamp() + self.token_expiry,
            "user_agent": os.environ.get("HTTP_USER_AGENT", "unknown")
        }
        
        return token
        
    def _is_locked_out(self, username: str) -> bool:
        """Check if a user is locked out due to too many failed attempts."""
        if username not in self.failed_attempts:
            return False
            
        attempts = self.failed_attempts[username]
        if len(attempts) < self.max_failed_attempts:
            return False
            
        # Check if the lockout period has expired for the oldest attempt
        oldest_attempt = min(attempts)
        lockout_expiry = oldest_attempt + self.lockout_period
        
        return datetime.now().timestamp() < lockout_expiry
        
    def _record_failed_attempt(self, username: str) -> None:
        """Record a failed authentication attempt."""
        if username not in self.failed_attempts:
            self.failed_attempts[username] = []
            
        # Add current timestamp
        self.failed_attempts[username].append(datetime.now().timestamp())
        
        # Keep only the most recent max_failed_attempts
        if len(self.failed_attempts[username]) > self.max_failed_attempts:
            self.failed_attempts[username] = self.failed_attempts[username][-self.max_failed_attempts:]
        
    def _verify_credentials(self, username: str, password: str) -> Optional[Dict]:
        """Verify user credentials against the database."""
        # In a real implementation, this would check against a secure database
        # This is a simplified example
        if username == "admin" and password == "secure_password":
            return {"id": "usr_123", "username": "admin", "role": "admin"}
        return None
        
    def _generate_token(self, user_id: str) -> str:
        """Generate a unique session token."""
        # In a real implementation, this would use a secure method
        # This is a simplified example using the secrets module
        random_bytes = secrets.token_bytes(32)
        timestamp = str(datetime.now().timestamp())
        token_data = f"{user_id}-{timestamp}-{random_bytes.hex()}"
        return hashlib.sha256(token_data.encode()).hexdigest()
        
    def validate_token(self, token: str) -> bool:
        """Validate a session token."""
        if token not in self.active_sessions:
            return False
            
        session = self.active_sessions[token]
        if session["expires_at"] < datetime.now().timestamp():
            # Token has expired
            del self.active_sessions[token]
            return False
            
        return True
        
    def logout(self, token: str) -> bool:
        """Log out a user by invalidating their session token."""
        if token in self.active_sessions:
            del self.active_sessions[token]
            return True
        return False

class UserManager:
    """Manages user accounts and profiles."""
    
    def __init__(self, database_path: str):
        """Initialize the user manager with a database path."""
        self.database_path = database_path
        
    def create_user(self, username: str, password: str, email: str) -> bool:
        """Create a new user account."""
        # In a real implementation, this would:
        # 1. Hash the password securely with a salt
        # 2. Store the user in a database
        # 3. Validate email format
        # 4. Check for existing users with same username/email
        
        # This is a simplified example
        print(f"Creating user: {username}, {email}")
        
        # Hash password - in a real system, use a proper password hashing library
        password_hash = hashlib.sha256(password.encode()).hexdigest()
        print(f"Password hash: {password_hash[:10]}...")
        
        return True
        
    def update_profile(self, user_id: str, profile_data: Dict) -> bool:
        """Update a user's profile information."""
        # In a real implementation, this would update a database
        # This is a simplified example
        print(f"Updating profile for user {user_id}: {profile_data}")
        return True
        
    def get_user(self, user_id: str) -> Optional[Dict]:
        """Get user information by ID."""
        # In a real implementation, this would query a database
        # This is a simplified example
        if user_id == "usr_123":
            return {
                "id": "usr_123",
                "username": "admin",
                "email": "admin@example.com",
                "created_at": "2023-01-01T00:00:00Z"
            }
        return None
    '''

# For testing
if __name__ == "__main__":
    print(generate_sample_code())
```

Run this with `streamlit run code_analysis_app.py` to launch the web interface.

## Best Practices

Here are some tips for getting the most out of Claude 3.7 Sonnet for code understanding:

### 1. Be Specific in Your Questions

Instead of asking "How does this code work?", ask "How does the authentication middleware validate JWT tokens in this Express.js application?"

### 2. Provide Relevant Context

Tell Claude about the purpose of the application and any specific terminology or patterns used in the codebase.

### 3. Break Down Complex Codebases

For very large codebases, focus on specific subsystems or features rather than trying to analyze everything at once.

### 4. Use Follow-up Questions

Start with high-level questions about architecture, then drill down into specific components or functions.

### 5. Augment with Code Visualization

Combine Claude's text analysis with visual tools like code graphs to get a complete understanding of complex codebases.

## Conclusion

Claude 3.7 Sonnet represents a major advancement in AI-assisted code understanding. By leveraging its 100K context window and advanced language capabilities, developers can now comprehend complex codebases more quickly and thoroughly than ever before.

This demo has shown you:
- How to prepare code for analysis
- Techniques for effective semantic chunking
- Strategies for prompting Claude for code insights
- Real-world applications for code understanding

The complete code for this demo is available in the files described above. Try it out with your own projects and see how Claude 3.7 Sonnet can transform your code understanding workflow!

## Running the Demo

To run the complete demo:

1. **Create the required files**:
   - `semantic_chunker.py`: The semantic chunking implementation
   - `sample_code.py`: The sample code generator
   - `code_analysis_app.py`: The Streamlit web application

2. **Install dependencies**:
   ```bash
   pip install anthropic streamlit scikit-learn numpy
   ```

3. **Run the web application**:
   ```bash
   streamlit run code_analysis_app.py
   ```

4. **Use the web interface**:
   - Enter your Anthropic API key
   - Choose between analyzing sample code or your own code
   - Ask questions about the code and see Claude 3.7 Sonnet's analysis

## Additional Resources

- [Semantic Chunking Guide](/docs/guides/semantic-chunking)
- [Prompt Engineering for Code](/docs/guides/prompt-engineering)
- [Anthropic Claude API Documentation](https://docs.anthropic.com/claude/reference/getting-started-with-the-api)
- [LiteLLM Integration Guide](/docs/guides/litellm-integration) for comparing model performance