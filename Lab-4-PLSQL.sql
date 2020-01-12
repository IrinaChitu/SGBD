SET SERVEROUTPUT ON;
SET VERIFY OFF;

-- Exe 1 (FUNCTIE LOCALA)
-- Bell, King, Kimball
SELECT last_name FROM emp_nic ORDER BY 1; -- Cambrault

DECLARE
    v_name employees.last_name%TYPE := Initcap('&p_nume');
    
    FUNCTION get_salary RETURN NUMBER 
    IS
        salariu employees.salary%TYPE;
    BEGIN
        SELECT salary INTO salariu
        FROM employees WHERE last_name = v_name;
        RETURN salariu;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             DBMS_OUTPUT.PUT_LINE('Nu exista angajati cu numele dat'); 
        WHEN TOO_MANY_ROWS THEN
             DBMS_OUTPUT.PUT_LINE('Exista mai multi angajati cu numele dat'); 
        WHEN OTHERS THEN
             DBMS_OUTPUT.PUT_LINE('Eroare'); 
    END get_salary;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Salariul angajatului ' || v_name || ' este ' || get_salary);
EXCEPTION -- daca nu punem exceptii in codul 'mare', atunci cand subprogramul prinde o eroare si o afiseaza,
        -- el nu intoarce nicio eroare, de unde si eroarea: Function returned without value
  WHEN OTHERS THEN 
    DBMS_OUTPUT.PUT_LINE('Eroarea are codul = '||SQLCODE || ' si mesajul = ' || SQLERRM);
END;
/

--cu return
DECLARE
  v_nume employees.last_name%TYPE := Initcap('&p_nume');   

  FUNCTION f1 RETURN NUMBER IS
    salariu employees.salary%type; 
  BEGIN
    SELECT salary INTO salariu 
    FROM   employees
    WHERE  last_name = v_nume;
    RETURN salariu;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       DBMS_OUTPUT.PUT_LINE('Nu exista angajati cu numele dat');
       return -1;
    WHEN TOO_MANY_ROWS THEN
       DBMS_OUTPUT.PUT_LINE('Exista mai multi angajati cu numele dat');
       return -2;
    WHEN OTHERS THEN
       DBMS_OUTPUT.PUT_LINE('Alta eroare!');
       return -3;
  END f1;
BEGIN
  if f1>0 then
     DBMS_OUTPUT.PUT_LINE('Salariul este '|| f1);
  end if;   

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Eroarea are codul = '||SQLCODE
            || ' si mesajul = ' || SQLERRM);
END;
/

-- Exe 2 (1 rezolvat folosind FUNCTIE STOCATA)
CREATE OR REPLACE FUNCTION get_salary_nic 
    (v_nume IN employees.last_name%TYPE DEFAULT 'Bell')
RETURN NUMBER 
    IS
        salariu employees.salary%TYPE;
BEGIN
    SELECT salary INTO salariu
    FROM employees WHERE last_name = v_nume;
    RETURN salariu;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20000, 'Nu exista angajati cu numele dat'); 
    WHEN TOO_MANY_ROWS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Exista mai multi angajati cu numele dat'); 
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Alta eroare'); 
END get_salary_nic;
/

-- apelare bloc PL/SQL
BEGIN
    DBMS_OUTPUT.PUT_LINE('Salariul lui Bell este: ' || get_salary_nic);
--    DBMS_OUTPUT.PUT_LINE('Salariul lui King este: ' || get_salary_nic('King')); -- prea multi
--    DBMS_OUTPUT.PUT_LINE('Salariul lui Kimball este: ' || get_salary_nic('Kimball')); -- nu exista
END;
/

-- apelare SQL
SELECT get_salary_nic FROM DUAL;
--SELECT get_salary_nic('King') FROM DUAL; -- eroare: prea multi

-- SQL*PLUS cu variabila HOST
  VARIABLE nr NUMBER
  EXECUTE :nr := get_salary_nic('Bell');
  PRINT nr
  
  
-- Exe 3 (1 rezolvat cu PROCEDURA LOCALA)
DECLARE
    v_nume employees.last_name%TYPE := Initcap('&p_nume');
    
    PROCEDURE get_salary 
    IS 
        salariu employees.salary%TYPE;
    BEGIN
        SELECT salary INTO salariu FROM employees WHERE last_name = v_nume;
        DBMS_OUTPUT.PUT_LINE('Salariul lui ' || v_nume || ' este ' || salariu);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Nu exista angajati cu numele dat'); 
        WHEN TOO_MANY_ROWS THEN  DBMS_OUTPUT.PUT_LINE('Exista mai multi angajati '||'cu numele dat');   
        WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Alta eroare!'); 
    END get_salary;
