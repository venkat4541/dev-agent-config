---
name: typescript
description: Apply TypeScript safety and repository-native type patterns when implementing or reviewing TypeScript changes.
---

Read the local tsconfig, lint rules, and nearby code before changing types. Prefer precise domain types, narrow unknown input, preserve public contracts, avoid unsafe casts and implicit any, and use the existing validation and error conventions. Run the repository's typecheck after relevant changes.

