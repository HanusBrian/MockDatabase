/*
 * Brian Hanus  
 * Modern Database Mgmt, Section 1, Spring 2015
 * hanusbSQL.sql
 * 
 * This file queries the database.
 *
 */
 
/* Query #1
 * This query displays all of the lessons with 2 or less people enrolled
 * it also displays the level of the lesson, this would be helpful if someone
 * was looking for a lesson to join and you want to see the options available
 * while trying not to over crowd any of the lessons.
 */
SELECT l.lesson_id, 
        l.lesson_level,   
        COUNT(e.client_id) AS number_enrolled
FROM enrollment e 
  JOIN lesson l
    ON l.lesson_id = e.lesson_id
WHERE l.lesson_id = e.lesson_id
GROUP BY l.lesson_id, l.lesson_level
HAVING COUNT(e.client_id) <= 2
ORDER BY lesson_id;
 
/* Query #2
 * This query displays the totals of court slots that are being used by  
 * reservations, lessons or are open for May 20, 2015.
 */
  SELECT 'Total Number of Empty Slots' AS Description,
          COUNT(court_aval) AS slot_total
  FROM court
  WHERE court_aval = 0 AND court_date = '20-MAY-2015'
UNION
  SELECT 'Total Number of Client Reserved Slots', COUNT(court_aval)
  FROM court
  WHERE court_aval = 1 AND court_date = '20-MAY-2015'
UNION
  SELECT 'Total Number of Lesson Slots', COUNT(court_aval)
  FROM court
  WHERE court_aval = 2 AND court_date = '20-MAY-2015';

/* Query #3
 * This query displays the workload of each instructor in hours.
 */
SELECT i.instructor_last_name || ', ' || i.instructor_first_name AS instructor_name, 
        COUNT(c.court_slot)/2 AS lesson_hours
FROM instructor i
  JOIN lesson l
    ON i.instructor_id = l.instructor_id
  JOIN court_group cg
    USING (lesson_id)
  JOIN court c
    ON c.court_cluster = cg.court_cluster
GROUP BY  i.instructor_last_name,
          i.instructor_first_name;
          
/* Query #4
 * This query shows all invoices for a client. This could act as 
 * a mailed bill to a client.
 */
SELECT invoice_id, 
      client_last_name || ', ' || client_first_name AS client_name,
      '$' || invoice_amt AS invoice_amount,
      '$' || payment_total AS payment_total
FROM invoice
  JOIN client
    USING (client_id)
WHERE client_id = 'cl-00003';
 
/* Query #5
 * A query to see a list of clients that are taught by a  
 * specific instructor.  If an instructor needs to cancel their 
 * lessons for the day this is a quick way to get their client contact info.
 */
SELECT UNIQUE c.client_id, 
      c.client_last_name || ', ' || c.client_first_name AS client_name,
      c.client_phone
FROM client c
  JOIN enrollment e
    ON c.client_id = e.client_id
  JOIN lesson l
    ON l.lesson_id = e.lesson_id
WHERE l.instructor_id = 'I-00004';

/* Query #6
 * Get an instructor's schedule by querying their lesson times.
 */
SELECT i.instructor_last_name || ', ' || i.instructor_first_name AS instructor_name,
      c.court_date,
      c.court_slot,
      c.court_number
FROM instructor i
  JOIN lesson l
    ON i.instructor_id = l.instructor_id
  JOIN court_group cg
    ON l.lesson_id = cg.lesson_id
  JOIN court c
    ON cg.court_cluster = c.court_cluster
WHERE i.instructor_id = 'I-00004'
ORDER BY court_slot;

/* Query #7
 * A query to see on which day and time slots where all of the courts are empty.  
 * If there is a time period where courts aren't selling the club could 
 * possibly offer discounted rates at those times.
 */
  SELECT court_date,
        court_slot
  FROM court 
  WHERE court_aval = 0 AND court_number = 1  
INTERSECT
  SELECT court_date,
        court_slot
  FROM court 
  WHERE court_aval = 0 AND court_number = 2
INTERSECT
  SELECT court_date,
        court_slot
  FROM court 
  WHERE court_aval = 0 AND court_number = 3
INTERSECT
  SELECT court_date,
        court_slot
  FROM court 
  WHERE court_aval = 0 AND court_number = 4
INTERSECT
  SELECT court_date,
        court_slot
  FROM court 
  WHERE court_aval = 0 AND court_number = 5
INTERSECT
  SELECT court_date,
        court_slot
  FROM court 
  WHERE court_aval = 0 AND court_number = 6
INTERSECT
  SELECT court_date,
        court_slot
  FROM court 
  WHERE court_aval = 0 AND court_number = 7
INTERSECT
  SELECT court_date,
        court_slot
  FROM court 
  WHERE court_aval = 0 AND court_number = 8
ORDER BY court_slot;
      