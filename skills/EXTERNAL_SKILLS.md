# External Skills Registry

This document tracks skills that are sourced from external packages and integrated into SuperFriends. External skills are referenced as dependencies, making them automatically available to any project that uses SuperFriends.

## Adding External Skills

### 1. Identify a Skill

Find a skill from:
- **npm packages** - Existing tools or libraries that provide reusable functionality
- **GitHub repositories** - Skills from your own projects or community sources
- **Other sources** - Any well-maintained, reusable skill

### 2. Add as a Dependency

Update the root-level `package.json` (or `requirements.txt` for Python):

```json
{
  "dependencies": {
    "@scope/skill-name": "^1.0.0"
  }
}
```

### 3. Document the Integration

Add an entry to this registry with:
- **Name** - Skill name
- **Source** - Link to npm or GitHub
- **Version** - Pinned version or range
- **Purpose** - What the skill does
- **Import path** - How to use it in code
- **Notes** - Any special setup or considerations

## Registry

> Currently empty. Skills will be added as they're integrated.

### Template Entry

```
### [Skill Name]
- **Source**: [npm package or GitHub URL]
- **Version**: [Version constraint]
- **Purpose**: [What it does]
- **Import**: 
  ```javascript
  const skill = require('@scope/skill-name');
  // or
  import skill from '@scope/skill-name';
  ```
- **Notes**: Any special setup or usage patterns
```

## Discovery

To see all available skills (native + external):
1. Check `skills/` folder for native skills
2. Check this registry for external skills
3. See `templates/using-external-skills.md` for integration examples
