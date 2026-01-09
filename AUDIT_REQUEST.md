# CodeRabbit Audit Request

## Audit Scope
Please perform a comprehensive audit of the entire codebase.

## Review Areas

### 1. Dead Code
- Identify unused functions, variables, and imports
- Flag orphaned files not referenced anywhere

### 2. Architecture
- Review MVVM compliance and separation of concerns
- Check for proper layering between Views, ViewModels, and Models
- Validate SwiftData model relationships

### 3. Code Quality
- Flag spaghetti code and complexity issues
- Identify code smells and anti-patterns
- Check for code duplication

### 4. Performance
- Identify potential performance bottlenecks
- Review animation efficiency
- Check for unnecessary view re-renders

### 5. Memory Management
- Check for retain cycles (especially in closures)
- Review @State, @Binding, @Environment usage
- Validate proper cleanup in onDisappear

### 6. SwiftUI Best Practices
- Review view composition and extraction
- Check state management patterns
- Validate proper use of view modifiers

### 7. SwiftData Usage
- Validate model relationships and queries
- Check for proper @Model annotations
- Review persistence patterns

### 8. Error Handling
- Check for proper error handling throughout
- Validate optional unwrapping safety
- Review edge case handling

### 9. Security
- Flag any hardcoded sensitive data
- Check UserDefaults usage for sensitive info
- Review data validation

### 10. Naming Conventions
- Review consistency in naming
- Check for Swift naming convention compliance
- Validate file organization

## Expected Output
Please provide specific line references for all findings.
