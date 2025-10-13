

-- ####################################################
-- NOTES ON THE USAGE OF SNOWFLAKE INTELLIGENCE
-- ####################################################

/*
PERSONA WORKFLOWS: Building Solutions in Snowflake Intelligence

====================================================================================
PERSONA 1: SNOWFLAKE_INTELLIGENCE_USER
The Everyday Explorer
====================================================================================

WHO THEY ARE:
  • Business analysts, data scientists, executives - anyone granted PUBLIC role
  • Read/query access to public agents and services
  • Cannot create new agents but can leverage existing AI infrastructure

TYPICAL JOURNEY:
  1. Log in, assume SNOWFLAKE_INTELLIGENCE_USER role
  2. Discover available public agents via: SHOW AGENTS IN SCHEMA SNOWFLAKE_INTELLIGENCE.AGENTS;
  3. Query a public agent for insights
  4. Access public Cortex Search services for document retrieval
  5. Query public semantic views via Cortex Analyst for natural language analytics

SCENARIO: "Quick Insights from Marketing Data"
  → Julia, Marketing Analyst, needs to understand Q4 campaign performance
  → She queries the PUBLIC_MARKETING_AGENT: "What were our top 3 campaigns by ROI?"
  → Agent uses PUBLIC_MARKETING_SEMANTIC_VIEW to access campaign tables
  → Agent returns: "Black Friday (185% ROI), Holiday Email (142% ROI), Cyber Monday (138% ROI)"
  → Julia exports results to stakeholders in <2 minutes - no SQL required
  → Key Limitation: Cannot customize agent behavior or access restricted datasets

SCENARIO: "Document Search Across Company Knowledge Base"
  → Marcus, Product Manager, needs to find engineering specs from 2024
  → Queries PUBLIC_DOCS_SEARCH_SERVICE with: "Battery specifications Model X 2024"
  → Cortex Search returns top 5 relevant docs from company wiki, Confluence, Jira
  → Marcus clicks through to exact doc location, finds answer in engineering memo
  → Key Win: Self-service discovery without bothering Data Engineering

====================================================================================
PERSONA 2: SNOWFLAKE_INTELLIGENCE_ADMIN
The Builder & Architect
====================================================================================

WHO THEY ARE:
  • AI Engineers, ML Engineers, Data Platform Architects
  • Member of AI_SERVICES_DEVELOPER_GROUP role
  • Full CREATE permissions on agents, search services, semantic views

TYPICAL JOURNEY:
  1. Identify business need: "Sales team needs an AI assistant for pipeline forecasting"
  2. Create semantic view to expose SALES_PIPELINE table structure
  3. Build Cortex Search service over sales docs (playbooks, win/loss reports)
  4. Orchestrate agent that combines LLM reasoning + semantic view + search
  5. Test agent with sample queries, iterate on tools and instructions
  6. Grant USAGE to SNOWFLAKE_INTELLIGENCE_SALES_INSIGHTS_USER role
  7. Monitor usage, logs, and agent performance over time

SCENARIO: "Building a Sales Forecasting Agent from Scratch"
  → Step 1: Create semantic view exposing SALES.PIPELINE, SALES.OPPORTUNITIES tables
      CREATE SEMANTIC VIEW SNOWFLAKE_INTELLIGENCE.SERVICES.SALES_SEMANTIC_VIEW AS ...
  
  → Step 2: Create Cortex Search service indexing sales methodology docs
      CREATE CORTEX SEARCH SERVICE SNOWFLAKE_INTELLIGENCE.SERVICES.SALES_DOCS_SEARCH
        ON document_text FROM sales_knowledge_base;
  
  → Step 3: Create the agent with tools (LLM: mixtral-8x7b)
      CREATE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.SALES_FORECAST_AGENT
        TOOLS = (
          CORTEX_ANALYST(SNOWFLAKE_INTELLIGENCE.SERVICES.SALES_SEMANTIC_VIEW),
          CORTEX_SEARCH(SNOWFLAKE_INTELLIGENCE.SERVICES.SALES_DOCS_SEARCH)
        )
        INSTRUCTIONS = 'You are a sales forecasting assistant. Use data to predict pipeline close rates.'
        AS 'Sales Forecast Agent';
  
  → Step 4: Grant access to sales team role
      GRANT USAGE ON AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.SALES_FORECAST_AGENT 
        TO ROLE SNOWFLAKE_INTELLIGENCE_SALES_INSIGHTS_USER;
  
  → Step 5: Sales team now queries: "What's our Q4 close rate trend for Enterprise deals?"
      Agent responds with: Data analysis (via Cortex Analyst) + Context (via Search)
  
  → Key Win: End-to-end AI solution deployed in hours, not weeks
  → Ongoing: Monitor with SHOW AGENTS, review execution logs, tune instructions

SCENARIO: "Iterating on Agent Performance"
  → Agent v1 is too verbose, users complain responses are too long
  → Admin updates INSTRUCTIONS: "Be concise. Limit responses to 3 bullet points."
  → ALTER AGENT SALES_FORECAST_AGENT SET INSTRUCTIONS = '...'
  → Users test, satisfaction improves
  → Admin tracks: query latency, token usage, user adoption metrics

====================================================================================
PERSONA 3: SNOWFLAKE_INTELLIGENCE_SALES_INSIGHTS_USER
The Specialist with Domain Access
====================================================================================

WHO THEY ARE:
  • Sales Ops, Sales Managers, Account Executives
  • Custom role with targeted access to sales-specific agents/services
  • More restrictive than SNOWFLAKE_INTELLIGENCE_USER (no public agents)
  • More permissive for sales domain (access to restricted sales data)

TYPICAL JOURNEY:
  1. Assume SNOWFLAKE_INTELLIGENCE_SALES_INSIGHTS_USER role
  2. Access only sales-specific agents (e.g., SALES_FORECAST_AGENT, SALES_CHAT_AGENT)
  3. Query agents for sales forecasts, deal insights, competitive analysis
  4. Cannot see marketing agents, finance agents, HR agents (role isolation)
  5. Query results draw from sensitive SALES.PIPELINE data (permissioned via semantic view)

SCENARIO: "Weekly Pipeline Review with AI Assistant"
  → Rashid, Regional Sales Manager, prepares for Monday pipeline call
  → Queries SALES_FORECAST_AGENT: "Show me deals >$100K at risk of slipping this week"
  → Agent analyzes:
      - Last activity date (stale deals = high risk)
      - Deal stage velocity (stuck in negotiation = red flag)
      - Historical close patterns (similar deals that slipped)
  → Agent returns: "5 deals at risk totaling $780K. Top risk: Acme Corp ($250K, no activity 12 days)"
  → Rashid proactively reaches out to Account Exec, unblocks procurement issue
  → Key Win: Predictive insights surface risks before they become misses

SCENARIO: "Competitive Intelligence During Active Deal"
  → Saniya, Account Executive, is in final negotiation with Enterprise prospect
  → Prospect mentions evaluating competitor "DataCo"
  → Queries SALES_CHAT_AGENT: "What's our win rate against DataCo in Enterprise deals?"
  → Agent searches SALES_DOCS_SEARCH for battlecards, win/loss reports
  → Agent responds: "72% win rate vs DataCo (last 12 months). Key differentiator: Data governance features."
  → Agent surfaces exact battlecard: "DataCo lacks row-level security and audit logs"
  → Saniya uses talking points in next call, wins deal
  → Key Win: Just-in-time competitive intel without leaving Snowflake chat interface

SCENARIO: "What They CANNOT Do (Role Boundaries)"
  → Saniya tries to query PUBLIC_MARKETING_AGENT: "What's our CAC by channel?"
  → Error: "Insufficient privileges to operate on AGENT PUBLIC_MARKETING_AGENT"
  → Security worked as designed: Sales role isolated from marketing data
  → Saniya escalates to manager if cross-functional insight genuinely needed
  → Manager with broader role runs query, shares sanitized results
  → Key Design: Principle of least privilege enforced by role-based access

====================================================================================
CROSS-PERSONA COLLABORATION PATTERN
====================================================================================

REALISTIC WORKFLOW: "Building a Sales+Marketing Attribution Agent"

  1. ADMIN creates SALES_MARKETING_AGENT with access to both domains
  2. ADMIN grants USAGE to both SALES_INSIGHTS_USER and MARKETING_USER roles
  3. SALES USER queries: "Which marketing campaigns drove my Q4 pipeline?"
  4. MARKETING USER queries: "What's the sales close rate from our webinar leads?"
  5. Both personas get answers from the SAME agent, unified view of attribution
  6. ADMIN monitors usage: 2,500 queries/month, 94% user satisfaction
  7. ADMIN iterates: adds Slack integration, agent now pushes weekly summaries

KEY INSIGHT: Roles compose and agents bridge silos.

====================================================================================
SUMMARY: The Snowflake Intelligence Hierarchy
====================================================================================

SNOWFLAKE_INTELLIGENCE_ADMIN
  ├─ Builds agents, semantic views, search services
  ├─ Grants access to roles
  └─ Monitors & iterates

SNOWFLAKE_INTELLIGENCE_USER (Public)
  ├─ Uses public agents for broad insights
  └─ Self-service analytics without barriers

SNOWFLAKE_INTELLIGENCE_<DOMAIN>_USER (e.g., SALES_INSIGHTS_USER)
  ├─ Uses domain-specific agents with restricted data access
  ├─ Higher trust, more sensitive data exposure
  └─ Role isolation prevents cross-contamination

RESULT: Democratized AI with governed access. Build once, serve many. 
        Snowflake Intelligence = Your org's AI copilot, custom-fitted to roles.

*/
