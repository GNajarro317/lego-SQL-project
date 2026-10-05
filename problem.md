### LEGO SQL Analysis: Problem
 
### Scenario
LEGO production involves creating many different parts. Making new, unique parts costs more than reusing existing ones. The goal is to find which LEGO sets include the most unique parts.
 
### Tags
`Snowflake` `Schema Design` `Views` `Aggregation` `Tableau`
 
### Skills
- Creating schemas and tables with fitting data types
- Loading data with `insert into ... select`
- Adding primary and foreign keys
- CTEs and multi-table joins
- Conditional counting with `case when`
- Left joins to keep all rows
- Creating views
- Building a Tableau dashboard
### Task
**Part 1: Schema setup**
- Create a new schema and build the eight LEGO tables in it
- Populate them from the staging schema
- Add primary and foreign keys

**Part 2: Unique parts analysis**
- Find parts that appear in only one set (quantity does not matter)
- For each set, report how many of its parts are unique and how many parts it has in total (a count of parts, not quantity)
- Add a "uniqueness" field that shows how unique each set is
- Include the set name, release year, and theme name
- Save the result as a view

**Part 3: Dashboard**
- Build a Tableau dashboard with three charts on unique parts: change over time, compared to total parts in a set, and by theme
- Add titles and interactions

**Extra**
- Build a second view that lists every part in every set and tags it as unique or not, for dashboard use