BEGIN
    get_salary;
END;
/

-- PROCEDURA LOCALA CU PARAMETRI
DECLARE
    v_nume employees.last_name%TYPE := Initcap('&p_nume');
    v_salariu employees.salary%TYPE;
    PROCEDURE get_salary (salariu OUT employees.salary%TYPE)
    IS
    BEGIN
        SELECT salary INTO salariu FROM employees WHERE last_name = v_nume;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
           RAISE_APPLICATION_ERROR(-20000,'Nu exista angajati cu numele dat');
        WHEN TOO_MANY_ROWS THEN
           RAISE_APPLICATION_ERROR(-20001,'Exista mai multi angajati cu numele dat');
        WHEN OTHERS THEN
           RAISE_APPLICATION_ERROR(-20002,'Alta eroare!'); 
    END get_salary;
BEGIN
    get_salary(v_salariu);
    DBMS_OUTPUT.PUT_LINE('Salariul lui ' || v_nume || ' este ' || v_salariu);
END;
/

-- Exe 4 (1 rezolvat cu PROCEDURA STOCATA)
CREATE OR REPLACE PROCEDURE proc_get_salary_nic (v_nume employees.last_name%TYPE)
    IS 
        salariu employees.salary%TYPE;
BEGIN
    SELECT salary INTO salariu FROM employees WHERE last_name = v_nume;
    DBMS_OUTPUT.PUT_LINE('Salariul lui ' || v_nume || ' este ' || salariu);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20000,'Nu exista angajati cu numele dat');
    WHEN TOO_MANY_ROWS THEN
        RAISE_APPLICATION_ERROR(-20001,'Exista mai multi angajati cu numele dat');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002,'Alta eroare!'); 
END proc_get_salary_nic;
/

-- metode apelare
-- Bloc PLSQL
DECLARE
    v_nume employees.last_name%TYPE := Initcap('&p_nume');
BEGIN
    proc_get_salary_nic(v_nume);
END;
/

BEGIN
  proc_get_salary_nic('Bell');
END;
/

-- SQL*PLUS
EXECUTE proc_get_salary_nic('Bell');
EXECUTE proc_get_salary_nic('King');
EXECUTE proc_get_salary_nic('Kimball');

-- varianta 2
CREATE OR REPLACE PROCEDURE 
       proc_get_salary_nic (v_nume IN employees.last_name%TYPE,
                            salariu OUT employees.salary%type) 
  IS 
  BEGIN
    SELECT salary INTO salariu FROM   employees WHERE  last_name = v_nume;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RAISE_APPLICATION_ERROR(-20000, 'Nu exista angajati cu numele dat');
    WHEN TOO_MANY_ROWS THEN
       RAISE_APPLICATION_ERROR(-20001, 'Exista mai multi angajati cu numele dat');
    WHEN OTHERS THEN
       RAISE_APPLICATION_ERROR(-20002,'Alta eroare!');
  END proc_get_salary_nic;
/

-- metode apelare
-- Bloc PLSQL
DECLARE
   v_salariu employees.salary%type;
BEGIN
  proc_get_salary_nic('Bell',v_salariu);
  DBMS_OUTPUT.PUT_LINE('Salariul este '|| v_salariu);
END;
/

-- SQL*PLUS
VARIABLE v_sal NUMBER
EXECUTE proc_get_salary_nic ('Bell',:v_sal)
PRINT v_sal


-- Exe 5
VARIABLE ang_man employees.employee_id%TYPE -- NUMBER 
BEGIN  
:ang_man:=200; 
END; 
/ 
CREATE OR REPLACE 
    PROCEDURE proc_get_manager (cod IN OUT employees.employee_id%TYPE) IS
BEGIN
    SELECT manager_id INTO cod FROM employees WHERE employee_id = cod;
END proc_get_manager;
/

EXECUTE proc_get_manager(:ang_man)
PRINT ang_man

