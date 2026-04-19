# Template — tech-stack.md

Output schema for **Axis 1: Tech Stack**. Fill with evidence from the project
you analyzed. Every value must cite the config file + line.

## What to detect vs. where to look

| What to detect | Where to look |
|----------------|---------------|
| Language + version | package.json engines, .python-version, go.mod, Cargo.toml |
| Framework + version | package.json dependencies, requirements.txt, go.mod |
| Database | docker-compose.yml, .env, ORM config, connection strings |
| ORM/ODM | prisma/schema.prisma, typeorm config, sequelize config |
| CSS framework | tailwind.config, package.json, imported stylesheets |
| Test framework | jest.config, vitest.config, pytest.ini, test files |
| Build tools | webpack.config, vite.config, tsconfig.json, Makefile |
| CI/CD | .github/workflows/, .gitlab-ci.yml, Jenkinsfile |
| Container | Dockerfile, docker-compose.yml, k8s manifests |
| Linting | .eslintrc, .prettierrc, ruff.toml, .golangci.yml |

## Output template

```markdown
# Tech Stack — [Project Name]

> Analyzed on YYYY-MM-DD
> Source: [project path]

## Core
| Category | Technology | Version | Config File |
|----------|-----------|---------|-------------|
| Language | TypeScript | 5.3.3 | tsconfig.json:3 |
| Framework | Angular | 17.2.0 | package.json:15 |
| ...      | ...       | ...     | ...         |

## Infrastructure
| Category | Technology | Version | Config File |
|----------|-----------|---------|-------------|
| Database | PostgreSQL | 16 | docker-compose.yml:8 |
| ...      | ...       | ...     | ...         |

## Dev Tools
| Category | Technology | Version | Config File |
|----------|-----------|---------|-------------|
| Linter | ESLint | 8.56.0 | .eslintrc.json:1 |
| ...      | ...       | ...     | ...         |
```
