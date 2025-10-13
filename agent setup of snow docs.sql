use role accountadmin;

ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION = 'AWS_US';

create or replace role snowflake_intelligence_admin;
grant create database on account to role snowflake_intelligence_admin;
grant create integration on account to role snowflake_intelligence_admin;
grant usage on warehouse compute_wh to role snowflake_intelligence_admin;

set current_user = (select current_user());   
grant role snowflake_intelligence_admin to user identifier($current_user);
alter user set default_role = snowflake_intelligence_admin;
alter user set default_warehouse = compute_wh;

use role snowflake_intelligence_admin;
create database if not exists snowflake_intelligence;
create schema if not exists snowflake_intelligence.agents;
grant create agent on schema snowflake_intelligence.agents to role snowflake_intelligence_admin;




/*
Sign in to Snowsight.
In the navigation menu, select AI & ML » Agents.
Select Create agent.
For Agent object name, specify a name for the agent that is displayed to users in the UI. EG. SNOW_DOCS
For Display name, specify a name for the agent that is displayed to admins in the agent list. EG. Snowflake Documentation
Select Create agent.
Open the Agent.Click Edit button
Under tools, add the Cortex Search service: SNOWFLAKE_DOCS.SHARED.CKE_SNOWFLAKE_DOCS_SERVICE
Save it!
*/