-- Exe 6
DECLARE
    nume employees.last_name%TYPE;
    
    PROCEDURE local_proc_get_emp (
                        rezultat OUT employees.last_name%TYPE,
                        comision IN employees.commission_pct%TYPE DEFAULT NULL,
                        cod IN employees.employee_id%TYPE DEFAULT NULL )
    IS
    BEGIN
        IF comision IS NOT NULL THEN
            SELECT last_name INTO rezultat 
            FROM employees
            WHERE commission_pct = comision;
            DBMS_OUTPUT.PUT_LINE('numele salariatului care are comisionul '||comision||' este '||rezultat);
        ELSE 
            SELECT last_name INTO rezultat 
            FROM employees
            WHERE employee_id = cod;
               DBMS_OUTPUT.PUT_LINE('numele salariatului avand codul '||cod ||' este '||rezultat); 
        END IF;
    END local_proc_get_emp;
BEGIN
    local_proc_get_emp(nume, 0.4);
    local_proc_get_emp(nume,cod=>200);
END;
/

-- Exe 7 (OVERLOAD)
select AVG(salary)
FROM employees;
SELECT SUM(salary)/COUNT(*)
FROM employees;

SELECT SUM(salary)
FROM employees;
SELECT COUNT(employee_id)
FROM employees;

DECLARE
    medie1 NUMBER(10,2);
    medie2 NUMBER(10,2);

    FUNCTION avg_salary (cod_dep departments.department_id%TYPE)
    RETURN NUMBER IS
        salariu_mediu NUMBER(10,2);
        BEGIN
        SELECT AVG(salary) INTO salariu_mediu 
        FROM employees WHERE department_id = cod_dep;
        RETURN salariu_mediu;
    END avg_salary;
    
    FUNCTION avg_salary (cod_dep departments.department_id%TYPE,
                         cod_job jobs.job_id%TYPE)
    RETURN NUMBER IS
        salariu_mediu NUMBER(10,2);
    BEGIN
        SELECT AVG(salary) INTO salariu_mediu 
        FROM employees 
        WHERE department_id = cod_dep AND job_id = cod_job;
        RETURN salariu_mediu;
    END avg_salary;
BEGIN
    medie1 := avg_salary(80);
    DBMS_OUTPUT.PUT_LINE('Media salariilor din departamentul 80'|| ' este ' || medie1);
    medie2 := avg_salary(80,'SA_MAN');
    DBMS_OUTPUT.PUT_LINE('Media salariilor managerilor din'|| ' departamentul 80 este ' || medie2);
END;
/


-- Exe 8 (RECURSIVITATE)
CREATE OR REPLACE 
    FUNCTION factorial_n (n NUMBER) -- DEFAULT: IN
RETURN INTEGER IS
BEGIN
    IF (n = 0) THEN RETURN 1;
    ELSE
        RETURN n*factorial_n(n-1);
    END IF;
END factorial_n;
/

SELECT factorial_n(3) FROM DUAL;
BEGIN
    DBMS_OUTPUT.PUT_LINE(factorial_n(3));
END;
/

-- Exe 9
SELECT last_name, salary FROM employees WHERE salary > (SELECT AVG(salary) FROM employees);

CREATE OR REPLACE 
    FUNCTION get_avg_salary
RETURN NUMBER -- aici doar tipul de date, farqa restrictii
IS
    rezultat NUMBER(10,2);
BEGIN
    SELECT AVG(salary) INTO rezultat FROM employees;
    RETURN rezultat;
END;
/
SELECT last_name, salary FROM employees WHERE salary > get_avg_salary;


-- Ex 1
DROP TABLE info_nic;
CREATE TABLE info_nic (
    utilizator VARCHAR2(20) NOT NULL,
    data Date NOT NULL,
    comanda VARCHAR2(20) NOT NULL,
    nr_linii NUMBER(4),
    eroare varchar2(30)
);

select * from info_nic;

CREATE OR REPLACE FUNCTION get_salary_nic 
    (v_nume IN employees.last_name%TYPE DEFAULT 'Bell')
RETURN NUMBER 
    IS
        salariu employees.salary%TYPE;
        err_msg info_nic.eroare%TYPE;
BEGIN
    SELECT salary INTO salariu
    FROM employees WHERE last_name = v_nume;
--    INSERT INTO info_nic
--    VALUES(user, SYSDATE, 'SELECT', 1, NULL);
    INSERT INTO info_nic VALUES(user, SYSDATE, $$plsql_unit, 1, NULL); -- => COMANDA: GET_SALARY_NIC

    RETURN salariu;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
