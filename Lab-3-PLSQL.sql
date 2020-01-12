SET SERVEROUTPUT ON;
SET VERIFY OFF;

-- Exe 1

SELECT d.department_name nume, COUNT(e.employee_id) nr
FROM departments d, employees e
WHERE d.department_id = e.department_id(+)
GROUP BY department_name;
--HAVING COUNT(*) >= 8;

DECLARE
    v_nr NUMBER(4);
    v_name departments.department_name%TYPE;
    CURSOR c IS
        SELECT d.department_name nume, COUNT(e.employee_id) nr
        FROM departments d, employees e
        WHERE d.department_id = e.department_id(+)
        GROUP BY department_name;
BEGIN
    OPEN c;
    LOOP
        FETCH c INTO v_name, v_nr;
        EXIT WHEN c%NOTFOUND;
        IF v_nr=0 THEN
         DBMS_OUTPUT.PUT_LINE('In departamentul '|| v_name||
                           ' nu lucreaza angajati');
          ELSIF v_nr=1 THEN
               DBMS_OUTPUT.PUT_LINE('In departamentul '|| v_name||
                               ' lucreaza un angajat');
          ELSE
             DBMS_OUTPUT.PUT_LINE('In departamentul '|| v_name||
                               ' lucreaza '|| v_nr||' angajati');
         END IF;
     END LOOP;
     CLOSE c;
END;
/

-- Exe 2 (1 rezolvat folosind COLECTII)

DECLARE
    TYPE name_table IS TABLE OF departments.department_name%TYPE;
    TYPE nr_table IS TABLE OF NUMBER(4);
    t_name name_table;
    t_nr nr_table;
    CURSOR c IS
        SELECT d.department_name nume, COUNT(e.employee_id) nr
        FROM departments d, employees e
        WHERE d.department_id = e.department_id(+)
        GROUP BY department_name;
BEGIN
    OPEN c;
    FETCH c BULK COLLECT INTO t_name, t_nr;
    CLOSE c;
    FOR i IN t_name.FIRST .. t_name.LAST LOOP
        IF t_nr(i)=0 THEN
         DBMS_OUTPUT.PUT_LINE('In departamentul '|| t_name(i)||
                           ' nu lucreaza angajati');
          ELSIF t_nr(i)=1 THEN
               DBMS_OUTPUT.PUT_LINE('In departamentul '|| t_name(i)||
                               ' lucreaza un angajat');
          ELSE
             DBMS_OUTPUT.PUT_LINE('In departamentul '|| t_name(i)||
                               ' lucreaza '|| t_nr(i)||' angajati');
         END IF;
     END LOOP;
END;
/

-- adaugand LIMITE
DECLARE
    TYPE name_table IS TABLE OF departments.department_name%TYPE;
    TYPE nr_table IS TABLE OF NUMBER(4);
    t_name name_table;
    t_nr nr_table;
    CURSOR c IS
        SELECT d.department_name nume, COUNT(e.employee_id) nr
        FROM departments d, employees e
        WHERE d.department_id = e.department_id(+)
        GROUP BY department_name;
BEGIN
    OPEN c;
    LOOP
        FETCH c BULK COLLECT INTO t_name, t_nr limit 5;
        EXIT WHEN c%NOTFOUND;
        FOR i IN t_name.FIRST .. t_name.LAST LOOP
            IF t_nr(i)=0 THEN
             DBMS_OUTPUT.PUT_LINE('In departamentul '|| t_name(i)||
                               ' nu lucreaza angajati');
              ELSIF t_nr(i)=1 THEN
                   DBMS_OUTPUT.PUT_LINE('In departamentul '|| t_name(i)||
                                   ' lucreaza un angajat');
              ELSE
                 DBMS_OUTPUT.PUT_LINE('In departamentul '|| t_name(i)||
                                   ' lucreaza '|| t_nr(i)||' angajati');
             END IF;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('au fost prelucrate 5');
     END LOOP;
     CLOSE c;
END;
/


