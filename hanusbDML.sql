/*
 * Brian Hanus  
 * Modern Database Mgmt, Section 1, Spring 2015
 * hanusbDML.sql
 * 
 * This file fills the database tables.
 *
 */
 
 --fill client
 
 INSERT INTO client 
 (  client_id,
    client_member,
    client_first_name,
    client_last_name,
    client_phone,
    client_address,
    client_city,
    client_state)
 VALUES
    ( 'cl-00001',
      'Y',
      'Grace',
      'Compton',
      '(123)345-5555',
      '349 N Road St.',
      'Chicago',
      'IL'
    );
    
INSERT INTO client 
 (  client_id,
    client_member,
    client_first_name,
    client_last_name,
    client_phone,
    client_address,
    client_city,
    client_state)
VALUES
    ( 'cl-00002',
      'N',
      'Frank',
      'Zappa',
      '(432)957-5555',
      '6758 S Smith St.',
      'Northbrook',
      'IL'
    );
    
INSERT INTO client 
 (  client_id,
    client_member,
    client_first_name,
    client_last_name,
    client_phone,
    client_address,
    client_city,
    client_state)
 VALUES
    ( 'cl-00003',
      'Y',
      'Jack',
      'Kerouac',
      '(853)495-5555',
      '349 N Vegabond Ct.',
      'Wheaton',
      'IL'
    );
    
INSERT INTO client 
 (  client_id,
    client_member,
    client_first_name,
    client_last_name,
    client_phone,
    client_address,
    client_city,
    client_state)
 VALUES
    ( 'cl-00004',
      'N',
      'Jesse',
      'Livermore',
      '(483)872-5555',
      '349 S Wall St.',
      'Chicago',
      'IL'
    );
    
INSERT INTO client 
 (  client_id,
    client_member,
    client_first_name,
    client_last_name,
    client_phone,
    client_address,
    client_city,
    client_state)
VALUES
  ( 'cl-00005',
    'Y',
    'Helen',
    'Keller',
    '(384)238-5555',
    '2492 N Blind St.',
    'Palatine',
    'IL'
  );

--fill instructor table

INSERT INTO instructor
  ( instructor_id,
    instructor_first_name,
    instructor_last_name,
    instructor_phone,
    instructor_address,
    instructor_city,
    instructor_state
  )
VALUES
  ( 'I-00001',
    'Brian',
    'Hanus',
    '(474)346-5555',
    '934 N Ballin Ave.',
    'Chicago',
    'IL'
  );
 
INSERT INTO instructor
  ( instructor_id,
    instructor_first_name,
    instructor_last_name,
    instructor_phone,
    instructor_address,
    instructor_city,
    instructor_state
  )
VALUES
  ( 'I-00002',
    'Ted',
    'Bundy',
    '(345)649-5555',
    '934 N Prison Ave.',
    'Chicago',
    'IL'
  ); 
  
INSERT INTO instructor
  ( instructor_id,
    instructor_first_name,
    instructor_last_name,
    instructor_phone,
    instructor_address,
    instructor_city,
    instructor_state
  )
VALUES
  ( 'I-00003',
    'Dhali',
    'Llama',
    '(123)456-5555',
    '934 N Clarity Ln.',
    'Northfield',
    'IL'
  );
INSERT INTO instructor
  ( instructor_id,
    instructor_first_name,
    instructor_last_name,
    instructor_phone,
    instructor_address,
    instructor_city,
    instructor_state
  )
VALUES
  ( 'I-00004',
    'Mike',
    'Ditka',
    '(987)578-5555',
    '3485 W Whitewater St.',
    'Barington',
    'IL'
  );
  
INSERT INTO instructor
  ( instructor_id,
    instructor_first_name,
    instructor_last_name,
    instructor_phone,
    instructor_address,
    instructor_city,
    instructor_state
  )
VALUES
  ( 'I-00005',
    'Danika',
    'Patrick',
    '(846)119-5555',
    '8943 N Green St.',
    'Wheeling',
    'IL'
  );
  
--Fill terms table

INSERT INTO terms
  ( terms_id,
    term_description,
    term_rate_per_half_hour
  )
VALUES
  ( 'term_1',
    'Court reservation for non member',
    15.00
  );
  
INSERT INTO terms
  ( terms_id,
    term_description,
    term_rate_per_half_hour
  )
VALUES
  ( 'term_2',
    'Court reservation for member',
    15.00 - (15 * .05)
  );  
  
INSERT INTO terms
  ( terms_id,
    term_description,
    term_rate_per_half_hour
  )
VALUES
  ( 'term_3',
    'Lesson for non member',
    40.00
  );
  
INSERT INTO terms
  ( terms_id,
    term_description,
    term_rate_per_half_hour
  )
VALUES
  ( 'term_4',
    'Lesson for member',
    40.00 - (40 * .05)
  );

INSERT INTO terms
  ( terms_id,
    term_description,
    term_rate_per_half_hour
  )
VALUES
  ( 'term_5',
    'Instructor open court walk on',
    0.00
  );
  
--Fill court and court_status
  
CALL populate_court('20-MAY-2015');
  
--Fill reservations
  
CALL reserve_court('cl-00003', '20-MAY-2015', 1, 10, 12);
CALL reserve_court('cl-00002', '20-MAY-2015', 1, 13, 15);
CALL reserve_court('cl-00001', '20-MAY-2015', 2, 1, 4);
CALL reserve_court('cl-00004', '20-MAY-2015', 3, 7, 7);
CALL reserve_court('cl-00004', '20-MAY-2015', 5, 10, 12);
CALL reserve_court('cl-00003', '20-MAY-2015', 8, 20, 28);

--Create lessons

CALL create_lesson('l-00001', 'I-00001', '20-MAY-2015', 4, 15, 18, 'Intermediate');
CALL fill_lesson('cl-00001', 'l-00001');
CALL fill_lesson('cl-00002', 'l-00001');

CALL create_lesson('l-00002', 'I-00002', '20-MAY-2015', 4, 19, 19, 'Beginner');
CALL fill_lesson('cl-00003', 'l-00002');
CALL fill_lesson('cl-00004', 'l-00002');
CALL fill_lesson('cl-00005', 'l-00002');

CALL create_lesson('l-00003', 'I-00003', '20-MAY-2015', 4, 4, 5, 'Advanced-Beginner');
CALL fill_lesson('cl-00005', 'l-00003');

CALL create_lesson('l-00004', 'I-00004', '20-MAY-2015', 4, 7, 10, 'Intermediate');
CALL fill_lesson('cl-00001', 'l-00004');
CALL fill_lesson('cl-00002', 'l-00004');
CALL fill_lesson('cl-00003', 'l-00004');
CALL fill_lesson('cl-00004', 'l-00004');

CALL create_lesson('l-00005', 'I-00005', '20-MAY-2015', 4, 11, 12, 'Advanced');
CALL fill_lesson('cl-00001', 'l-00005');
CALL fill_lesson('cl-00002', 'l-00005');

CALL create_lesson('l-00006', 'I-00004', '20-MAY-2015', 6, 1, 5, 'Intermediate');
CALL fill_lesson('cl-00001', 'l-00006');
CALL fill_lesson('cl-00002', 'l-00006');
CALL fill_lesson('cl-00003', 'l-00006');
CALL fill_lesson('cl-00004', 'l-00006');