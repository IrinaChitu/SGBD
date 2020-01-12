-- Exe 1 (DECLANSATOR LA NIVEL DE INSTRUCTIUNE)
CREATE OR REPLACE TRIGGER t_time_edit
    BEFORE INSERT OR UPDATE OR DELETE ON emp_nic
BEGIN
    IF (TO_CHAR(SYSDATE, 'D') = 1) OR (TO_CHAR(SYSDATE, 'HH24') NOT BETWEEN 8 AND 20) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nu este permis lucrul asupra tabelului');
    END IF;
END;
/
DROP TRIGGER t_time_edit;

-- Exe 2 (DECLANSATOR LA NIVEL DE LINIE)
--- VAR 1
CREATE OR REPLACE TRIGGER t_min_salary
    BEFORE UPDATE ON emp_nic
    FOR EACH ROW
BEGIN
    IF(:NEW.salary < :OLD.salary) THEN
        RAISE_APPLICATION_ERROR(-20001, '1) Nu este permisa micsorarea salariului');
    END IF;
END;
/

--- VAR 2
CREATE OR REPLACE TRIGGER t_min_salary
    BEFORE UPDATE OF salary ON emp_nic
    FOR EACH ROW
    WHEN (NEW.salary < OLD.salary)
BEGIN
    RAISE_APPLICATION_ERROR(-20001, '2) Nu este permisa micsorarea salariului');
END;
/

select employee_id, salary from emp_nic;
UPDATE emp_nic    SET salary = salary-100;
UPDATE emp_nic    SET salary = salary-100    WHERE employee_id = 100;
DROP TRIGGER t_min_salary;

-- Exe 3
CREATE TABLE job_grades_nic AS SELECT *  FROM job_grades;
select * from job_grades_nic;
SELECT MIN(salary), MAX(salary) FROM emp_nic;

-- VAR 1
CREATE OR REPLACE TRIGGER t_limit_salary
    BEFORE UPDATE OF lowest_sal, highest_sal ON job_grades_nic
    FOR EACH ROW
DECLARE 
    min_salary emp_nic.salary%TYPE;
    max_salary emp_nic.salary%TYPE;
BEGIN
    SELECT MIN(salary), MAX(salary) INTO min_salary, max_salary FROM emp_nic;
    IF (:OLD.grade_level = 1) AND (:NEW.lowest_sal > min_salary) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Lowest nu e lowest!');
    END IF;
    IF (:OLD.grade_level = 7) AND (:NEW.highest_sal < max_salary) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Highest nu e highest!');
    END IF;
END;
/

-- VAR 2
CREATE OR REPLACE TRIGGER t_limit_salary
    BEFORE UPDATE OF lowest_sal, highest_sal ON job_grades_nic
    FOR EACH ROW
DECLARE 
    min_salary emp_nic.salary%TYPE;
    max_salary emp_nic.salary%TYPE;
    exceptie EXCEPTION;
BEGIN
    SELECT MIN(salary), MAX(salary) INTO min_salary, max_salary FROM emp_nic;
    IF (:OLD.grade_level = 1) AND (:NEW.lowest_sal > min_salary) THEN
        RAISE exceptie;
    END IF;
    IF (:OLD.grade_level = 7) AND (:NEW.highest_sal < max_salary) THEN
        RAISE exceptie;
    END IF;
EXCEPTION
    WHEN exceptie THEN
        RAISE_APPLICATION_ERROR (-20003, 'Exista salarii care se gasesc in afara intervalului');
END;
/

--update job_grades_nic set highest_sal = 3000 where grade_level = 7;
--update job_grades_nic set lowest_sal = 3000 where grade_level = 1;
--rollback;
--drop trigger t_limit_salary;

-- Exe 4
---a)
create table info_dept_nic (
    id NUMBER(3)  PRIMARY KEY,
    nume_dept VARCHAR2(20),
    plati NUMBER
);
drop table info_dept_nic;
ROLLBACK;
select * from info_dept_nic;