-- Exe 3 (1 rezolvat folosind CICLU CURSOR)
 
DECLARE
  CURSOR c IS
    SELECT department_name nume, COUNT(employee_id) nr 
    FROM   departments d, employees e
    WHERE  d.department_id=e.department_id(+)
    GROUP BY department_name; 
BEGIN
  FOR linie in c LOOP
      IF linie.nr=0 THEN
         DBMS_OUTPUT.PUT_LINE('In departamentul '|| linie.nume||
                           ' nu lucreaza angajati');
      ELSIF linie.nr=1 THEN
           DBMS_OUTPUT.PUT_LINE('In departamentul '|| linie.nume ||
                           ' lucreaza un angajat');
      ELSE
         DBMS_OUTPUT.PUT_LINE('In departamentul '|| linie.nume||
                           ' lucreaza '|| linie.nr||' angajati');
     END IF;
 END LOOP;
END;
/

--cu erori
DECLARE
  CURSOR c IS
    SELECT department_name nume, COUNT(employee_id) nr 
    FROM   departments d, employees e
    WHERE  d.department_id=e.department_id(+)
    GROUP BY department_name; 
BEGIN
  --open c;
  FOR i in c LOOP
      IF i.nr=0 THEN
         DBMS_OUTPUT.PUT_LINE('In departamentul '|| i.nume||
                           ' nu lucreaza angajati');
      ELSIF i.nr=1 THEN
           DBMS_OUTPUT.PUT_LINE('In departamentul '|| i.nume ||
                           ' lucreaza un angajat');
      ELSE
         DBMS_OUTPUT.PUT_LINE('In departamentul '|| i.nume||
                           ' lucreaza '|| i.nr||' angajati');
     END IF;
     --DBMS_OUTPUT.PUT_LINE(c%rowcount);
 END LOOP;
 --DBMS_OUTPUT.PUT_LINE(c%rowcount);
 --close c;
END;
/

-- no_data_found
DECLARE
  CURSOR c IS
    SELECT department_name nume, COUNT(employee_id) nr 
    FROM   departments d, employees e
    WHERE  d.department_id=e.department_id(+) and 1=2
    GROUP BY department_name; 
  x int := 0;
BEGIN
  FOR i in c LOOP
      x:=1;
      IF i.nr=0 THEN
         DBMS_OUTPUT.PUT_LINE('In departamentul '|| i.nume||
                           ' nu lucreaza angajati');
      ELSIF i.nr=1 THEN
           DBMS_OUTPUT.PUT_LINE('In departamentul '|| i.nume ||
                           ' lucreaza un angajat');
      ELSE
         DBMS_OUTPUT.PUT_LINE('In departamentul '|| i.nume||
                           ' lucreaza '|| i.nr||' angajati');
     END IF;
 END LOOP;
 if x=0 then raise no_data_found;
 end if;
END;
/

-- Exe 4 (1 rezolvat folosind CICLU CURSOR CU SUBCERERI)
BEGIN
  FOR i in (SELECT department_name nume, COUNT(employee_id) nr 
            FROM   departments d, employees e
            WHERE  d.department_id=e.department_id(+)
            GROUP BY department_name) LOOP
      IF i.nr=0 THEN
         DBMS_OUTPUT.PUT_LINE('In departamentul '|| i.nume||
                           ' nu lucreaza angajati');
      ELSIF i.nr=1 THEN
           DBMS_OUTPUT.PUT_LINE('In departamentul '|| i.nume ||
                           ' lucreaza un angajat');
      ELSE
         DBMS_OUTPUT.PUT_LINE('In departamentul '|| i.nume||
                           ' lucreaza '|| i.nr||' angajati');
     END IF;
 END LOOP;
END;
/

-- Exe 5
SELECT employee_id, manager_id FROM employees;

SELECT *
FROM(
    SELECT m.employee_id, MAX(m.last_name), COUNT(e.employee_id) 
    FROM employees e JOIN employees m ON(e.manager_id = m.employee_id)
    GROUP BY m.employee_id
    ORDER BY 3 DESC
)
WHERE ROWNUM <4;

