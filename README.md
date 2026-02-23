# LLM Skills

A collection of reusable skills for [Claude Code](https://docs.anthropic.com/en/docs/claude-code), Anthropic's official CLI agent.

Skills are custom slash-command prompts that extend Claude Code with domain-specific workflows, templates, and automation.

## Usage

1. Copy a skill directory into your project's `.claude/skills/` folder (or `~/.claude/skills/` for global access).
2. Invoke it in Claude Code with `/<skill-name>`.

## Available Skills

| Skill | Description |
|-------|-------------|
| `ansible-homelab` | Scaffolds Ansible playbook projects for homelab infrastructure |
| `komodo-deploy` | Deploy, restart, and manage Docker stacks via Komodo |

## License

[MIT](LICENSE.md)