SELECT NVL(SUM(salary),0) FROM emp_nic WHERE department_id = 5; -- 10,20,60,90
SELECT department_id from employees;

---b)
insert into info_dept_nic
select d.department_id, department_name, NVL(sum(salary),0)
from   emp_nic e, departments d
where  e.department_id (+) = d.department_id
group by d.department_id, department_name;
--- SAU ---
DECLARE
    salariu NUMBER;
    CURSOR departamente IS
        SELECT department_id, department_name FROM departments;
BEGIN
    FOR dep in departamente LOOP
        SELECT NVL(SUM(salary),0)
        INTO salariu 
        FROM emp_nic
        WHERE department_id = dep.department_id;
        
        INSERT INTO info_dept_nic
        VALUES(dep.department_id, dep.department_name, salariu);
    END LOOP;
END;
/

---c)
CREATE OR REPLACE PROCEDURE update_salary
    (
        v_id info_dept_nic.id%TYPE,
        v_plati info_dept_nic.plati%TYPE
    ) AS
BEGIN
    UPDATE info_dept_nic
    SET plati = plati + v_plati --  NVL (plati, 0)
    WHERE id = v_id;
END;
/

CREATE OR REPLACE TRIGGER update_info
    AFTER INSERT OR UPDATE OR DELETE OF salary ON emp_nic
    FOR EACH ROW
BEGIN
    IF DELETING THEN
        update_salary(:OLD.department_id, -1*:OLD.salary);
    ELSIF UPDATING THEN
        update_salary(:OLD.department_id, :NEW.salary-:OLD.salary);
    ELSIF INSERTING THEN
        update_salary(:NEW.department_id, :NEW.salary);
    END IF;
END;
/

SELECT * FROM  info_dept_nic WHERE id=90;

INSERT INTO emp_nic (employee_id, last_name, email, hire_date, 
                     job_id, salary, department_id) 
VALUES (300, 'N1', 'n1@g.com',sysdate, 'SA_REP', 2000, 90);

SELECT * FROM  info_dept_nic WHERE id=90;

UPDATE emp_nic
SET    salary = salary + 1000
WHERE  employee_id=300;

SELECT * FROM  info_dept_nic WHERE id=90;

DELETE FROM emp_nic
WHERE  employee_id=300;   

SELECT * FROM  info_dept_nic WHERE id=90;

DROP TRIGGER update_info;

-- Exe 5 (!!!)
---a)
CREATE TABLE info_emp_nic (
    id NUMBER(3) NOT NULL PRIMARY KEY,
    nume VARCHAR2(30),
    prenume VARCHAR2(30),
    salariu NUMBER(8),
    id_dept NUMBER(3),
    CONSTRAINT fkk_id_dept FOREIGN KEY (id_dept) REFERENCES info_dept_nic(id)
);
drop table info_emp_nic;
select * from info_emp_nic;
select * from info_dept_nic;

---b)
insert into info_emp_nic
select employee_id, last_name, first_name, salary, department_id
from emp_nic;
rollback;

---c)
CREATE OR REPLACE VIEW v_info_nic AS
    SELECT  e.id, e.nume, e.prenume, e.salariu, e.id_dept, d.nume_dept, d.plati  
    FROM info_emp_nic e JOIN info_dept_nic d ON (e.id_dept = d.id);
--drop view v_info_nic;

---d)
SELECT *
FROM   user_updatable_columns
WHERE  table_name = UPPER('v_info_nic');
---Q: Se pot realiza actualiz?ri asupra acestei vizualiz?ri? Care este tabelul protejat prin cheie?  
--???
--insert into v_info_nic
--values(8, user, 'v_info_nic', 'comentarii', 'YES', 'YES', 'YES');
--update v_info_nic
--set updatable = 'NO' where column_name = 'NUME';

---e)
CREATE OR REPLACE TRIGGER modify_view
    INSTEAD OF INSERT OR DELETE OR UPDATE ON v_info_nic
    FOR EACH ROW
