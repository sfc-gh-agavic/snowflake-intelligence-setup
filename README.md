# Snowflake Intelligence Setup

A complete role-based access control (RBAC) setup for Snowflake Cortex AI services including Agents, Semantic Views (Cortex Analyst), and Cortex Search.

## What's Included

`1. snowflake intelligence setup.sql` creates the foundational infrastructure for governed AI services in Snowflake.

`2. agent setup of snow docs.md` creates your first agent using the Snowflake Documentation Search Service from a Cortex Knowledge Extension (CKE).

`3. mcp setup of snow docs.sql` exposes the Snowflake Documentation Search Service to Cursor via a MCP server setup

## What Gets Created (In Script #1)

### Database & Schemas
- **`SNOWFLAKE_INTELLIGENCE.PUBLIC`** - Schema for all public AI services
- **`EDW.SALES_INSIGHTS`** - Example domain-specific schema (template for other domains)

### Permissions by Role

| Role | Can Create | Can Use |
|------|-----------|---------|
| **SNOWFLAKE_INTELLIGENCE_ADMIN** | Public agents, search services, semantic views, custom tools | Everything |
| **SNOWFLAKE_INTELLIGENCE_USER** | Nothing | Public agents only |
| **SALES_INSIGHTS_DEV_GROUP** | Domain-specific agents, search services, semantic views custom tools | Domain AI resources |
| **SALES_INSIGHTS_USER_GROUP** | Nothing | Domain agents |
