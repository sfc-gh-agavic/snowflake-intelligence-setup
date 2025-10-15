# Snowflake Intelligence Setup

A complete role-based access control (RBAC) setup for Snowflake Cortex AI services including Agents, Semantic Views (Cortex Analyst), and Cortex Search.

## Quick Start

Run `1. snowflake intelligence setup.sql` to create the foundational infrastructure for governed AI services in Snowflake.

## What Gets Created

### Database & Schemas
- **`SNOWFLAKE_INTELLIGENCE`** - Top-level database for all AI services
- **`PUBLIC`** - Public agents and services (accessible to all users)
- **`AGENTS`** - Agent storage schema
- **`SALES_INSIGHTS`** - Example domain-specific schema (template for other domains)

### Role Hierarchy

```
SNOWFLAKE_INTELLIGENCE_ADMIN (Top-level admin)
├── SNOWFLAKE_INTELLIGENCE_USER (Public read access to agents)
├── SALES_INSIGHTS_DEV_GROUP (Domain developers)
│   └── SALES_INSIGHTS_USER_GROUP (Domain users)
```

### Permissions by Role

| Role | Can Create | Can Use |
|------|-----------|---------|
| **SNOWFLAKE_INTELLIGENCE_ADMIN** | Public agents, search services, semantic views | Everything |
| **SALES_INSIGHTS_DEV_GROUP** | Domain-specific agents, search services, semantic views | Domain resources |
| **SALES_INSIGHTS_USER_GROUP** | Nothing | Domain resources (granted explicitly) |
| **SNOWFLAKE_INTELLIGENCE_USER** | Nothing | Public agents and services only |

## Architecture Pattern

1. **Admins** create public/cross-functional AI services in `SNOWFLAKE_INTELLIGENCE.PUBLIC`
2. **Domain developers** create specialized services in domain schemas (e.g., `SALES_INSIGHTS`)
3. **Domain users** consume services via natural language queries
4. **Public users** access general-purpose agents for self-service analytics

## Extending to Other Domains

To add another domain (e.g., Marketing, Finance, HR):

```sql
-- 1. Create schema
CREATE SCHEMA SNOWFLAKE_INTELLIGENCE.MARKETING_INSIGHTS;

-- 2. Create developer role
CREATE ROLE MARKETING_INSIGHTS_DEV_GROUP;
GRANT CREATE AGENT ON SCHEMA SNOWFLAKE_INTELLIGENCE.MARKETING_INSIGHTS TO ROLE MARKETING_INSIGHTS_DEV_GROUP;
GRANT CREATE SEMANTIC VIEW ON SCHEMA SNOWFLAKE_INTELLIGENCE.MARKETING_INSIGHTS TO ROLE MARKETING_INSIGHTS_DEV_GROUP;
GRANT CREATE CORTEX SEARCH SERVICE ON SCHEMA SNOWFLAKE_INTELLIGENCE.MARKETING_INSIGHTS TO ROLE MARKETING_INSIGHTS_DEV_GROUP;

-- 3. Create user role
CREATE ROLE MARKETING_INSIGHTS_USER_GROUP;
GRANT USAGE ON SCHEMA SNOWFLAKE_INTELLIGENCE.MARKETING_INSIGHTS TO ROLE MARKETING_INSIGHTS_USER_GROUP;

-- 4. Grant to admin
GRANT ROLE MARKETING_INSIGHTS_DEV_GROUP TO ROLE SNOWFLAKE_INTELLIGENCE_ADMIN;

-- 5. Add users to roles
 GRANT ROLE MARKETING_INSIGHTS_DEV_GROUP TO user <insights_developer>;
 GRANT ROLE MARKETING_INSIGHTS_USER_GROUP TO user <insights_user>;
```