BEGIN
IF INSERTING THEN 
    -- inserarea in vizualizare determina inserarea 
    -- in info_emp_prof si reactualizarea in info_dept_prof
    -- se presupune ca departamentul exista
   INSERT INTO info_emp_nic
   VALUES (:NEW.id, :NEW.nume, :NEW.prenume, :NEW.salariu, :NEW.id_dept);

   UPDATE info_dept_nic
   SET    plati = plati + :NEW.salariu
   WHERE  id = :NEW.id_dept;

ELSIF DELETING THEN
   -- stergerea unui salariat din vizualizare determina
   -- stergerea din info_emp_prof si reactualizarea in
   -- info_dept_prof
   DELETE FROM info_emp_nic
   WHERE  id = :OLD.id;
     
   UPDATE info_dept_nic
   SET    plati = plati - :OLD.salariu
   WHERE  id = :OLD.id_dept;

ELSIF UPDATING ('salariu') THEN
   /* modificarea unui salariu din vizualizare determina 
      modificarea salariului in info_emp_prof si reactualizarea
      in info_dept_prof    */
    	
   UPDATE  info_emp_nic
   SET     salariu = :NEW.salariu
   WHERE   id = :OLD.id;
    	
   UPDATE info_dept_nic
   SET    plati = plati - :OLD.salariu + :NEW.salariu
   WHERE  id = :OLD.id_dept;

ELSIF UPDATING ('id_dept') THEN
    /* modificarea unui cod de departament din vizualizare
       determina modificarea codului in info_emp_prof 
       si reactualizarea in info_dept_prof  */  
    UPDATE info_emp_nic
    SET    id_dept = :NEW.id_dept
    WHERE  id = :OLD.id;
    
    UPDATE info_dept_nic
    SET    plati = plati - :OLD.salariu
    WHERE  id = :OLD.id_dept;
    	
    UPDATE info_dept_nic
    SET    plati = plati + :NEW.salariu
    WHERE  id = :NEW.id_dept;
  END IF;
END;
/

---f)
SELECT *
FROM   user_updatable_columns
WHERE  table_name = UPPER('v_info_nic'); -- dupa crearea triggerului s-a modificat

-- adaugarea unui nou angajat
SELECT * FROM  info_dept_nic WHERE id=10;

INSERT INTO v_info_nic 
VALUES (400, 'N1', 'P1', 3000,10, 'Nume dept', 0);

SELECT * FROM  info_emp_nic WHERE id=400;
SELECT * FROM  info_dept_nic WHERE id=10;

-- modificarea salariului unui angajat
UPDATE v_info_nic 
SET    salariu = salariu + 1000
WHERE  id=400;

SELECT * FROM  info_emp_nic WHERE id=400;
SELECT * FROM  info_dept_nic WHERE id=10;

-- modificarea departamentului unui angajat
SELECT * FROM  info_dept_nic WHERE id=90;

UPDATE v_info_nic 
SET    id_dept=90
WHERE  id=400;

SELECT * FROM  info_emp_nic WHERE id=400;
SELECT * FROM  info_dept_nic WHERE id IN (10,90);

-- eliminarea unui angajat
DELETE FROM v_info_nic WHERE id = 400;
SELECT * FROM  info_emp_nic WHERE id=400;
SELECT * FROM  info_dept_nic WHERE id = 90;

DROP TRIGGER modify_view;


-- Exe 6
CREATE OR REPLACE TRIGGER forbid_delete
    BEFORE DELETE ON emp_nic
BEGIN
    IF USER = 'GRUPA31' THEN
        RAISE_APPLICATION_ERROR(-20900,'Nu ai voie sa stergi, noob!');
    END IF;
END;
/
delete from emp_nic where employee_id = 100;
delete from emp_nic;
DROP TRIGGER forbid_delete;

-- Exe 7
---a)
CREATE TABLE audit_nic (
    utilizator  VARCHAR2(20),
    nume_bd     VARCHAR2(50),
    eveniment   VARCHAR2(20),
    nume_obiect VARCHAR2(30),
    data        DATE
);

