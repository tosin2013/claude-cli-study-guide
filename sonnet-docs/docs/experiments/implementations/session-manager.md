---
sidebar_position: 5
---

# Session Manager Implementation

Our Session Manager is an experimental implementation focused on studying and replicating how Claude CLI manages session state across multiple interactions. This component explores one of the key architectural features that enable Claude CLI to maintain context effectively.

## Overview

The Session Manager is designed to:

1. Maintain context across multiple interactions
2. Update context incrementally with new information
3. Optimize context within token limits
4. Synchronize state between local storage and model context

This implementation represents our understanding of how Claude CLI might handle persistent sessions and context management.

## Architecture

The Session Manager consists of several key components:

```
┌───────────────────────────┐
│     Session Storage       │
└───────────┬───────────────┘
            │
┌───────────▼───────────────┐
│     Context Window        │
└───────────┬───────────────┘
            │
┌───────────▼───────────────┐
│     Pruning Strategy      │
└───────────┬───────────────┘
            │
┌───────────▼───────────────┐
│     Importance Tracker    │
└───────────┬───────────────┘
            │
┌───────────▼───────────────┐
│     State Synchronizer    │
└───────────────────────────┘
```

### Key Components

#### 1. Session Storage

The Session Storage maintains session data:

```python
class SessionStorage:
    def __init__(self, storage_path):
        self.storage_path = storage_path
        self.current_session = None
        self.sessions = self._load_sessions()
        
    def _load_sessions(self):
        if os.path.exists(self.storage_path):
            with open(self.storage_path, 'r') as f:
                return json.load(f)
        return {}
        
    def _save_sessions(self):
        with open(self.storage_path, 'w') as f:
            json.dump(self.sessions, f)
            
    def create_session(self, session_id=None):
        if session_id is None:
            session_id = str(uuid.uuid4())
            
        self.current_session = session_id
        self.sessions[session_id] = {
            'created_at': datetime.now().isoformat(),
            'updated_at': datetime.now().isoformat(),
            'context': [],
            'files_accessed': [],
            'conversation': []
        }
        self._save_sessions()
        return session_id
        
    def get_session(self, session_id):
        if session_id in self.sessions:
            self.current_session = session_id
            return self.sessions[session_id]
        return None
        
    def update_session_context(self, context_items):
        if self.current_session:
            self.sessions[self.current_session]['context'] = context_items
            self.sessions[self.current_session]['updated_at'] = datetime.now().isoformat()
            self._save_sessions()
```

#### 2. Context Window

The Context Window manages context within token limits:

```python
class ContextWindow:
    def __init__(self, max_tokens=100000):
        self.max_tokens = max_tokens
        self.current_tokens = 0
        self.context_items = []
        
    def add_item(self, item):
        item_tokens = self._count_tokens(item['content'])
        
        # Check if item can fit
        if self.current_tokens + item_tokens <= self.max_tokens:
            self.context_items.append(item)
            self.current_tokens += item_tokens
            return True
        
        # Item doesn't fit, need to make room
        return self._make_room(item_tokens, item)
        
    def _make_room(self, required_tokens, new_item):
        # Try to prune items to make room
        candidates = sorted(self.context_items, key=lambda x: x.get('importance', 0))
        
        tokens_to_free = required_tokens - (self.max_tokens - self.current_tokens)
        tokens_freed = 0
        items_to_remove = []
        
        for item in candidates:
            if tokens_freed >= tokens_to_free:
                break
                
            item_tokens = self._count_tokens(item['content'])
            tokens_freed += item_tokens
            items_to_remove.append(item)
            
        # Remove selected items
        for item in items_to_remove:
            self.context_items.remove(item)
            self.current_tokens -= self._count_tokens(item['content'])
            
        # Add new item
        self.context_items.append(new_item)
        self.current_tokens += required_tokens
        return True
        
    def _count_tokens(self, text):
        # Simple estimation: 1 token ≈ 4 characters
        return len(text) // 4
```

#### 3. Pruning Strategy

The Pruning Strategy determines how to reduce context:

