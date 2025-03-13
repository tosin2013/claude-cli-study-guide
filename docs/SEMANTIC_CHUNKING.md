# Semantic Chunking for Large Codebases

This document outlines the implementation details for the semantic chunking algorithm used in the Claude 3.7 Sonnet demo. Semantic chunking is a technique for dividing large codebases into semantically meaningful segments that can be processed by Large Language Models (LLMs) more effectively.

## Core Concepts

Semantic chunking differs from simple character or line-based chunking in several key ways:

1. **Preserves semantic units**: Chunks maintain coherent units of code like functions, classes, and logical blocks
2. **Respects syntax boundaries**: Chunks don't break in the middle of syntax constructs
3. **Prioritizes contextual relevance**: Related code segments stay together
4. **Optimizes for token limits**: Creates chunks that fit within model context windows

## Implementation

Below is the Python implementation of our semantic chunking algorithm for codebases.

```python
import os
import re
from typing import List, Dict, Tuple, Optional
import ast
import tokenize
from io import BytesIO

class SemanticChunker:
    """
    A class for semantically chunking code files based on their structure and content.
    """
    
    def __init__(self, max_chunk_size: int = 8000, overlap: int = 200):
        """
        Initialize the SemanticChunker.
        
        Args:
            max_chunk_size (int): Maximum size of each chunk in characters
            overlap (int): Number of characters to overlap between chunks
        """
        self.max_chunk_size = max_chunk_size
        self.overlap = overlap
    
    def chunk_file(self, file_path: str) -> List[Dict[str, str]]:
        """
        Chunk a single file based on its content and extension.
        
        Args:
            file_path (str): Path to the file
            
        Returns:
            List[Dict[str, str]]: List of chunks with metadata
        """
        if not os.path.exists(file_path):
            raise FileNotFoundError(f"File not found: {file_path}")
            
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        extension = os.path.splitext(file_path)[1].lower()
        
        # Choose appropriate chunking strategy based on file type
        if extension in ['.py']:
            return self._chunk_python_file(content, file_path)
        elif extension in ['.js', '.jsx', '.ts', '.tsx']:
            return self._chunk_javascript_file(content, file_path)
        elif extension in ['.java', '.kt', '.scala']:
            return self._chunk_java_family_file(content, file_path)
        elif extension in ['.c', '.cpp', '.h', '.hpp', '.cc']:
            return self._chunk_c_family_file(content, file_path)
        else:
            # Default to general code chunking for other file types
            return self._chunk_general_code(content, file_path)
    
    def _chunk_python_file(self, content: str, file_path: str) -> List[Dict[str, str]]:
        """
        Chunk a Python file using AST parsing to preserve semantic structure.
        
        Args:
            content (str): File content
            file_path (str): Path to the file
            
        Returns:
            List[Dict[str, str]]: List of chunks with metadata
        """
        chunks = []
        
        try:
            # Parse the Python file
            tree = ast.parse(content)
            
            # Extract classes and functions as primary chunks
            class_defs = []
            function_defs = []
            imports = []
            
            for node in ast.walk(tree):
                if isinstance(node, ast.ClassDef):
                    class_defs.append((node, self._get_node_source(content, node)))
                elif isinstance(node, ast.FunctionDef) or isinstance(node, ast.AsyncFunctionDef):
                    # Only top-level functions
                    if isinstance(node.parent, ast.Module):
                        function_defs.append((node, self._get_node_source(content, node)))
                elif isinstance(node, (ast.Import, ast.ImportFrom)):
                    imports.append((node, self._get_node_source(content, node)))
            
            # Create a chunk for imports
            if imports:
                import_chunk = "\n".join([imp[1] for imp in imports])
                chunks.append({
                    "content": import_chunk,
                    "file_path": file_path,
                    "type": "imports",
                    "size": len(import_chunk)
                })
            
            # Create chunks for classes
            for class_node, class_source in class_defs:
                if len(class_source) <= self.max_chunk_size:
                    chunks.append({
                        "content": class_source,
                        "file_path": file_path,
                        "type": "class",
                        "name": class_node.name,
                        "size": len(class_source)
                    })
                else:
                    # If class is too large, split its methods into separate chunks
                    method_chunks = self._split_class_methods(class_node, content)
                    chunks.extend(method_chunks)
            
            # Create chunks for functions
            for func_node, func_source in function_defs:
                if len(func_source) <= self.max_chunk_size:
                    chunks.append({
                        "content": func_source,
                        "file_path": file_path,
                        "type": "function",
                        "name": func_node.name,
                        "size": len(func_source)
                    })
                else:
                    # If function is too large, split it by logical blocks
                    sub_chunks = self._split_large_function(func_source, func_node.name)
                    chunks.extend(sub_chunks)
            
            # If there are sections not covered by classes and functions, add them as general chunks
            covered_lines = set()
            for chunk in chunks:
                chunk_lines = chunk["content"].count('\n') + 1
                chunk_start_line = content[:content.find(chunk["content"])].count('\n') + 1
                for i in range(chunk_start_line, chunk_start_line + chunk_lines):
                    covered_lines.add(i)
            
            # Get uncovered lines
            total_lines = content.count('\n') + 1
            uncovered_lines = [i for i in range(1, total_lines + 1) if i not in covered_lines]
            
            if uncovered_lines:
                # Group consecutive uncovered lines
                groups = []
                current_group = [uncovered_lines[0]]
                
                for line in uncovered_lines[1:]:
                    if line == current_group[-1] + 1:
                        current_group.append(line)
                    else:
                        groups.append(current_group)
                        current_group = [line]
                
                if current_group:
                    groups.append(current_group)
                
                # Create chunks for each group of uncovered lines
                for group in groups:
                    start_idx = self._line_to_char_index(content, group[0])
                    end_idx = self._line_to_char_index(content, group[-1] + 1) if group[-1] < total_lines else len(content)
                    
                    uncovered_content = content[start_idx:end_idx]
                    if len(uncovered_content.strip()) > 0:  # Only add non-empty chunks
                        chunks.append({
                            "content": uncovered_content,
                            "file_path": file_path,
                            "type": "general",
                            "size": len(uncovered_content)
                        })
            
        except SyntaxError:
            # Fall back to general code chunking if AST parsing fails
            chunks = self._chunk_general_code(content, file_path)
            
        return chunks
    
    def _get_node_source(self, content: str, node) -> str:
        """Extract source code for an AST node."""
        if hasattr(node, 'lineno') and hasattr(node, 'end_lineno'):
            start_idx = self._line_to_char_index(content, node.lineno)
            end_idx = self._line_to_char_index(content, node.end_lineno + 1)
            return content[start_idx:end_idx]
        return ""
    
    def _line_to_char_index(self, content: str, line_num: int) -> int:
        """Convert line number to character index in content."""
        lines = content.split('\n')
        return sum(len(lines[i]) + 1 for i in range(line_num - 1))
    
    def _split_class_methods(self, class_node, content: str) -> List[Dict[str, str]]:
        """Split a large class into method-based chunks."""
        method_chunks = []
        
        for node in ast.walk(class_node):
            if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
                method_source = self._get_node_source(content, node)
                method_chunks.append({
                    "content": method_source,
                    "file_path": class_node.name + "." + node.name,
                    "type": "method",
                    "class_name": class_node.name,
                    "name": node.name,
                    "size": len(method_source)
                })
        
        return method_chunks
    
    def _split_large_function(self, func_content: str, func_name: str) -> List[Dict[str, str]]:
        """Split a large function into logical blocks."""
        chunks = []
        
        # Use indentation to identify logical blocks
        lines = func_content.split('\n')
        current_chunk = []
        current_chunk_size = 0
        
        for line in lines:
            line_with_newline = line + '\n'
            line_size = len(line_with_newline)
            
            if current_chunk_size + line_size > self.max_chunk_size:
                # Start a new chunk if current one is full
                if current_chunk:
                    chunk_content = '\n'.join(current_chunk)
                    chunks.append({
                        "content": chunk_content,
                        "file_path": func_name,
                        "type": "function_part",
                        "name": func_name,
                        "size": len(chunk_content)
                    })
                    
                    # Start new chunk with overlap
                    if len(current_chunk) > self.overlap:
                        current_chunk = current_chunk[-self.overlap:]
                        current_chunk_size = sum(len(l) + 1 for l in current_chunk)
                    else:
                        current_chunk = []
                        current_chunk_size = 0
            
            current_chunk.append(line)
            current_chunk_size += line_size
        
        # Add the last chunk
        if current_chunk:
            chunk_content = '\n'.join(current_chunk)
            chunks.append({
                "content": chunk_content,
                "file_path": func_name,
                "type": "function_part",
                "name": func_name,
                "size": len(chunk_content)
            })
        
        return chunks
    
    def _chunk_javascript_file(self, content: str, file_path: str) -> List[Dict[str, str]]:
        """
        Chunk a JavaScript/TypeScript file preserving function and class definitions.
        Uses regex patterns since we're not implementing a full JS parser.
        
        Args:
            content (str): File content
            file_path (str): Path to the file
            
        Returns:
            List[Dict[str, str]]: List of chunks with metadata
        """
        # Implementation details would go here
        # For brevity, we're using the general code chunker
        return self._chunk_general_code(content, file_path)
    
    def _chunk_java_family_file(self, content: str, file_path: str) -> List[Dict[str, str]]:
        """Chunk a Java-family file."""
        # Implementation details would go here
        return self._chunk_general_code(content, file_path)
    
    def _chunk_c_family_file(self, content: str, file_path: str) -> List[Dict[str, str]]:
        """Chunk a C-family file."""
        # Implementation details would go here
        return self._chunk_general_code(content, file_path)
    
    def _chunk_general_code(self, content: str, file_path: str) -> List[Dict[str, str]]:
        """
        General purpose code chunking algorithm based on logical blocks.
        
        Args:
            content (str): File content
            file_path (str): Path to the file
            
        Returns:
            List[Dict[str, str]]: List of chunks with metadata
        """
        chunks = []
        
        # Split the content into lines
        lines = content.split('\n')
        
        # Initialize variables for the current chunk
        current_chunk = []
        current_chunk_size = 0
        
        # Process each line
        for i, line in enumerate(lines):
            line_with_newline = line + '\n'
            line_size = len(line_with_newline)
            
            # Check if adding this line would exceed the max chunk size
            if current_chunk_size + line_size > self.max_chunk_size and current_chunk:
                # Save the current chunk and start a new one
                chunk_content = '\n'.join(current_chunk)
                chunks.append({
                    "content": chunk_content,
                    "file_path": file_path,
                    "type": "general",
                    "start_line": i - len(current_chunk) + 1,
                    "end_line": i,
                    "size": len(chunk_content)
                })
                
                # Start new chunk with overlap
                overlap_lines = min(self.overlap, len(current_chunk))
                current_chunk = current_chunk[-overlap_lines:]
                current_chunk_size = sum(len(l) + 1 for l in current_chunk)
            
            # Add the current line to the chunk
            current_chunk.append(line)
            current_chunk_size += line_size
        
        # Add the last chunk if there's anything left
        if current_chunk:
            chunk_content = '\n'.join(current_chunk)
            chunks.append({
                "content": chunk_content,
                "file_path": file_path,
                "type": "general",
                "start_line": len(lines) - len(current_chunk) + 1,
                "end_line": len(lines),
                "size": len(chunk_content)
            })
        
        return chunks

    def chunk_directory(self, directory_path: str, 
                        exclude_dirs: List[str] = None, 
                        include_extensions: List[str] = None) -> List[Dict[str, str]]:
        """
        Recursively chunk all files in a directory.
        
        Args:
            directory_path (str): Path to the directory
            exclude_dirs (List[str]): Directories to exclude (e.g., node_modules, .git)
            include_extensions (List[str]): File extensions to include
            
        Returns:
            List[Dict[str, str]]: List of chunks with metadata across all files
        """
        if not os.path.isdir(directory_path):
            raise ValueError(f"Not a directory: {directory_path}")
        
        if exclude_dirs is None:
            exclude_dirs = ['node_modules', '.git', 'venv', '__pycache__', 'dist', 'build']
            
        all_chunks = []
        
        for root, dirs, files in os.walk(directory_path):
            # Skip excluded directories
            dirs[:] = [d for d in dirs if d not in exclude_dirs]
            
            for file in files:
                file_path = os.path.join(root, file)
                
                # Skip files with unwanted extensions
                if include_extensions:
                    ext = os.path.splitext(file)[1].lower()
                    if ext not in include_extensions:
                        continue
                
                try:
                    file_chunks = self.chunk_file(file_path)
                    all_chunks.extend(file_chunks)
                except (UnicodeDecodeError, FileNotFoundError) as e:
                    print(f"Error processing {file_path}: {str(e)}")
                    continue
        
        return all_chunks
```