---b) DECLANSATOR SISTEM - LA NIVEL DE SCHEMA (dupa o comanda LDD: CREATE OR DROP OR ALTER)
CREATE OR REPLACE TRIGGER ldd_niv_schema
    AFTER CREATE OR ALTER OR DROP ON SCHEMA
BEGIN
    INSERT INTO audit_nic
    VALUES (SYS.LOGIN_USER, SYS.DATABASE_NAME, SYS.SYSEVENT, SYS.DICTIONARY_OBJ_NAME, SYSDATE); 
END;
/

CREATE INDEX ind_nic ON info_emp_nic(nume); 
DROP INDEX ind_nic;

SELECT * FROM audit_nic; -- se adauga 2 randuri in urma comenzilor de mai sus

DROP TRIGGER ldd_niv_schema;


-- Exe 8 -- fara pachete nu merge (eroare cu ceva mutatii)
CREATE OR REPLACE PACKAGE pachet_nic
AS
	smin emp_nic.salary%type;
	smax emp_nic.salary%type;
	smed emp_nic.salary%type;
END pachet_nic;
/

CREATE OR REPLACE TRIGGER get_extreme
    BEFORE UPDATE OF salary ON emp_nic
BEGIN
  SELECT MIN(salary),AVG(salary),MAX(salary)
  INTO pachet_nic.smin, pachet_nic.smed, pachet_nic.smax
  FROM emp_nic;
END;
/

CREATE OR REPLACE TRIGGER modify_salary
    BEFORE UPDATE OF salary ON emp_nic
    FOR EACH ROW
BEGIN
    IF(:OLD.salary = pachet_nic.smin)AND (:NEW.salary > pachet_nic.smed) 
     THEN
       RAISE_APPLICATION_ERROR(-20001,'Acest salariu depaseste valoarea medie');
    ELSIF (:OLD.salary = pachet_nic.smax) 
           AND (:NEW.salary<  pachet_nic.smed) 
     THEN
       RAISE_APPLICATION_ERROR(-20001,'Acest salariu este sub valoarea medie');
    END IF;
END;
/


SELECT AVG(salary)
FROM   emp_nic;

UPDATE emp_nic 
SET    salary=10000 
WHERE  salary=(SELECT MIN(salary) FROM emp_nic);

UPDATE emp_nic 
SET    salary=1000 
WHERE  salary=(SELECT MAX(salary) FROM emp_nic);

DROP TRIGGER modif_salary;


-- Ex 1
CREATE OR REPLACE TRIGGER allow_delete
    BEFORE DELETE ON info_dept_nic
BEGIN
    IF USER <> 'SCOTT' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Userul nu are drept de stergere!');
    END IF;
END;
/
delete from info_dept_nic;
DROP TRIGGER allow_delete;


-- Ex 2
SELECT * FROM emp_nic;
CREATE OR REPLACE TRIGGER forbid_raise
    BEFORE UPDATE OF commission_pct ON emp_nic
    FOR EACH ROW
BEGIN
    IF (:NEW.commission_pct*:OLD.salary > 0.5*:OLD.salary) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Comisionul depastete 50% din valoarea salariului');
    END IF;
END;
/
UPDATE emp_nic
SET commission_pct = 0.6;
rollback;


-- Ex 3
---a)
SELECT * FROM info_dept_nic;
SELECT * FROM info_emp_nic;
ALTER TABLE info_dept_nic
ADD numar NUMBER DEFAULT 0;
ROLLBACK;

SELECT d.id, COUNT(e.id)
FROM info_emp_nic e RIGHT OUTER JOIN info_dept_nic d ON (e.id_dept = d.id)
GROUP BY d.id ORDER BY 1;

DECLARE 
    CURSOR dep_ang IS
        SELECT d.id, COUNT(e.id) nr
        FROM info_emp_nic e RIGHT OUTER JOIN info_dept_nic d ON (e.id_dept = d.id)
        GROUP BY d.id ORDER BY 1;