--        err_msg := sqlerrm;
        INSERT INTO info_nic
        VALUES(user, SYSDATE,'SELECT', 0, 'NU EXISTA ANG');
        COMMIT;
        RAISE_APPLICATION_ERROR(-20000,'Nu exista angajati cu numele dat');
    WHEN TOO_MANY_ROWS THEN
--        err_msg := sqlerrm;
        INSERT INTO info_nic
        VALUES(user, SYSDATE,'SELECT', 0, 'PREA MULTI ANG');
        COMMIT;
        RAISE_APPLICATION_ERROR(-20001,'Exista mai multi angajati cu numele dat');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002,'Alta eroare!'); 
END get_salary_nic;
/


BEGIN
--  DBMS_OUTPUT.PUT_LINE('Salariul este '|| get_salary_nic('Bell'));
--  DBMS_OUTPUT.PUT_LINE('Salariul este '|| get_salary_nic('King'));
  DBMS_OUTPUT.PUT_LINE('Salariul este '|| get_salary_nic('K'));
END;
/

-- Ex 3
select * from job_history ORDER BY employee_id;
select * from employees ORDER BY employee_id;
select DISTINCT job_id, city FROM employees JOIN departments USING (department_id)
                             JOIN locations USING (location_id);
                             
SELECT employee_id 
FROM employees JOIN departments USING (department_id)
               JOIN locations USING (location_id)
WHERE city = 'Seattle';

SELECT employee_id, COUNT(DISTINCT job_id)
FROM job_history
GROUP BY employee_id
HAVING COUNT(DISTINCT job_id) >= 2 AND
    employee_id IN (SELECT employee_id 
FROM employees JOIN departments USING (department_id)
               JOIN locations USING (location_id)
WHERE city = 'Seattle');


CREATE OR REPLACE
    FUNCTION get_nr_emp (oras locations.city%TYPE)
    RETURN NUMBER 
    IS
        err_oras locations.city%TYPE;
        rezultat NUMBER(4);
    BEGIN
        SELECT city INTO err_oras from locations where city = oras;
        SELECT COUNT(*)
        INTO rezultat
        FROM (
            SELECT employee_id, COUNT(DISTINCT job_id) 
            FROM job_history
            GROUP BY employee_id
            HAVING COUNT(DISTINCT job_id) >= 2 AND
                   employee_id IN (
                        SELECT employee_id 
                        FROM employees JOIN departments USING (department_id)
                        JOIN locations USING (location_id)
                        WHERE city = oras)
        );
        IF rezultat = 0 THEN --Hiroshima
            INSERT INTO info_nic VALUES(user, SYSDATE, $$plsql_unit, 0, 'NO_EMP'); -- => COMANDA: GET_SALARY_NIC
            COMMIT;
            RAISE_APPLICATION_ERROR(-20001, 'Niciun angajat nu lucreaza in ascest oras');
        END IF;
        INSERT INTO info_nic VALUES(user, SYSDATE, $$plsql_unit, 0, NULL); -- => COMANDA: GET_SALARY_NIC
        RETURN rezultat;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            INSERT INTO info_nic VALUES(user, SYSDATE, $$plsql_unit, 0, 'NO_CITY'); -- => COMANDA: GET_SALARY_NIC
            COMMIT;
            RAISE_APPLICATION_ERROR(-20000,'Nu exista niciun oras cu numele dat');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20002,'Alta eroare!'); 
    END get_nr_emp;
/

DECLARE
    oras locations.city%TYPE := '&p_oras';
BEGIN
    DBMS_OUTPUT.PUT_LINE(get_nr_emp(oras));
END;
/

rollback;
select * from info_nic;
select city from locations;

-- Ex 4
--drop table qwerty;
--create table qwerty(
--   id int,
--   name varchar2(100),
--   parent_id int
--);
--
--insert all
--into qwerty values( 1, 'Grandfather', null )
--into qwerty values( 2, 'Father', 1 )
--into qwerty values( 3, 'Son', 2 )
--into qwerty values( 4, 'Grandson', 3 )
--select 1234 from dual;
--
--select level, t.*
--from qwerty t
--start with name = 'Grandfather'
--connect by prior id = parent_id;

SELECT employee_id, manager_id
FROM employees;