DECLARE
    v_cod employees.employee_id%TYPE;
    v_nume employees.last_name%TYPE;
    v_nr NUMBER(4);
    CURSOR c IS
        SELECT m.employee_id cod, MAX(m.last_name) nume, COUNT(*) nr 
        FROM employees e JOIN employees m ON(e.manager_id = m.employee_id)
        GROUP BY m.employee_id
        ORDER BY 3 DESC;
BEGIN
    OPEN c;
    LOOP
        FETCH c INTO v_cod, v_nume, v_nr;
        EXIT WHEN c%ROWCOUNT > 3 OR c%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Managerul '|| v_cod || 
                           ' avand numele ' || v_nume || 
                           ' conduce ' || v_nr||' angajati');    
    END LOOP;
    CLOSE c;
END;
/

-- Exe 6 (5 rezolvat folosind CICLU CURSOR)
DECLARE
    CURSOR c IS
        SELECT m.employee_id cod, MAX(m.last_name) nume, COUNT(*) nr 
        FROM employees e JOIN employees m ON(e.manager_id = m.employee_id)
        GROUP BY m.employee_id
        ORDER BY 3 DESC;
BEGIN
    FOR linie IN c LOOP
        EXIT WHEN c%ROWCOUNT > 3 OR c%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Managerul '|| linie.cod || 
                           ' avand numele ' || linie.nume || 
                           ' conduce ' || linie.nr||' angajati');    
    END LOOP;
END;
/

-- Exe 7 (5 rezolvat folosind CICLU CURSOR CU SUBCERERI)
DECLARE
    contor NUMBER(1) :=0;
BEGIN
    FOR linie IN (SELECT m.employee_id cod, MAX(m.last_name) nume, COUNT(*) nr 
        FROM employees e JOIN employees m ON(e.manager_id = m.employee_id)
        GROUP BY m.employee_id
        ORDER BY 3 DESC) LOOP
        
        DBMS_OUTPUT.PUT_LINE('Managerul '|| linie.cod || 
                           ' avand numele ' || linie.nume || 
                           ' conduce ' || linie.nr||' angajati');
        contor := contor+1;
        EXIT WHEN CONTOR = 3;
    END LOOP;
END;
/

-- Exe 8 (1 rezolvat cu cerinta minima)
DECLARE
  nr_min NUMBER(4) := '&minim';
  CURSOR c IS
    SELECT department_name nume, COUNT(employee_id) nr 
    FROM   departments d, employees e
    WHERE  d.department_id=e.department_id(+)
    GROUP BY department_name; 
BEGIN
  FOR linie in c LOOP
      IF linie.nr=0 AND linie.nr >= nr_min THEN
         DBMS_OUTPUT.PUT_LINE('In departamentul '|| linie.nume||
                           ' nu lucreaza angajati');
      ELSIF linie.nr=1 AND linie.nr >= nr_min THEN
           DBMS_OUTPUT.PUT_LINE('In departamentul '|| linie.nume ||
                           ' lucreaza un angajat');
      ELSIF linie.nr >= nr_min THEN
         DBMS_OUTPUT.PUT_LINE('In departamentul '|| linie.nume||
                           ' lucreaza '|| linie.nr||' angajati');
     END IF;
 END LOOP;
END;
/

-- CU TOATE TIPURILE DE CURSOARE
DECLARE
  v_x     number(4) := &p_x;
  v_nr    number(4);
  v_nume  departments.department_name%TYPE;

  CURSOR c (paramentru NUMBER) IS
    SELECT department_name nume, COUNT(employee_id) nr  
    FROM   departments d, employees e
    WHERE  d.department_id=e.department_id
    GROUP BY department_name
    HAVING COUNT(employee_id)> paramentru; 
