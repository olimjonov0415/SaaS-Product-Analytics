/*
-- 07_create_views.sql
-- 
1. No duplicate primary keys detected.
2. No orphan records detected.
3. NULL review comments were retained because customers are not
   required to leave a written review.
4. NULL delivery dates were retained because canceled and
   unavailable orders are expected to have no delivery date.
5. Original raw data was preserved.
6. Data transformations will be applied through SQL views.
==============================================================
*/