SELECT employee_id, last_name, manager_id, salary
FROM employees
START WITH manager_id = 100
CONNECT BY PRIOR employee_id =  manager_id;


-- in PL/SQL nu merg folosite colectii de tipuri declarate local
-- functii de genul ROWTYPE sunt de tip PL/SQL si nu merg folosite in afara unui bloc PL/SQL

CREATE OR REPLACE 
    PROCEDURE marire (cod_manager employees.employee_id%TYPE)
IS
    check_err NUMBER;
    CURSOR angajati(cod employees.employee_id%TYPE) IS
        SELECT *
        FROM employees
        START WITH manager_id = cod
        CONNECT BY PRIOR employee_id =  manager_id
        FOR UPDATE NOWAIT;
BEGIN
    select COUNT(*) 
    INTO check_err
    FROM( 
            SELECT employee_id  
            FROM employees 
            WHERE manager_id = cod_manager
        );
    IF check_err = 0 THEN
        INSERT INTO info_nic VALUES(user, SYSDATE, $$plsql_unit, 0, 'NO_MANAGER'); -- => COMANDA: GET_SALARY_NIC
        COMMIT;
        RAISE_APPLICATION_ERROR(-20000,'Nu exista manager cu id-ul dat'); -- INTRA PE RAMURA OTHERS
    END IF;
    FOR employee IN angajati(cod_manager) LOOP
        UPDATE employees
        SET salary = salary*1.1 
        WHERE CURRENT OF angajati;
    END LOOP;
    INSERT INTO info_nic VALUES(user, SYSDATE, $$plsql_unit, CHECK_ERR, NULL); -- => COMANDA: GET_SALARY_NIC
EXCEPTION
--    WHEN NO_DATA_FOUND THEN
    WHEN TOO_MANY_ROWS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Exista mai multi manageri cu id-ul dat');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002,'Alta eroare!');
END marire;
/

DECLARE
    cod employees.employee_id%TYPE := '&manager';
BEGIN
    marire(cod);
END;
/

-- Ex 6
DBMS_OUTPUT.PUT('Nume departament: ');
-- print ziua din sapt cu cele mai multe angajari 
-- persoanele angajate in ziua respectiva: nume, vechime si venit lunar
-- exceptions: intr un dep nu lucreaza nieni
--              intr o zi din sapt nu a fost nimeni angajat
select * from departments;
select employee_id, last_name, hire_date, salary, department_name
from employees RIGHT OUTER JOIN departments USING (department_id)
ORDER BY department_name;


set serveroutput on;
CREATE OR REPLACE PROCEDURE get_hire_data
IS
--    vechime FLOAT;
    TYPE pair IS RECORD (nr NUMBER, zi NUMBER);
    nr_angajari NUMBER;
    max_angajari pair;
    CURSOR dep IS
        SELECT department_id, department_name
        FROM departments;
--    CURSOR ang(dep_id departments.department_id%TYPE) IS
--        SELECT employee_id, last_name, hire_date, salary
--        FROM employees
--        WHERE department_id = dep_id;
    CURSOR angajati_zi(dep_id departments.department_id%TYPE, zi NUMBER) IS
        SELECT employee_id, last_name, hire_date, salary
        from employees RIGHT OUTER JOIN departments USING (department_id)
        where department_id = dep_id AND TO_CHAR(TO_DATE(hire_date), 'D') = zi;
BEGIN
    FOR department in dep LOOP
        DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('NUMELE DEPARTAMENTULUI: ' || department.department_name);
        SELECT COUNT(*) INTO max_angajari.nr FROM employees WHERE department_id = department.department_id;
        IF max_angajari.nr = 0 THEN 
            DBMS_OUTPUT.PUT_LINE('Nu lucreaza nimeni');
        ELSE    
            max_angajari.nr := 0;
            FOR contor IN 1..7 LOOP
                SELECT COUNT(*)
                INTO nr_angajari
                FROM (
                    select employee_id, last_name
                    from employees RIGHT OUTER JOIN departments USING (department_id)
                    where department_name = department.department_name AND
                        TO_CHAR(TO_DATE(hire_date), 'D') = contor
                );
                DBMS_OUTPUT.PUT_LINE('Ziua: ' || contor || '; Nr angajari: ' ||  nr_angajari);
                IF max_angajari.nr < nr_angajari THEN
                    max_angajari.nr := nr_angajari;
                    max_angajari.zi := contor;
                END IF;
            END LOOP;
    
            FOR angajat in angajati_zi(department.department_id, max_angajari.zi) LOOP
    --            vechime := ROUND((SYSDATE-angajat.hire_date)/365.25,2);
                DBMS_OUTPUT.PUT_LINE('Angajatul ' || angajat.last_name || ' lucreaza in companine de ' || ROUND((SYSDATE-angajat.hire_date)/365.25,2) || ' si castiga ' || angajat. salary);
            END LOOP;
        END IF;
    END LOOP;