BEGIN
  OPEN c(v_x);
  LOOP
      FETCH c INTO v_nume,v_nr;
      EXIT WHEN c%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE('In departamentul '|| v_nume||
                           ' lucreaza '|| v_nr||' angajati');
 END LOOP;
 CLOSE c;
END;
/

DECLARE
 v_x     number(4) := &p_x;
 CURSOR c (paramentru NUMBER) IS
    SELECT department_name nume, COUNT(employee_id) nr 
    FROM   departments d, employees e
    WHERE  d.department_id=e.department_id
    GROUP BY department_name
    HAVING COUNT(employee_id)> paramentru; 
BEGIN
  FOR i in c(v_x) LOOP
     DBMS_OUTPUT.PUT_LINE('In departamentul '|| i.nume||
                           ' lucreaza '|| i.nr||' angajati');
  END LOOP;
END;
/

DECLARE
 v_x     number(4) := &p_x;
 BEGIN
  FOR i in (SELECT department_name nume, COUNT(employee_id) nr 
            FROM   departments d, employees e
            WHERE  d.department_id=e.department_id
            GROUP BY department_name 
            HAVING COUNT(employee_id)> v_x) 
  LOOP
     DBMS_OUTPUT.PUT_LINE('In departamentul '|| i.nume||
                           ' lucreaza '|| i.nr||' angajati');
END LOOP;
END;
/

-- Exe 9
select * from emp_nic;
SELECT EXTRACT( YEAR FROM SYSDATE) FROM DUAL;
SELECT TO_CHAR( SYSDATE, 'YYYY') FROM DUAL;
SELECT salary FROM emp_nic
WHERE EXTRACT( YEAR FROM hire_date) = 2000;
ROLLBACK;

DECLARE
    CURSOR c IS
        SELECT * FROM emp_nic
        WHERE EXTRACT( YEAR FROM hire_date) = 2000
        FOR UPDATE OF salary NOWAIT;
BEGIN
    FOR linie IN c LOOP
        UPDATE emp_nic
        SET salary = salary+1000
        WHERE CURRENT OF c;
    END LOOP;
END;
/


-- Exe 10
BEGIN
    FOR v_dep IN ( SELECT department_id, department_name
        FROM departments WHERE department_id IN (10,20,30,40)) LOOP
        DBMS_OUTPUT.PUT_LINE('DEPARTMENT NAME: ' || v_dep.department_name);
        
        FOR v_emp IN (SELECT * FROM employees WHERE department_id = v_dep.department_id) LOOP
            DBMS_OUTPUT.PUT(v_emp.last_name||' ');
        END LOOP;
        DBMS_OUTPUT.NEW_LINE();
    END LOOP;
END;
/

-- cu EXPRESII CURSOR
DECLARE   
    TYPE refcursor IS REF CURSOR;   
    CURSOR c_dept IS     
        SELECT department_name,             
            CURSOR (SELECT last_name                     
                    FROM   employees e                    
                    WHERE  e.department_id = d.department_id)     
        FROM   departments d     
        WHERE  department_id IN (10,20,30,40);   
    v_nume_dept   departments.department_name%TYPE;   
    v_cursor      refcursor;   
    v_nume_emp    employees.last_name%TYPE; 
BEGIN   
    OPEN c_dept;   
    LOOP    
        FETCH c_dept INTO v_nume_dept, v_cursor;     
        EXIT WHEN c_dept%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('-------------------------------------');     
        DBMS_OUTPUT.PUT_LINE ('DEPARTAMENT '||v_nume_dept);     
        DBMS_OUTPUT.PUT_LINE('-------------------------------------');     
        LOOP       
            FETCH v_cursor 
            INTO v_nume_emp;       
            EXIT WHEN v_cursor%NOTFOUND;       
            DBMS_OUTPUT.PUT_LINE (v_nume_emp);     
        END LOOP;   
    END LOOP;   
    CLOSE c_dept; 
END; 
/ 

-- Exe 11 si 12 -> nu intra cursoare dinamice

-- EXERCITII --

