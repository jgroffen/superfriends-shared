# Skills

This folder contains **reusable skills** that can be leveraged across the MCP services included in this project.

Skills are self-contained, modular components designed to **Solve specific problems** without tight coupling to implementations.

Each skill is organized in its own directory with implementation code, documentation, and examples.

Only skills that are relevant to multiple MCP services should be included in the `./shared` folder. If a skill is relevant to one MCP only it should be included within that MCP.



## Integration

Choose the integration method based on your workflow:

### 1. Local Development (Direct Reference)

Use this when actively developing and testing skill changes alongside your project.

```bash
# Reference the skill from your project
const skill = require('./superfriends/skills/skill-name');
// or
import skill from './superfriends/skills/skill-name';
```

Changes are immediately reflected without reinstalling.

### 2. Module Installation (Recommended)

Use this for stable, production use with version control and dependency management.

```bash
# Install SuperFriends as a dependency
npm install @your-org/superfriends-mcp

# Import the skill
const skill = require('@your-org/superfriends-mcp/skills/skill-name');
// or
import skill from '@your-org/superfriends-mcp/skills/skill-name';
```

See individual skill READMEs for specific usage and configuration details.