END get_hire_data;
/

BEGIN
    GET_HIRE_DATA;
END;
/


SELECT TO_CHAR(date '1982-03-09', 'DD-MON-YY') FROM dual; -- 09-mar-82
SELECT TO_CHAR(date '1982-03-09', 'DAY') FROM dual; -- TUESDAY
SELECT TO_CHAR(date '07-JUN-94', 'DD-MON-YY') FROM dual; -- err
SELECT TO_CHAR(TO_DATE('07-JUN-94'), 'DAY') FROM dual; -- TUESDAY
SELECT TO_DATE('07-JUN-94') from dual;
SELECT TO_CHAR(SYSDATE, 'D') FROM dual; -- 7 (sunday = 1)

select employee_id, last_name, hire_date, salary, department_name
from employees RIGHT OUTER JOIN departments USING (department_id)
where department_name = 'Accounting'; 


-- Ex 6
set serveroutput on;
CREATE OR REPLACE PROCEDURE get_hire_data
IS
--    vechime FLOAT;
    TYPE pair IS RECORD (nr NUMBER, zi NUMBER);
    nr_angajari NUMBER;
    max_angajari pair;
    poz NUMBER;
    prev_hire_date employees.hire_date%TYPE := SYSDATE;
    CURSOR dep IS
        SELECT department_id, department_name
        FROM departments;
--    CURSOR ang(dep_id departments.department_id%TYPE) IS
--        SELECT employee_id, last_name, hire_date, salary
--        FROM employees
--        WHERE department_id = dep_id;
    CURSOR angajati_zi(dep_id departments.department_id%TYPE, zi NUMBER) IS
        SELECT employee_id, last_name, hire_date, salary
        from employees RIGHT OUTER JOIN departments USING (department_id)
        where department_id = dep_id AND TO_CHAR(TO_DATE(hire_date), 'D') = zi
        ORDER BY hire_date;
BEGIN
    FOR department in dep LOOP
        DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('NUMELE DEPARTAMENTULUI: ' || department.department_name);
        SELECT COUNT(*) INTO max_angajari.nr FROM employees WHERE department_id = department.department_id;
        IF max_angajari.nr = 0 THEN 
            DBMS_OUTPUT.PUT_LINE('Nu lucreaza nimeni');
        ELSE    
            max_angajari.nr := 0;
            FOR contor IN 1..7 LOOP
                SELECT COUNT(*)
                INTO nr_angajari
                FROM (
                    select employee_id, last_name
                    from employees RIGHT OUTER JOIN departments USING (department_id)
                    where department_name = department.department_name AND
                        TO_CHAR(TO_DATE(hire_date), 'D') = contor
                );
                DBMS_OUTPUT.PUT_LINE('Ziua: ' || contor || '; Nr angajari: ' ||  nr_angajari);
                IF max_angajari.nr < nr_angajari THEN
                    max_angajari.nr := nr_angajari;
                    max_angajari.zi := contor;
                END IF;
            END LOOP;
            
            poz := 0;
            FOR angajat in angajati_zi(department.department_id, max_angajari.zi) LOOP
                IF angajat.hire_date <> prev_hire_date THEN
                    poz := poz + 1;
                    prev_hire_date := angajat.hire_date;
                    DBMS_OUTPUT.PUT_LINE('POZITIA: ' || poz);
                END IF;
--              vechime := ROUND((SYSDATE-angajat.hire_date)/365.25,2);
                DBMS_OUTPUT.PUT_LINE('Angajatul ' || angajat.last_name || ' lucreaza in companine de ' || ROUND((SYSDATE-angajat.hire_date)/365.25,2) || 'ani, de pe data de: ' || angajat.hire_date || ' si castiga ' || angajat. salary);
            END LOOP;
        END IF;
    END LOOP;
END get_hire_data;
/

BEGIN
    GET_HIRE_DATA;
END;
/