-- Ex 1
SELECT * FROM jobs;
CREATE TABLE jobs_nic AS SELECT * FROM jobs;
SELECT * FROM jobs_nic;
INSERT INTO jobs_nic
VALUES ('TST', 'Tester', 1000, 10000);

SELECT job_title, COUNT(employee_id)
FROM jobs_nic LEFT OUTER JOIN employees USING (job_id)
GROUP BY job_title;

BEGIN
    FOR jobs IN (SELECT job_id, job_title FROM jobs_nic) LOOP
        DBMS_OUTPUT.PUT_LINE('JOB: ' || jobs.job_title);
        FOR people IN (SELECT last_name, salary FROM emp_nic WHERE job_id = jobs.job_id) LOOP
            DBMS_OUTPUT.PUT_LINE(people.last_name || ', ' || people.salary);
        END LOOP;
        DBMS_OUTPUT.NEW_LINE();
    END LOOP;
END;
/

-- Ex 2
-- cu expresii cursor -- nu este corect deoarece imi afiseaza un job de atatea ori cati membri are
DECLARE
    TYPE refcursor IS REF CURSOR;
    CURSOR c_jobs IS
        SELECT job_title,
            CURSOR (SELECT last_name, salary FROM employees WHERE job_id = j. job_id)
        FROM jobs_nic j LEFT OUTER JOIN employees e ON (j.job_id = e.job_id);
    
    v_title jobs.job_title%TYPE;
    v_nr NUMBER(4);
    v_cursor refcursor;
    v_name employees.last_name%TYPE;
    v_salary employees.salary%TYPE;
    contor NUMBER(4);
BEGIN
    OPEN c_jobs;
    LOOP 
        FETCH c_jobs INTO v_title, v_cursor;
        EXIT WHEN c_jobs%NOTFOUND;
        
        DBMS_OUTPUT.PUT('JOB: ' || v_title);
--        SELECT COUNT(employee_id) INTO v_nr FROM jobs_nic LEFT OUTER JOIN employees USING (job_id) GROUP BY job_title;
--        DBMS_OUTPUT.PUT(' NR_ANGAJATI: ' || v_nr);
        contor := 1;
        LOOP
            FETCH v_cursor INTO v_name, v_salary;
            EXIT WHEN v_cursor%NOTFOUND;

            DBMS_OUTPUT.PUT_LINE(contor || ': ' || v_name || ', ' || v_salary);
            contor := contor +  1;

        END LOOP;

    END LOOP;
    CLOSE c_jobs;
END;
/


SELECT job_title titlu, COUNT(employee_id) nr, SUM(salary) total, AVG(salary) medie
FROM jobs_nic LEFT OUTER JOIN employees USING (job_id)
GROUP BY job_title;

SELECT COUNT(employee_id), SUM(salary), AVG(salary)
FROM employees;

DECLARE
    v_nr NUMBER(4);
    v_sum NUMBER(9);
    v_avg NUMBER(7);
    contor NUMBER(4);
BEGIN
    SELECT COUNT(employee_id), SUM(salary), AVG(salary)
    INTO v_nr, v_sum, v_avg
    FROM employees;
    DBMS_OUTPUT.PUT_LINE('IN TOTAL: NR_ANGAJATI: ' || v_nr || ' VAL LUNARA VENIT: ' || v_sum || ' VAL MEDIE VENIT: ' || v_avg);
    DBMS_OUTPUT.NEW_LINE();

    FOR jobs IN (SELECT job_id, job_title FROM jobs_nic) LOOP
        DBMS_OUTPUT.PUT_LINE('JOB: ' || jobs.job_title);
  
        SELECT COUNT(employee_id), SUM(NVL(salary,0)), AVG(NVL(salary,0)) INTO v_nr, v_sum, v_avg
        FROM jobs_nic LEFT OUTER JOIN employees USING (job_id) 
        GROUP BY job_title
        HAVING job_title = jobs.job_title;
        DBMS_OUTPUT.PUT_LINE(' NR_ANGAJATI: ' || v_nr || ' VAL LUNARA VENIT: ' || v_sum || ' VAL MEDIE VENIT: ' || v_avg);