BEGIN
    FOR pair IN dep_ang LOOP
        UPDATE info_dept_nic
        SET numar = pair.nr
        WHERE id = pair.id;
    END LOOP;
END;
/

---b)
CREATE OR REPLACE TRIGGER actualizeaza_dept
    AFTER INSERT OR UPDATE OR DELETE ON info_emp_nic
    FOR EACH ROW
BEGIN
    IF INSERTING THEN
        UPDATE info_dept_nic
        SET numar = numar+1 
        WHERE id = :NEW.id_dept;
    ELSIF UPDATING THEN
        UPDATE info_dept_nic
        SET numar = numar+1 
        WHERE id = :NEW.id_dept;
        
        UPDATE info_dept_nic
        SET numar = numar-1 
        WHERE id = :OLD.id_dept;
    ELSIF DELETING THEN
        UPDATE info_dept_nic
        SET numar = numar-1 
        WHERE id = :OLD.id_dept;
    END IF;
END;
/

select * from info_emp_nic where id_dept = 10;
select * from info_dept_nic where id = 20;

INSERT INTO info_emp_nic
VALUES(207,'Chitu', 'Irina', 100000, 10);

UPDATE info_emp_nic
SET id_dept = 20 WHERE id = 207;

DELETE FROM info_emp_nic
WHERE id = 207;


-- Ex 4
create table dept_nic AS select * from departments;
select * from emp_nic WHERE department_id = 10;
select * from dept_nic;

CREATE OR REPLACE TRIGGER max_angajati
    BEFORE INSERT ON emp_nic
    FOR EACH ROW
DECLARE
    nr_ang NUMBER;
BEGIN
    select count(employee_id) into nr_ang from emp_nic where department_id = :NEW.department_id;
    DBMS_OUTPUT.PUT_LINE(nr_ang);
    IF nr_ang >= 45 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nu pot lucra mai mut de 45 de angajati intr-un departament');
    END IF;
END;
/
DROP TRIGGER max_angajati;

BEGIN
    FOR i IN 1..45 LOOP
--        DELETE FROM emp_nic
--        WHERE last_name = 'Chitu';
        insert into emp_nic
        values(300+i, 'Irina', 'Chitu', 'GMAIL', '123.456.7890', '20-OCT-98', 'MK_REP', 10000, 0.3, 100, 10);
--        COMMIT;
    END LOOP;
END;
/
rollback;


-- Ex 5
---a)
CREATE TABLE emp_test_nic (
    employee_id NUMBER(3) PRIMARY KEY,
    last_name VARCHAR2(20),
    first_name VARCHAR2(20),
    department_id NUMBER(3)
);

CREATE TABLE dept_test_nic (
    department_id NUMBER(3) PRIMARY KEY,
    dedpartment_name VARCHAR2(20)
);

INSERT INTO emp_test_nic
SELECT employee_id, last_name, first_name, department_id
FROM emp_nic;

INSERT INTO dept_test_nic
SELECT department_id, department_name
FROM departments;

select * from emp_test_nic where department_id = 5;
select * from dept_test_nic;

---b) (rezolvat fara a tine cont de cazurile cu constrangeri)
CREATE OR REPLACE TRIGGER cascade_modif
    AFTER UPDATE OR DELETE ON dept_test_nic
    FOR EACH ROW
BEGIN
    IF DELETING THEN
        DELETE FROM emp_test_nic
        WHERE department_id = :OLD.department_id;
    ELSIF UPDATING THEN
        UPDATE emp_test_nic
        SET department_id = :NEW.department_id
        WHERE department_id = :OLD.department_id;
    END IF;
END;
/

delete from dept_test_nic
where department_id = 20;

UPDATE dept_test_nic
SET department_id = 5 
WHERE department_id = 20;

rollback;

DROP TRIGGER cascade_modif;

-- Ex 6 -- Nu intra declansator de sistem la colocviu