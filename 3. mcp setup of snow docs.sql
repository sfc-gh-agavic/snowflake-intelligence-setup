-- ========================================================
-- CREATE AUTHENTICATION POLICY FOR PATs
-- ========================================================

USE ROLE ACCOUNTADMIN;

-- Note: It is recommened to have a strict PAT policy in place for MCP usage, but not required.
-- This policy is not required for Snowflake Intelligence usage.

-- If this strict policy is used, users can only generate/use PATs for MCP usage, if they have:
-- Be assigned to a network policy that defines allowed IP ranges or network identifiers
-- Have the network policy activated for their user account

CREATE AUTHENTICATION POLICY strict_pat_policy
  PAT_POLICY=(
    NETWORK_POLICY_EVALUATION = ENFORCED_REQUIRED,
    DEFAULT_EXPIRY_IN_DAYS = 7,
    MAX_EXPIRY_IN_DAYS = 30
  );

ALTER ACCOUNT SET AUTHENTICATION POLICY strict_pat_policy;


-- ========================================================
-- MCP DATABASE - MCP SERVERS AND ROLES FOR SNOWFLAKE DOCS
-- ========================================================

USE ROLE SYSADMIN;

CREATE DATABASE IF NOT EXISTS MCP;

USE DATABASE MCP;

-- create a schema for our MCP servers
CREATE SCHEMA IF NOT EXISTS MCP_SERVERS;

-- create mcp server for snowflake docs
CREATE OR REPLACE MCP SERVER MCP.MCP_SERVERS.SNOWFLAKE_DOCS FROM SPECIFICATION 
$$
  tools:
    - name: "snowflake-docs"
      type: "CORTEX_SEARCH_SERVICE_QUERY"
      identifier: "snowflake_docs.shared.cke_snowflake_docs_service"
      description: "cortex search service for snowflake documentation"
      title: "Snowflake Docs"
$$;
DESCRIBE MCP SERVER SNOWFLAKE_DOCS;

-- create restrictive role to just access docs search service
USE ROLE SECURITYADMIN ;
GRANT USAGE ON DATABASE MCP TO ROLE SNOWFLAKE_INTELLIGENCE_USER;
GRANT USAGE ON SCHEMA MCP_SERVERS TO ROLE SNOWFLAKE_INTELLIGENCE_USER;
GRANT USAGE ON MCP SERVER MCP.MCP_SERVERS.SNOWFLAKE_DOCS TO ROLE SNOWFLAKE_INTELLIGENCE_USER;

-- create PAT for Snowflake Intelligence user
ALTER USER <username> ADD PROGRAMMATIC ACCESS TOKEN SNOWFLAKE_DOCS
ROLE_RESTRICTION = 'SNOWFLAKE_INTELLIGENCE_USER'
DAYS_TO_EXPIRY = 10;

-- ========================================================
-- MCP SETUP OF SNOWFLAKE DOCS IN CURSOR
-- ========================================================

-- Let's install the mcp server into Cursor
-- In Cursor, open or create ~/.cursor/mcp.json and add the following. 
-- NOTE: Replace the ORG and PAT placeholders with your values.
/*
{
    "mcpServers": {
      "snowflake-docs": {
        "url": "https://<YOUR-ORG-YOUR-ACCOUNT>.snowflakecomputing.com/api/v2/databases/MCP/schemas/MCP_SERVERS/mcp-servers/SNOWFLAKE_DOCS",
            "headers": {
              "Authorization": "Bearer <YOUR-PAT-TOKEN>"
            }
      }
    }
}

 */


-- Once saved, you should see snowflake-docs MCP server enabled. (Can be verifed in Cursor Settings > Tools & MCP)

-- Start a new chat in Cursor and set your @mcp.json as context to ask a question!
-- "What is a MCP server?""

-- Note: You may get a prompt asking you to allow Cursor to use the snowflake-docs MCP server tool.

-- That's it! You can now use the snowflake-docs MCP server in Cursor to ask questions about Snowflake Documentation.