--        
        contor := 1;
        FOR people IN (SELECT last_name, salary FROM emp_nic WHERE job_id = jobs.job_id) LOOP
            DBMS_OUTPUT.PUT_LINE(contor || ': ' || people.last_name || ', ' || people.salary);
            contor := contor +  1;
        END LOOP;
        DBMS_OUTPUT.NEW_LINE();
    END LOOP;
END;
/


-- Ex 3
SELECT * FROM emp_nic;
SELECT SUM(salary + commission_pct*salary)
FROM emp_nic;
DECLARE
    v_nr NUMBER(4);
    v_total NUMBER(9);
    v_sum NUMBER(9);
    v_avg NUMBER(7);
    contor NUMBER(4);
    v_procent FLOAT;
BEGIN
    SELECT COUNT(employee_id), SUM(salary), AVG(salary), SUM(salary + commission_pct*salary)
    INTO v_nr, v_sum, v_avg, v_total
    FROM employees;
    DBMS_OUTPUT.PUT_LINE('IN TOTAL: NR_ANGAJATI: ' || v_nr || ' TOTAL ALOCAT: ' || v_total|| ' VAL LUNARA VENIT: ' || v_sum || ' VAL MEDIE VENIT: ' || v_avg);
    DBMS_OUTPUT.NEW_LINE();

    FOR jobs IN (SELECT job_id, job_title FROM jobs_nic) LOOP
        DBMS_OUTPUT.PUT_LINE('JOB: ' || jobs.job_title);
  
        SELECT COUNT(employee_id), SUM(NVL(salary,0)), AVG(NVL(salary,0)) INTO v_nr, v_sum, v_avg
        FROM jobs_nic LEFT OUTER JOIN employees USING (job_id) 
        GROUP BY job_title
        HAVING job_title = jobs.job_title;
        DBMS_OUTPUT.PUT_LINE(' NR_ANGAJATI: ' || v_nr || ' VAL LUNARA VENIT: ' || v_sum || ' VAL MEDIE VENIT: ' || v_avg);
--        
        contor := 1;
        FOR people IN (SELECT last_name, salary FROM emp_nic WHERE job_id = jobs.job_id) LOOP
--            v_procent := ROUND(people.salary * 100,-2) / ROUND(v_total,-2);
            v_procent := round((people.salary * 100.0 / v_total), 2);
--            v_procent := people.salary * 100.0 / v_total;
            DBMS_OUTPUT.PUT_LINE(contor || ': ' || people.last_name || ', ' || people.salary || ' care reprezinta ' || v_procent || ' la suta din salariul total: ' || v_total);
            contor := contor +  1;
        END LOOP;
        DBMS_OUTPUT.NEW_LINE();
    END LOOP;
END;
/

-- Ex 4
DECLARE
    v_nr NUMBER(4);
    v_total NUMBER(9);
    v_sum NUMBER(9);
    v_avg NUMBER(7);
    contor NUMBER(4);
    v_procent FLOAT;
BEGIN
    SELECT COUNT(employee_id), SUM(salary), AVG(salary), SUM(salary + commission_pct*salary)
    INTO v_nr, v_sum, v_avg, v_total
    FROM employees;
    DBMS_OUTPUT.PUT_LINE('IN TOTAL: NR_ANGAJATI: ' || v_nr || ' TOTAL ALOCAT: ' || v_total|| ' VAL LUNARA VENIT: ' || v_sum || ' VAL MEDIE VENIT: ' || v_avg);
    DBMS_OUTPUT.NEW_LINE();

    FOR jobs IN (SELECT job_id, job_title FROM jobs_nic) LOOP
        DBMS_OUTPUT.PUT_LINE('JOB: ' || jobs.job_title);
  
        SELECT COUNT(employee_id), SUM(NVL(salary,0)), AVG(NVL(salary,0)) INTO v_nr, v_sum, v_avg
        FROM jobs_nic LEFT OUTER JOIN employees USING (job_id) 
        GROUP BY job_title
        HAVING job_title = jobs.job_title;
        DBMS_OUTPUT.PUT_LINE(' NR_ANGAJATI: ' || v_nr || ' VAL LUNARA VENIT: ' || v_sum || ' VAL MEDIE VENIT: ' || v_avg);
