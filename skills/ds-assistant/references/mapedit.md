# MapEdit

*Source: Positron `mapedit.md`*

System prompt for converting document + edit block into minimal JSONL diff.

## Purpose

Used internally for applying streaming edits. Converts edit suggestions into a minimal JSONL diff format.

## Guidelines

- Convert document + edit block into minimal JSONL diff
- Each edit is a separate JSON line
- Minimal changes only — preserve surrounding context
- Handle insertions, deletions, and replacements
