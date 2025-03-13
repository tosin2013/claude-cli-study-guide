#!/usr/bin/env python3
"""
Semantic Chunking Analysis Experiment

This script analyzes how Claude CLI processes large codebases to understand
its semantic chunking mechanism. It sends a codebase to Claude CLI and analyzes
which portions are referenced in responses to specific queries.

Usage:
    python analyze_chunking.py --repo=/path/to/repo --query="Explain the authentication system"

Author: Claude CLI Study Project
License: MIT
"""

import argparse
import os
import json
import re
import subprocess
import hashlib
import time
from pathlib import Path


class ChunkingAnalyzer:
    """Analyzes Claude CLI's semantic chunking behavior."""

    def __init__(self, repo_path):
        """
        Initialize the analyzer.
        
        Args:
            repo_path: Path to the repository to analyze
        """
        self.repo_path = Path(repo_path).absolute()
        self.session_id = None
        self.results = {}

    def create_session(self):
        """Create a Claude CLI session for the experiment."""
        print(f"Creating Claude CLI session for {self.repo_path.name}...")
        
        # This is a study of Claude CLI, so we're using it directly
        result = subprocess.run(
            ["claude", "session", "create", "--name", f"chunk-study-{int(time.time())}"],
            capture_output=True, text=True
        )
        
        try:
            session_data = json.loads(result.stdout)
            self.session_id = session_data.get("id")
            print(f"Session created with ID: {self.session_id}")
            return self.session_id
        except json.JSONDecodeError:
            print("Failed to create session. Output:", result.stdout)
            print("Error:", result.stderr)
            return None

    def send_directory(self):
        """Send the repository directory to Claude CLI."""
        if not self.session_id:
            print("No active session. Please create a session first.")
            return False
        
        print(f"Sending directory {self.repo_path} to Claude CLI...")
        
        # Send the directory to Claude CLI
        result = subprocess.run(
            ["claude", "dir", "send", "--session", self.session_id, str(self.repo_path)],
            capture_output=True, text=True
        )
        
        try:
            output = json.loads(result.stdout) if result.stdout else {}
            print(f"Directory sent. Result: {output.get('status', 'unknown')}")
            return True
        except json.JSONDecodeError:
            print("Failed to send directory. Output:", result.stdout)
            print("Error:", result.stderr)
            return False

    def query_claude(self, query):
        """
        Send a query to Claude CLI.
        
        Args:
            query: The query text to send
            
        Returns:
            The response from Claude CLI
        """
        if not self.session_id:
            print("No active session. Please create a session first.")
            return None
        
        print(f"Sending query to Claude CLI: {query}")
        
        # Send the query to Claude CLI
        result = subprocess.run(
            ["claude", "prompt", "--session", self.session_id, query],
            capture_output=True, text=True
        )
        
        try:
            response = json.loads(result.stdout) if result.stdout else {}
            content = response.get("content", [{"text": ""}])[0].get("text", "")
            print(f"Received response of length {len(content)}")
            return response
        except json.JSONDecodeError:
            print("Failed to parse response. Output:", result.stdout)
            print("Error:", result.stderr)
            return None

    def analyze_file_references(self, response, files_info):
        """
        Analyze which files are referenced in the Claude response.
        
        Args:
            response: The Claude CLI response
            files_info: Dictionary mapping file paths to content
            
        Returns:
            Dictionary with file reference analysis
        """
        if not response:
            return {}
        
        content = response.get("content", [{"text": ""}])[0].get("text", "")
        token_usage = response.get("usage", {})
        
        # Analyze which files are referenced in the response
        file_references = {}
        for file_path, file_info in files_info.items():
            file_content = file_info["content"]
            
            # Check if the file is referenced by path
            path_referenced = False
            relative_path = str(file_path).replace(str(self.repo_path) + "/", "")
            if relative_path in content:
                path_referenced = True
            
            # Check which portions of the file content are referenced
            snippets = self._find_content_in_response(file_content, content)
            
            if path_referenced or snippets:
                file_references[relative_path] = {
                    "path_referenced": path_referenced,
                    "snippets": snippets,
                    "size": len(file_content),
                    "referenced_size": sum(len(s) for s in snippets),
                    "referenced_percentage": sum(len(s) for s in snippets) / len(file_content) if file_content else 0
                }
        
        return {
            "file_references": file_references,
            "token_usage": token_usage,
            "total_files": len(files_info),
            "referenced_files": len(file_references),
            "reference_rate": len(file_references) / len(files_info) if files_info else 0
        }

    def _find_content_in_response(self, file_content, response):
        """
        Find which portions of a file were included in a response.
        
        Args:
            file_content: Content of the file
            response: Text of the Claude response
            
        Returns:
            List of snippets from the file that appear in the response
        """
        # This is a simplified algorithm - in a real implementation, we would use
        # more sophisticated text similarity measures and language-specific parsing
        snippets = []
        
        # Split file into logical sections (functions, classes, etc.)
        # This is a very basic approach - we'd use language-specific parsers in a real scenario
        sections = re.split(r'(def\s+\w+|class\s+\w+)', file_content)
        
        for i in range(1, len(sections), 2):
            section = sections[i] + (sections[i+1] if i+1 < len(sections) else "")
            # Check if this section or a significant portion appears in the response
            if section in response or self._has_significant_overlap(section, response):
                snippets.append(section)
        
        return snippets

    def _has_significant_overlap(self, text, response, threshold=0.7):
        """
        Check if there is significant text overlap between a piece of text and response.
        
        Args:
            text: The text to check
            response: The response to check against
            threshold: Minimum percentage of lines that must match
            
        Returns:
            True if there is significant overlap, False otherwise
        """
        lines = text.split('\n')
        matched_lines = 0
        
        for line in lines:
            line = line.strip()
            if len(line) > 10 and line in response:  # Only check non-trivial lines
                matched_lines += 1
        
        return (matched_lines / len(lines) > threshold) if lines else False

    def collect_files_info(self):
        """
        Collect information about files in the repository.
        
        Returns:
            Dictionary mapping file paths to file information
        """
        files_info = {}
        
        # Common code file extensions
        code_extensions = ['.py', '.js', '.jsx', '.ts', '.tsx', '.java', '.c', '.cpp', '.h', '.rb', '.go', '.rs', '.php', '.cs']
        
        # Walk through the repository
        for root, _, files in os.walk(self.repo_path):
            for file in files:
                # Skip non-code files and hidden files
                if not any(file.endswith(ext) for ext in code_extensions) or file.startswith('.'):
                    continue
                
                file_path = Path(root) / file
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    files_info[file_path] = {
                        "content": content,
                        "size": len(content),
                        "checksum": hashlib.md5(content.encode()).hexdigest()
                    }
                except (UnicodeDecodeError, PermissionError, IsADirectoryError) as e:
                    print(f"Error reading {file_path}: {e}")
        
        return files_info

    def run_experiment(self, query):
        """
        Run the semantic chunking analysis experiment.
        
        Args:
            query: The query to send to Claude CLI
            
        Returns:
            Dictionary with experiment results
        """
        # Step 1: Create a session
        if not self.create_session():
            return {"error": "Failed to create session"}
        
        # Step 2: Send the directory
        if not self.send_directory():
            return {"error": "Failed to send directory"}
        
        # Step 3: Collect file information
        files_info = self.collect_files_info()
        print(f"Collected information about {len(files_info)} files")
        
        # Step 4: Send the query
        response = self.query_claude(query)
        if not response:
            return {"error": "Failed to get response"}
        
        # Step 5: Analyze the response
        analysis = self.analyze_file_references(response, files_info)
        
        # Step 6: Save the results
        self.results = {
            "repo_path": str(self.repo_path),
            "query": query,
            "session_id": self.session_id,
            "timestamp": time.time(),
            "analysis": analysis,
            "response": response
        }
        
        return self.results

    def save_results(self, output_path=None):
        """
        Save the experiment results to a file.
        
        Args:
            output_path: Path to save the results to
            
        Returns:
            The path where the results were saved
        """
        if not self.results:
            print("No results to save")
            return None
        
        if not output_path:
            output_dir = Path("results")
            output_dir.mkdir(exist_ok=True)
            output_path = output_dir / f"chunking_analysis_{int(time.time())}.json"
        
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(self.results, f, indent=2)
        
        print(f"Results saved to {output_path}")
        return output_path


def main():
    """Main function to run the experiment."""
    parser = argparse.ArgumentParser(description="Analyze Claude CLI's semantic chunking behavior")
    parser.add_argument("--repo", required=True, help="Path to the repository to analyze")
    parser.add_argument("--query", required=True, help="Query to send to Claude CLI")
    parser.add_argument("--output", help="Path to save the results to")
    
    args = parser.parse_args()
    
    # Run the experiment
    analyzer = ChunkingAnalyzer(args.repo)
    results = analyzer.run_experiment(args.query)
    
    # Save the results
    analyzer.save_results(args.output)
    
    # Print summary
    if "error" not in results:
        analysis = results["analysis"]
        print("\nExperiment Summary:")
        print(f"- Repository: {results['repo_path']}")
        print(f"- Query: {results['query']}")
        print(f"- Total files analyzed: {analysis['total_files']}")
        print(f"- Files referenced in response: {analysis['referenced_files']} ({analysis['reference_rate']:.1%})")
        print(f"- Token usage: {analysis['token_usage']}")
    else:
        print(f"Experiment failed: {results['error']}")


if __name__ == "__main__":
    main()