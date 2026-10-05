### LEGO SQL Analysis
 
### Date created
10/02/2026 | last updated: 10/05/2026
 
### Description
A Snowflake SQL project that builds a LEGO database schema from staging tables, links it with primary and foreign keys, then finds which parts appear in only one set. Results are rolled up per set with release year and theme to show which sets rely most on unique parts, then visualized in a Tableau dashboard.
 
### Scenario
Producing new, unique LEGO parts costs more than reusing existing ones. This project looks at which sets include the most unique parts.
 
### Tables
Created in the `gerard_lego` schema from the `staging` tables:
 
- **colors:** `id`, `name`, `rgb`, `is_trans`
- **inventories:** `id`, `version`, `set_num`
- **inventory_parts:** `inventory_id`, `part_num`, `color_id`, `quantity`, `is_spare`
- **inventory_sets:** `inventory_id`, `set_num`, `quantity`
- **part_categories:** `id`, `name`
- **parts:** `part_num`, `name`, `part_cat_id`
- **sets:** `set_num`, `name`, `year`, `theme_id`, `num_parts`
- **themes:** `id`, `name`, `parent_id`
### The problems included are:
- **Part 1:** Build the schema, create and populate the tables, and set primary and foreign keys
- **Part 2:** Identify parts that appear in only one set, then measure how unique each set is
- **Part 3:** Build a Tableau dashboard with three charts on unique parts: change over time, compared to total parts in a set, and by theme
- **Extra:** A master view with one row per part per set, tagged Unique or Not Unique, for dashboard use
### Files
- `lego_sql_challenge.sql`: schema setup, both views, and the final select statements
- `problem.md`: scenario, skills, and task write-up
- Dashboard screenshot and Tableau Public link: *(add once finished)*
### Key Takeaways
- Counting distinct sets per part gives a true "one set only" check
- Staging data had parts missing from the parts table, so they were added with null names
- A second master view makes the results easy to connect to the Tableau dashboard
### Data Source
1. LEGO staging schema provided with the SQL Portfolio challenge