## Usage Example

Here's an example of how to use the semantic chunker:

```python
# Initialize the chunker
chunker = SemanticChunker(max_chunk_size=8000, overlap=200)

# Chunk a single file
file_chunks = chunker.chunk_file("path/to/your/code.py")

# Print the first chunk
print(f"Found {len(file_chunks)} chunks")
print(f"First chunk type: {file_chunks[0]['type']}")
print(f"First chunk size: {file_chunks[0]['size']} characters")
print(f"First chunk content preview: {file_chunks[0]['content'][:100]}...")

# Chunk an entire directory
directory_chunks = chunker.chunk_directory(
    "path/to/your/project",
    exclude_dirs=['node_modules', '.git', 'venv'],
    include_extensions=['.py', '.js', '.ts']
)

print(f"Found {len(directory_chunks)} chunks across the directory")
```

## Key Benefits of Semantic Chunking

1. **Improved Context Preservation**: By keeping related code together, the model can better understand the relationships between different parts of the code.

2. **Reduced Token Waste**: Traditional fixed-size chunking can split code in the middle of functions or classes, wasting tokens on incomplete context. Semantic chunking minimizes this waste.

3. **Better Query Results**: When searching through code, semantic chunks provide more meaningful results since they contain complete logical units.

4. **Enhanced Code Understanding**: Models can more accurately answer questions about code when provided with semantically coherent chunks.

## Integration with Claude 3.7 Sonnet

This semantic chunking algorithm is integrated with Claude 3.7 Sonnet in our demo to:

1. Process large codebases efficiently
2. Maintain context across related code sections
3. Optimize token usage for maximum value
4. Enable more accurate code understanding and search

The chunker outputs metadata with each chunk, allowing the LLM to understand the type of code segment (class, function, general code) and its relationship to other chunks.

## Future Improvements

1. **Language-Specific Parsers**: Implement dedicated parsers for more programming languages
2. **Semantic Similarity Chunking**: Use embeddings to group semantically related code segments
3. **Dependency-Aware Chunking**: Include related imports and dependencies with each chunk
4. **Adaptive Chunk Sizing**: Dynamically adjust chunk sizes based on code complexity 