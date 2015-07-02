/*
 * Brian Hanus  
 * Modern Database Mgmt, Section 1, Spring 2015
 * hanusbDDL.sql
 * 
 * This file creates the database objects.
 *
 */
 --drop all tables

 DROP TABLE enrollment;
 DROP TABLE court;
 DROP TABLE court_group;
 DROP TABLE lesson;
 DROP TABLE invoice;
 DROP TABLE terms;
 DROP TABLE client;
 DROP TABLE instructor;
 
 --Create the user
 
 CONNECT hanusb/hanusb;
 
 CREATE USER hanusb 
    IDENTIFIED BY hanusb
    GRANT ALL PRIVILEGES TO hanusb;

 --create the tables

 CREATE TABLE instructor
 (
    instructor_id             VARCHAR2(25),
    instructor_first_name     VARCHAR2(100) NOT NULL,
    instructor_last_name      VARCHAR2(100) NOT NULL,
    instructor_phone          VARCHAR2(20) NOT NULL,
    instructor_address        VARCHAR2(100) NOT NULL,
    instructor_city           VARCHAR2(50) NOT NULL,
    instructor_state          CHAR(2) NOT NULL,
    
    CONSTRAINT pk_instructor
      PRIMARY KEY(instructor_id)
 );
 
  CREATE TABLE client
 (
    client_id                 VARCHAR2(25),
    client_member             CHAR(1) NOT NULL,
    client_first_name         VARCHAR2(100) NOT NULL,
    client_last_name          VARCHAR2(100) NOT NULL,
    client_phone              VARCHAR2(20) NOT NULL,
    client_address            VARCHAR2(100) NOT NULL,
    client_city               VARCHAR2(50) NOT NULL,
    client_state              CHAR(2) NOT NULL,
    
    CONSTRAINT pk_client
      PRIMARY KEY(client_id)
 );
 
CREATE TABLE terms
 (
    terms_id                  VARCHAR2(20),
    term_description          VARCHAR2(150) NOT NULL,
    term_rate_per_half_hour   NUMBER(5, 2) NOT NULL,
    
    CONSTRAINT pk_terms
      PRIMARY KEY(terms_id)
 );
 
CREATE TABLE invoice
 (
    invoice_id                VARCHAR2(100),
    invoice_amt               NUMBER(6, 2) NOT NULL,
    invoice_date              DATE DEFAULT SYSDATE,
    payment_total             NUMBER(6, 2) DEFAULT 0,
    terms_id                  VARCHAR2(20) NOT NULL,
    client_id                 VARCHAR2(25) NOT NULL,
    CONSTRAINT pk_invoice
      PRIMARY KEY(invoice_id),
      
    CONSTRAINT fk_invoice_terms
      FOREIGN KEY (terms_id)
      REFERENCES terms(terms_id),
    CONSTRAINT fk_invoice_client
      FOREIGN KEY (client_id)
      REFERENCES client(client_id)
 );
 
CREATE TABLE lesson
 (
    lesson_id                 VARCHAR2(25),
    court_cluster             VARCHAR2(50) NOT NULL,
    instructor_id             VARCHAR2(25) NOT NULL,
    enrollment_id             VARCHAR2(25) NOT NULL,
    lesson_level              VARCHAR2(50) NOT NULL,
    
    CONSTRAINT pk_lesson
      PRIMARY KEY(lesson_id),
      
    CONSTRAINT fk_lesson_instructor
      FOREIGN KEY (instructor_id)
      REFERENCES instructor(instructor_id)
 );
 
  CREATE TABLE court_group
 (  
    court_cluster             VARCHAR2(50),
    lesson_id                 VARCHAR2(25),
    client_id                 VARCHAR2(25),    
    
    CONSTRAINT pk_court_group
      PRIMARY KEY(court_cluster),
      
    CONSTRAINT fk_court_group_lesson
      FOREIGN KEY(lesson_id)
      REFERENCES lesson(lesson_id),
    CONSTRAINT fk_court_group_client
      FOREIGN KEY(client_id)
      REFERENCES client(client_id)
 );
 
 CREATE TABLE court
  ( 
    court_number              NUMBER(1),
    court_date                DATE,
    court_slot                NUMBER(2),
    court_cluster             VARCHAR2(50),
    court_aval                NUMBER(1) DEFAULT 0,
    
    CONSTRAINT pk_court
      PRIMARY KEY (court_number, court_date, court_slot),
    
    CONSTRAINT fk_court_court_group
      FOREIGN KEY (court_cluster)
      REFERENCES court_group(court_cluster) 
  );

 CREATE TABLE enrollment
 (
    client_id                 VARCHAR2(25) NOT NULL,
    lesson_id                 VARCHAR2(25) NOT NULL,
      
    CONSTRAINT fk_enrollment_client
      FOREIGN KEY(client_id)
      REFERENCES client(client_id),
    CONSTRAINT fk_enrollment_lesson
      FOREIGN KEY(lesson_id)
      REFERENCES lesson(lesson_id)
 );





--Procedures

create or replace PROCEDURE populate_court
  (
    day_in            IN court.court_date %TYPE
  )
  AS
  i NUMBER;
  j NUMBER;
  BEGIN
    FOR i IN 1..8 LOOP
      FOR j IN 1..28 LOOP
        INSERT INTO court
        ( court_number,
          court_date,
          court_slot
        )
        VALUES
        ( i,
          day_in,
          j
        );
      END LOOP;
    END LOOP;
  END;
/



