# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

FoundationChat is a SwiftUI application demonstrating Apple's Foundation Models framework for on-device AI. The project targets iOS 26.0+ and showcases chat functionality using Apple Intelligence.

## Framework Overview

Apple's Foundation Models framework provides on-device large language models that power Apple Intelligence. It's available on iOS 26.0+, iPadOS 26.0+, macOS 26.0+, and visionOS 26.0+.

## Key Documentation Files

### 1. **EXAMPLES/FOUNDATION_MODELS_RULES.md**
**When to use:** Start here for understanding core framework principles
- Availability checking patterns
- Session management rules
- Performance optimization guidelines
- Safety implementation requirements
- Platform requirements and limitations

### 2. **EXAMPLES/QUICK_REFERENCE.md**
**When to use:** For quick code snippets and common patterns
- Import statements
- Basic usage patterns
- Error handling snippets
- Common configurations

### 3. **EXAMPLES/01_Basic_Usage.md**
**When to use:** For simple text generation tasks
- Creating sessions
- Basic prompting
- Handling availability states
- Error handling basics
- Multi-turn conversations

### 4. **EXAMPLES/02_Structured_Output.md**
**When to use:** When you need structured data from the model
- @Generable macro usage
- @Guide annotations
- Complex nested structures
- Optional properties
- Performance considerations

### 5. **EXAMPLES/03_Streaming_Responses.md**
**When to use:** For real-time UI updates during generation
- Basic streaming implementation
- Streaming with structured output
- Progress tracking
- Error handling in streams
- SwiftUI integration

### 6. **EXAMPLES/04_Tool_Calling.md**
**When to use:** When the model needs external data/actions
- Tool protocol implementation
- Integration with system frameworks (Contacts, Calendar, etc.)
- Stateful tools
- Multiple tool usage

### 7. **EXAMPLES/05_Performance_and_Safety.md**
**When to use:** For optimization and safety implementation
- Prewarming strategies
- Schema optimization
- Safety boundaries
- Context management
- Performance monitoring

### 8. **EXAMPLES/06_Complete_Chat_App.md**
**When to use:** For understanding the full application structure
- Complete chat implementation
- SwiftUI best practices
- State management
- UI/UX considerations

## Development Workflow

### Starting a New Feature

1. **Check FOUNDATION_MODELS_RULES.md** for constraints
2. **Reference QUICK_REFERENCE.md** for syntax
3. **Find similar examples** in the numbered example files
4. **Always check availability first**
5. **Implement with proper error handling**

### Common Tasks Reference

| Task | Primary Reference | Secondary Reference |
|------|------------------|-------------------|
| Basic text generation | 01_Basic_Usage.md | QUICK_REFERENCE.md |
| Structured data extraction | 02_Structured_Output.md | 04_Tool_Calling.md |
| Chat interface | 06_Complete_Chat_App.md | 03_Streaming_Responses.md |
| Adding tools/functions | 04_Tool_Calling.md | FOUNDATION_MODELS_RULES.md |
| Performance optimization | 05_Performance_and_Safety.md | FOUNDATION_MODELS_RULES.md |
| Safety implementation | 05_Performance_and_Safety.md | FOUNDATION_MODELS_RULES.md |

## Critical Rules (Always Remember)

1. **ALWAYS check `SystemLanguageModel.default.isAvailable`** before using
2. **NEVER assume the model is available** - provide fallback UI
3. **Handle all error cases**, especially:
   - `GenerationError.guardrailViolation`
   - `GenerationError.exceededContextWindowSize`
   - `GenerationError.unsupportedLanguageOrLocale`
4. **Use streaming for responses > 1 sentence** for better UX
5. **Prewarm sessions** when users show intent to interact
6. **Keep instructions in sessions**, not user input (security)
7. **Display errors in UI** - pass error messages to the user interface

## Code Patterns

### Standard Session Creation
```swift
@available(iOS 26.0, *)
guard SystemLanguageModel.default.isAvailable else { 
    // Show fallback UI
    return 
}

let session = LanguageModelSession(instructions: """
    You are a helpful assistant.
    Be concise and accurate.
    """)
```

### Structured Output Pattern
```swift
@Generable
struct Output {
    @Guide(description: "Clear description")
    let field: String
}

let response = try await session.respond(
    to: prompt,
    generating: Output.self
)
```

### Tool Implementation Pattern
```swift
struct MyTool: Tool {
    let name = "toolName"
    let description = "What it does"
    
    @Generable
    struct Arguments {
        let param: String
    }
    
    func call(arguments: Arguments) async throws -> ToolOutput {
        // Implementation
        return ToolOutput("result")
    }
}
```

## Debugging Tips

1. Use **Foundation Models Instrument** in Xcode
2. Monitor token counts and response times
3. Check `session.transcript` for conversation history
4. Log availability state changes
5. Test all error scenarios

## When Things Go Wrong

- **Model not available**: Check Settings > Apple Intelligence
- **Guardrail violations**: Rephrase prompts, add safety instructions
- **Context overflow**: Create new session or condense history
- **Poor performance**: Check prewarming, schema inclusion settings

## Recent Updates and Features

### Tool Integration
The project now includes the `WebAnalyserTool` that demonstrates Foundation Models tool calling:
- Extracts structured metadata from web pages (title, thumbnail, description)
- Uses SwiftSoup for HTML parsing
- Returns structured data via `@Generable` types

### Message Attachments
Messages now support rich attachments:
- `attachementTitle`: Display title for web content
- `attachementThumbnail`: Preview image URL
- `attachementDescription`: Content description

### UI Improvements
- Enhanced scrolling behavior with `.scrollPosition`
- Automatic keyboard focus on conversation load
- Error messages displayed directly in the chat UI
- Preview support for SwiftUI views

## Development Best Practices

- When editing code, always build the project to check for errors and fix them, then rebuild.
- Always build the project with XcodeBuildMCP to check for errors
- Use previews to test UI components without running the full app
- Handle all async operations with proper error catching and UI feedback

## Testing with Tools

When implementing tools:
1. Define the tool conforming to the `Tool` protocol
2. Create `@Generable` structs for both Arguments and return types
3. Add the tool to the session configuration
4. Test with real URLs to verify extraction logic
5. Ensure proper error handling for network failures

Remember: This framework prioritizes privacy and runs entirely on-device. No internet connection is required for the model, but tools may access network resources when explicitly requested.