```python
class PruningStrategy:
    def __init__(self):
        pass
        
    def prune_context(self, context_items, target_tokens):
        # Start with simple strategies
        strategies = [
            self._prune_by_age,
            self._prune_by_importance,
            self._prune_by_similarity
        ]
        
        # Try each strategy until we reach target tokens
        for strategy in strategies:
            context_items = strategy(context_items, target_tokens)
            current_tokens = sum(self._count_tokens(item['content']) for item in context_items)
            
            if current_tokens <= target_tokens:
                return context_items
        
        # If all strategies fail, use aggressive pruning
        return self._aggressive_prune(context_items, target_tokens)
        
    def _prune_by_age(self, context_items, target_tokens):
        # Remove oldest items first
        sorted_items = sorted(context_items, key=lambda x: x.get('timestamp', 0))
        return self._prune_sorted_items(sorted_items, target_tokens)
        
    def _prune_by_importance(self, context_items, target_tokens):
        # Remove least important items first
        sorted_items = sorted(context_items, key=lambda x: x.get('importance', 0))
        return self._prune_sorted_items(sorted_items, target_tokens)
        
    def _prune_by_similarity(self, context_items, target_tokens):
        # Remove redundant items first
        # This is a simplified implementation
        # A real implementation would use embeddings to calculate similarity
        return context_items
```

#### 4. Importance Tracker

The Importance Tracker evaluates the importance of context items:

```python
class ImportanceTracker:
    def __init__(self):
        self.item_access_count = {}
        self.item_recency = {}
        self.item_query_relevance = {}
        
    def track_access(self, item_id):
        if item_id in self.item_access_count:
            self.item_access_count[item_id] += 1
        else:
            self.item_access_count[item_id] = 1
            
        self.item_recency[item_id] = time.time()
        
    def track_query_relevance(self, item_id, query, relevance_score):
        if item_id not in self.item_query_relevance:
            self.item_query_relevance[item_id] = {}
            
        self.item_query_relevance[item_id][query] = relevance_score
        
    def calculate_importance(self, item_id, current_query=None):
        # Base importance is access count
        importance = self.item_access_count.get(item_id, 0)
        
        # Recency factor (higher for more recent items)
        recency = time.time() - self.item_recency.get(item_id, 0)
        recency_factor = 1.0 / (1.0 + math.log(1 + recency / 3600))  # Normalize to hours
        
        # Query relevance (if current query is provided)
        query_relevance = 0
        if current_query and item_id in self.item_query_relevance:
            # Simple relevance calculation based on previous queries
            for query, score in self.item_query_relevance[item_id].items():
                similarity = self._calculate_similarity(current_query, query)
                query_relevance += score * similarity
                
        # Combined importance score
        return (importance * 0.3) + (recency_factor * 0.3) + (query_relevance * 0.4)
```

#### 5. State Synchronizer

The State Synchronizer keeps local state and model context in sync:

```python
class StateSynchronizer:
    def __init__(self, session_storage):
        self.session_storage = session_storage
        
    def sync_to_model(self, session_id, context_window):
        # Get the session
        session = self.session_storage.get_session(session_id)
        if not session:
            return None
            
        # Prepare context for the model
        model_context = self._prepare_model_context(session, context_window.context_items)
        
        # Return the formatted context
        return model_context
        
    def sync_from_model(self, session_id, model_response, user_query):
        # Get the session
        session = self.session_storage.get_session(session_id)
        if not session:
            return
            
        # Update conversation history
        session['conversation'].append({
            'user': user_query,
            'assistant': model_response,
            'timestamp': datetime.now().isoformat()
        })
        
        # Extract any new context from the response
        new_context = self._extract_context_from_response(model_response)
        if new_context:
            session['context'].extend(new_context)
            
        # Save the updated session
        self.session_storage.update_session(session_id, session)
```

## Implementation Details

### Session Persistence

Our session persistence implementation includes:

1. **File-Based Storage**: Sessions are stored in a JSON file for persistence
2. **Session Identification**: Sessions are identified by a UUID
3. **Metadata Tracking**: Creation time, update time, and other metadata are tracked
4. **Conversation History**: All interactions are recorded in the session

Example of session data structure:

```json
{
  "session_123": {
    "created_at": "2024-03-12T10:15:30.123456",
    "updated_at": "2024-03-12T10:30:45.654321",
    "context": [
      {
        "id": "ctx_1",
        "type": "file",
        "path": "/path/to/file.py",
        "content": "def example():\n    return 'Hello, world!'",
        "importance": 0.85,
        "timestamp": 1615554930.123456
      },
      {
        "id": "ctx_2",
        "type": "query_result",
        "query": "How does authentication work?",
        "content": "Authentication is handled in auth.py using JWT tokens...",
        "importance": 0.65,
        "timestamp": 1615555230.123456
      }
    ],
    "files_accessed": [
      "/path/to/file.py",
      "/path/to/auth.py"
    ],
    "conversation": [
      {
        "user": "How does this code work?",
        "assistant": "This code defines a simple function that returns 'Hello, world!'.",
        "timestamp": "2024-03-12T10:15:30.123456"
      }
    ]
  }
}
```

### Context Management

Our context management implementation includes:

1. **Token Accounting**: Tracking token usage to stay within limits
2. **Intelligent Pruning**: Multiple strategies for pruning context when needed
3. **Importance Scoring**: Evaluating which context is most important to keep
4. **Content Optimization**: Optimizing content to use fewer tokens

Example of context item structure:

```python
context_item = {
    "id": "item_123",
    "type": "file",  # file, query_result, conversation, etc.
    "path": "/path/to/file.py",  # for file type
    "query": "How does auth work?",  # for query_result type
    "content": "def authenticate(user, password):\n    ...",
    "importance": 0.75,  # importance score
    "timestamp": 1615554930.123456,  # when the item was added
    "access_count": 3,  # how many times the item has been accessed
    "last_accessed": 1615555230.123456  # when the item was last accessed
}
```

### Importance Calculation

Our importance calculation includes these factors:

1. **Access Frequency**: How often an item is used
2. **Recency**: How recently an item was accessed
3. **Query Relevance**: How relevant an item is to current queries
4. **Semantic Significance**: The semantic importance of the content
5. **User Interactions**: Direct user interactions with the content

Example importance calculation:

```python
def calculate_importance(self, item, current_query):
    # Base score
    importance = 0.0
    
    # Access frequency component (0-25%)
    access_frequency = min(1.0, item['access_count'] / 10)  # Normalize to 0-1
    importance += access_frequency * 0.25
    
    # Recency component (0-25%)
    time_since_access = time.time() - item['last_accessed']
    recency = 1.0 / (1.0 + math.log(1 + time_since_access / 3600))  # Normalize to 0-1
    importance += recency * 0.25
    
    # Query relevance component (0-30%)
    if current_query:
        relevance = self._calculate_query_relevance(item, current_query)
        importance += relevance * 0.30
    
    # Semantic significance (0-20%)
    if 'semantic_score' in item:
        importance += item['semantic_score'] * 0.20
    
    return importance
```

### Token Optimization

Our token optimization strategies include:

1. **Comment Removal**: Removing non-essential comments
2. **Whitespace Normalization**: Normalizing whitespace to save tokens
3. **Duplicate Elimination**: Removing redundant information
4. **Content Summarization**: Summarizing verbose content

Example token optimization:

```python
def optimize_content(self, content, content_type):
    if content_type == 'code':
        # For code content, preserve structure but remove comments
        return self._optimize_code(content)
    elif content_type == 'conversation':
        # For conversation content, retain only essential exchanges
        return self._optimize_conversation(content)
    elif content_type == 'documentation':
        # For documentation, summarize verbose sections
        return self._optimize_documentation(content)
    else:
        # Default optimization
        return self._default_optimize(content)
```

## Usage Example

Using the Session Manager in a project:

```python
# Initialize components
session_storage = SessionStorage("./sessions.json")
context_window = ContextWindow(max_tokens=100000)
pruning_strategy = PruningStrategy()
importance_tracker = ImportanceTracker()
state_synchronizer = StateSynchronizer(session_storage)

# Create a new session
session_id = session_storage.create_session()

# Add some context items
file_content = open("main.py").read()
context_window.add_item({
    "id": "file_1",
    "type": "file",
    "path": "main.py",
    "content": file_content,
    "importance": 0.5,
    "timestamp": time.time()
})

# Track usage
importance_tracker.track_access("file_1")

# Process a query
query = "How does the authentication system work?"
importance_tracker.track_query_relevance("file_1", query, 0.3)

# Sync context to model
model_context = state_synchronizer.sync_to_model(session_id, context_window)

# Send query to model with context
response = send_to_model(query, model_context)

# Sync response back to session
state_synchronizer.sync_from_model(session_id, response, query)
```

## Integration with Other Components

The Session Manager integrates with other components:

1. **Semantic Chunker**: Receives chunks to add to the context
2. **Tool Manager**: Receives tool outputs to add to the context
3. **CLI Interface**: Receives user queries and presents responses
4. **API Client**: Sends context to and receives responses from the API

Example of integration with other components:

```python
# Initialize components
session_manager = SessionManager()
semantic_chunker = SemanticChunker()
tool_manager = ToolManager()
api_client = ApiClient()

# Process a user query
def process_query(query, codebase_path):
    # Get or create session
    session_id = session_manager.get_current_session_id() or session_manager.create_session()
    
    # Find relevant files
    relevant_files = semantic_chunker.find_relevant_files(query, codebase_path)
    
    # Add relevant file chunks to session
    for file_path in relevant_files:
        chunks = semantic_chunker.chunk_file(file_path)
        for chunk in chunks:
            session_manager.add_context_item(session_id, {
                "id": f"chunk_{uuid.uuid4()}",
                "type": "file_chunk",
                "path": file_path,
                "content": chunk,
                "importance": 0.5,
                "timestamp": time.time()
            })
    
    # Prepare context for API
    context = session_manager.prepare_model_context(session_id)
    
    # Send to API
    response = api_client.send_query(query, context)
    
    # Process tool calls
    if "tool_calls" in response:
        tool_results = tool_manager.process_tool_calls(response["tool_calls"])
        
        # Add tool results to context
        for result in tool_results:
            session_manager.add_context_item(session_id, {
                "id": f"tool_{uuid.uuid4()}",
                "type": "tool_result",
                "tool": result["tool"],
                "content": result["content"],
                "importance": 0.7,  # Tool results are usually important
                "timestamp": time.time()
            })
            
        # Prepare updated context
        updated_context = session_manager.prepare_model_context(session_id)
        
        # Send follow-up to API
        final_response = api_client.send_follow_up(response["id"], updated_context)
        return final_response
    
    # No tool calls, return response directly
    return response
```

## Performance Considerations

The Session Manager has been optimized for performance:

1. **Efficient Storage**: Session data is efficiently stored and retrieved
2. **Incremental Updates**: Only changed data is persisted
3. **Lazy Loading**: Session data is loaded only when needed
4. **Caching**: Frequently accessed data is cached for quick access

For large sessions, we recommend:

```python
# For large sessions, use a database backend
class DatabaseSessionStorage(SessionStorage):
    def __init__(self, connection_string):
        self.db = Database(connection_string)
        self.current_session = None
        
    def _load_session(self, session_id):
        # Only load the specific session, not all sessions
        return self.db.query(
            "SELECT * FROM sessions WHERE id = ?", 
            (session_id,)
        ).fetchone()
```

## Limitations and Future Work

Current limitations include:

1. **Simple Token Counting**: Currently uses a simplified token counting method
2. **Limited Similarity Detection**: Basic similarity detection for content
3. **Simple Importance Heuristics**: Relatively simple importance calculation
4. **Local Storage Only**: No distributed storage support

Future work includes:

1. **Advanced Token Counting**: More accurate token counting for different models
2. **Embedding-Based Similarity**: Using embeddings for better similarity detection
3. **Machine Learning for Importance**: Using ML to predict content importance
4. **Distributed Session Storage**: Support for distributed session storage
5. **Cross-Session Learning**: Learning patterns across multiple sessions

## Conclusion

Our Session Manager provides a practical implementation of the session management patterns we've observed in Claude CLI. While not as sophisticated as Claude CLI's implementation, it demonstrates the core principles of effective session management for AI-assisted programming tools.