CREATE OR REPLACE PROCEDURE reserve_court
  ( 
    client_id_in      IN client.client_id%TYPE,
    court_date_in     IN court.court_date%TYPE,
    court_number_in   IN court.court_number%TYPE,
    slot_begin        IN court.court_slot%TYPE,
    slot_end          IN court.court_slot%TYPE
  )
  AS
  term_id_in VARCHAR2(20);
  term_id_calc NUMBER(5, 2);
  slot_total NUMBER;
  client_member_bool CHAR;
  BEGIN
  --Create a court group for the clients court reservation
    INSERT INTO court_group
      (
        court_cluster,
        client_id
      )
    VALUES  
      ('CC' || '-' || TO_CHAR(court_date_in, 'MMDDYY') || court_number_in || slot_begin,
        client_id_in
      );
    
  --Update the court time status aval 
    UPDATE court
    SET court_cluster = 'CC' || '-' || TO_CHAR(court_date_in, 'MMDDYY') || court_number_in || slot_begin,
      court_aval = 1
    WHERE court_date = court_date_in 
      AND court_number = court_number_in  
      AND court_slot BETWEEN slot_begin AND slot_end;
      
  --Calculate the amount due for the court
  slot_total := slot_end - slot_begin + 1;
  SELECT client_member
  INTO client_member_bool
  FROM client
  WHERE client_id = client_id_in;
  
  IF client_member_bool = 'Y' THEN
    SELECT term_rate_per_half_hour
    INTO term_id_calc
    FROM terms
    WHERE terms_id = 'term_2';
    term_id_in := 'term_2';
  ELSE
    SELECT term_rate_per_half_hour
    INTO term_id_calc
    FROM terms
    WHERE terms_id = 'term_1';
    term_id_in := 'term_1';
  END IF;
  
  --Bill the client
    INSERT INTO invoice
      (
        invoice_id,
        invoice_amt,
        invoice_date,
        payment_total,
        terms_id,
        client_id
      )
    VALUES
      (
        client_id_in || court_date_in || court_number_in || slot_begin,
        slot_total * term_id_calc,
        court_date_in,
        0,
        term_id_in,
        client_id_in
      );
  END;
/



CREATE OR REPLACE PROCEDURE create_lesson
  (lesson_id_in           IN lesson.lesson_id%TYPE,
    instructor_id_in      IN instructor.instructor_id%TYPE,
    court_date_in         IN court.court_date%TYPE,
    court_number_in       IN court.court_number%TYPE,
    slot_begin            IN court.court_slot%TYPE,
    slot_end              IN court.court_slot%TYPE,
    lesson_level_in       IN lesson.lesson_level%TYPE
  )
  AS
  BEGIN   
    INSERT INTO lesson
      (lesson_id,
        court_cluster,
        instructor_id,
        enrollment_id,
        lesson_level  
      )
    VALUES
      (
        lesson_id_in,
        'CC' || '-' || TO_CHAR(court_date_in, 'MMDDYY') || court_number_in || slot_begin,
        instructor_id_in,
        'e-' || court_date_in || court_number_in || slot_begin,
        lesson_level_in
      );
   
    INSERT INTO court_group
      (
        court_cluster,
        lesson_id
      )
    VALUES  
      ('CC' || '-' || TO_CHAR(court_date_in, 'MMDDYY') || court_number_in || slot_begin,
        lesson_id_in
      );
      
    UPDATE court
    SET court_cluster = 'CC' || '-' || TO_CHAR(court_date_in, 'MMDDYY') || court_number_in || slot_begin,
      court_aval = 2
    WHERE court_date = court_date_in 
      AND court_number = court_number_in  
      AND court_slot BETWEEN slot_begin AND slot_end;
  END;
/

CREATE OR REPLACE PROCEDURE fill_lesson
  (
    client_id_in              IN client.client_id%TYPE,
    lesson_id_in              IN lesson.lesson_id%TYPE
  )
  AS
  slot_total NUMBER;
  client_member_bool CHAR;
  term_id_in VARCHAR(20);
  term_id_calc VARCHAR(20);
  court_date_in DATE;
  court_number_in NUMBER;
  BEGIN
    INSERT INTO enrollment
      (
        client_id,
        lesson_id
      )
    VALUES
      (
        client_id_in,
        lesson_id_in
      );
  --Create invoice for the client enrolling in the lesson
      SELECT COUNT(c.court_slot), court_date, court_number
      INTO slot_total, court_date_in, court_number_in
      FROM lesson l
          JOIN court_group cg
            USING (lesson_id)
          JOIN court c
            ON c.court_cluster = cg.court_cluster
      WHERE lesson_id = lesson_id_in
      GROUP BY court_date, court_number;
      
      SELECT client_member
      INTO client_member_bool
      FROM client
      WHERE client_id = client_id_in;
  
      IF client_member_bool = 'Y' THEN
        SELECT term_rate_per_half_hour
        INTO term_id_calc
        FROM terms
        WHERE terms_id = 'term_4';
        term_id_in := 'term_4';
      ELSE
        SELECT term_rate_per_half_hour
        INTO term_id_calc
        FROM terms
        WHERE terms_id = 'term_3';
        term_id_in := 'term_3';
      END IF;
      
      INSERT INTO invoice
        (
          invoice_id,
          invoice_amt,
          invoice_date,
          payment_total,
          terms_id,
          client_id
        )
      VALUES
        (
          client_id_in || court_date_in || court_number_in || lesson_id_in,
          slot_total * term_id_calc,
          court_date_in,
          0,
          term_id_in,
          client_id_in
        );
      
  END;
  /

 