--        
        contor := 1;
        FOR people IN (SELECT last_name, salary FROM emp_nic WHERE job_id = jobs.job_id ORDER BY salary DESC) LOOP
--            v_procent := ROUND(people.salary * 100,-2) / ROUND(v_total,-2);
            v_procent := round((people.salary * 100.0 / v_total), 2);
--            v_procent := people.salary * 100.0 / v_total;
            DBMS_OUTPUT.PUT_LINE(contor || ': ' || people.last_name || ', ' || people.salary || ' care reprezinta ' || v_procent || ' la suta din salariul total: ' || v_total);
            contor := contor +  1;
            EXIT WHEN contor = 6;
        END LOOP;
        IF CONTOR < 5 THEN -- v_nr
            DBMS_OUTPUT.PUT_LINE('OBS: Departamentul are mai putin de 5 angajati');
        END IF;
        DBMS_OUTPUT.NEW_LINE();
    END LOOP;
END;
/

-- Ex 5
DECLARE
    v_nr NUMBER(4);
    v_total NUMBER(9);
    v_sum NUMBER(9);
    v_avg FLOAT;
    contor NUMBER(4);
    v_procent FLOAT;
    v_prev_salary employees.salary%TYPE;
BEGIN
    SELECT COUNT(employee_id), SUM(salary), AVG(salary), SUM(salary + commission_pct*salary)
    INTO v_nr, v_sum, v_avg, v_total
    FROM employees;
    DBMS_OUTPUT.PUT_LINE('IN TOTAL: NR_ANGAJATI: ' || v_nr || ' TOTAL ALOCAT: ' || v_total|| ' VAL LUNARA VENIT: ' || v_sum || ' VAL MEDIE VENIT: ' || v_avg);
    DBMS_OUTPUT.NEW_LINE();

    FOR jobs IN (SELECT job_id, job_title FROM jobs_nic) LOOP
        DBMS_OUTPUT.PUT_LINE('JOB: ' || jobs.job_title);
  
        SELECT COUNT(employee_id), SUM(NVL(salary,0)), AVG(NVL(salary,0)) INTO v_nr, v_sum, v_avg
        FROM jobs_nic LEFT OUTER JOIN employees USING (job_id) 
        GROUP BY job_title
        HAVING job_title = jobs.job_title;
        DBMS_OUTPUT.PUT_LINE(' NR_ANGAJATI: ' || v_nr || ' VAL LUNARA VENIT: ' || v_sum || ' VAL MEDIE VENIT: ' || v_avg);
--        
        contor := 1;
        FOR people IN (SELECT last_name, salary FROM emp_nic WHERE job_id = jobs.job_id ORDER BY salary DESC) LOOP
            IF contor <= 5 OR v_prev_salary = people.salary  THEN
--                v_procent := ROUND(people.salary * 100,-2) / ROUND(v_total,-2);
                v_procent := round((people.salary * 100.0 / v_total), 2);
--                v_procent := people.salary * 100.0 / v_total;
                DBMS_OUTPUT.PUT_LINE(contor || ': ' || people.last_name || ', ' || people.salary || ' care reprezinta ' || v_procent || ' la suta din salariul total: ' || v_total);
                contor := contor +  1;
                v_prev_salary := people.salary;
            ELSE EXIT;
            END IF;
        END LOOP;
        IF contor < 5 THEN -- v_nr
            DBMS_OUTPUT.PUT_LINE('OBS: Departamentul are mai putin de 5 angajati');
        END IF;
        DBMS_OUTPUT.NEW_LINE();
    END LOOP;
END;
/