SET SERVEROUTPUT ON;
SET VERIFY OFF;

--1
DECLARE
  x      NUMBER(1) := 5;
  y      x%TYPE  := NULL;
BEGIN
  IF x <> y THEN 
      DBMS_OUTPUT.PUT_LINE ('valoare <> null este = true');
    ELSE -- dac? valoarea de adev?r este FALSE sau NULL 
      DBMS_OUTPUT.PUT_LINE ('valoare <> null este != true'); -- CORECT
  END IF;
  
  x := NULL; 
  IF x = y THEN 
       DBMS_OUTPUT.PUT_LINE ('null = null este = true');
    ELSE -- dac? valoarea de adev?r este FALSE sau NULL 
       DBMS_OUTPUT.PUT_LINE ('null = null este != true'); -- CORECT
  END IF;
END;
/

--2
--a
DECLARE
  TYPE emp_record IS RECORD 
        (employee_id employees.employee_id%TYPE, 
         salary employees.salary%TYPE, 
         job_id employees.job_id%TYPE);
  v_ang emp_record;
BEGIN
  v_ang.employee_id:=700;
  v_ang.salary:= 9000;
  v_ang.job_id:='SA_MAN';
  DBMS_OUTPUT.PUT_LINE ('Angajatul cu codul '|| v_ang.employee_id || 
    ' si jobul ' || v_ang.job_id || ' are salariul ' ||  v_ang.salary);
END;
/

--b
DECLARE
  TYPE emp_record IS RECORD 
        (cod employees.employee_id%TYPE, 
         salariu employees.salary%TYPE, 
         job employees.job_id%TYPE);
  v_ang emp_record;
BEGIN
 /********   In loc de ...
 * SELECT employee_id, salary, job_id
 * INTO   v_ang.cod, v_ang.salariu, v_ang.job
 * FROM   employees
 * WHERE  employee_id = 101;
 **********************************************/

 SELECT employee_id, salary, job_id
 INTO   v_ang
 FROM   employees
 WHERE  employee_id = 101;
 DBMS_OUTPUT.PUT_LINE ('Angajatul cu codul '|| v_ang.cod || 
    ' si jobul ' || v_ang.job || ' are salariul ' ||  v_ang.salariu);
END;
/

--c
drop table emp_nic;
create table emp_nic as select * from employees;
select * from emp_nic;

DECLARE
  TYPE emp_record IS RECORD 
        (cod employees.employee_id%TYPE, 
         salariu employees.salary%TYPE, 
         job employees.job_id%TYPE);
  v_ang emp_record;
BEGIN
 DELETE FROM emp_nic
 WHERE employee_id=100
 RETURNING employee_id, salary, job_id INTO v_ang;
 
 DBMS_OUTPUT.PUT_LINE ('Angajatul cu codul '|| v_ang.cod || 
    ' si jobul ' || v_ang.job || ' are salariul ' ||  v_ang.salariu);
END;
/
ROLLBACK;

--3
DECLARE
 v_ang1     employees%ROWTYPE;
 v_ang2     employees%ROWTYPE;
BEGIN
-- sterg angajat 100 si mentin in variabila linia stearsa
   DELETE FROM emp_nic 
   WHERE employee_id = 100 
   RETURNING employee_id, first_name, last_name, email, phone_number,
             hire_date, job_id, salary, commission_pct, manager_id,
             department_id 
   INTO v_ang1;

-- inserez inapoi in tabel linia stearsa
   INSERT INTO emp_nic
   VALUES v_ang1;

-- sterg angajat 101 
   DELETE FROM emp_nic 
   WHERE employee_id = 101;

-- obtin datele din tabelul employees
   SELECT *
   INTO   v_ang2
   FROM   employees
   WHERE  employee_id = 101;

-- inserez o linie oarecare in emp_nic
   INSERT INTO emp_nic
   VALUES(1000,'FN','LN','E',null,sysdate, 'AD_VP',1000, null,100,90);

-- modific linia adaugata anterior cu valorile variabilei v_ang2
   UPDATE emp_nic
   SET    ROW = v_ang2
   WHERE  employee_id = 1000;
 END;
/

--4 (tablouri indexate)
DECLARE
  TYPE tablou_indexat IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  t    tablou_indexat;
BEGIN
-- punctul a
  FOR i IN 1..10 LOOP
    t(i):=i;
  END LOOP;
  DBMS_OUTPUT.PUT('Tabloul are ' || t.COUNT ||' elemente: ');
  FOR i IN t.FIRST..t.LAST LOOP
      DBMS_OUTPUT.PUT(t(i) || ' '); 
  END LOOP;
  DBMS_OUTPUT.NEW_LINE;

-- punctul b
  FOR i IN 1..10 LOOP
    IF i mod 2 = 1 THEN t(i):=null; 
    END IF;
  END LOOP;
  DBMS_OUTPUT.PUT('Tabloul are ' || t.COUNT ||' elemente: ');

  FOR i IN t.FIRST..t.LAST LOOP
      DBMS_OUTPUT.PUT(nvl(t(i), 0) || ' '); 
  END LOOP;
  DBMS_OUTPUT.NEW_LINE;

-- punctul c
  t.DELETE(t.first);
  t.DELETE(5,7);
  t.DELETE(t.last);
  DBMS_OUTPUT.PUT_LINE('Primul element are indicele ' || t.first ||
         ' si valoarea ' || nvl(t(t.first),0));
  DBMS_OUTPUT.PUT_LINE('Ultimul element are indicele ' || t.last ||
         ' si valoarea ' || nvl(t(t.last),0));
  DBMS_OUTPUT.PUT('Tabloul are ' || t.COUNT ||' elemente: ');
  FOR i IN t.FIRST..t.LAST LOOP
     IF t.EXISTS(i) THEN 
        DBMS_OUTPUT.PUT(nvl(t(i), 0)|| ' '); 
     END IF;
  END LOOP;
  DBMS_OUTPUT.NEW_LINE;

-- punctul d
  t.delete;
  DBMS_OUTPUT.PUT_LINE('Tabloul are ' || t.COUNT ||' elemente.');
END;
/

--5
DECLARE
  TYPE tablou_indexat IS TABLE OF emp_nic%ROWTYPE 
                      INDEX BY BINARY_INTEGER;
  t    tablou_indexat;
BEGIN
-- stergere din tabel si salvare in tablou 
   DELETE FROM emp_nic 
   WHERE  ROWNUM<= 2
   RETURNING employee_id, first_name, last_name, email, phone_number,
             hire_date, job_id, salary, commission_pct, manager_id,
             department_id 
   BULK COLLECT INTO t;

--afisare elemente tablou
  DBMS_OUTPUT.PUT_LINE (t(1).employee_id ||' ' || t(1).last_name);
  DBMS_OUTPUT.PUT_LINE (t(2).employee_id ||' ' || t(2).last_name);

--inserare cele 2 linii in tabel
  INSERT INTO emp_nic VALUES t(1);
  INSERT INTO emp_nic VALUES t(2);
  END;
/

--6 (4 rezolvat cu tablouri imbricate)
DECLARE
  TYPE tablou_imbricat IS TABLE OF NUMBER;
  t    tablou_imbricat := tablou_imbricat(); -- constructor
BEGIN
-- punctul a
  FOR i IN 1..10 LOOP
     t.extend; -- atentie!
     t(i):=i;
  END LOOP;
  DBMS_OUTPUT.PUT('Tabloul are ' || t.COUNT ||' elemente: ');
  FOR i IN t.FIRST..t.LAST LOOP
      DBMS_OUTPUT.PUT(t(i) || ' '); 
  END LOOP;
  DBMS_OUTPUT.NEW_LINE;

-- punctul b
  FOR i IN 1..10 LOOP
    IF i mod 2 = 1 THEN t(i):=null; 
    END IF;
  END LOOP;
  DBMS_OUTPUT.PUT('Tabloul are ' || t.COUNT ||' elemente: ');
  FOR i IN t.FIRST..t.LAST LOOP
      DBMS_OUTPUT.PUT(nvl(t(i), 0) || ' '); 
  END LOOP;
  DBMS_OUTPUT.NEW_LINE;

-- punctul c
  t.DELETE(t.first);
  t.DELETE(5,7);
  t.DELETE(t.last);
  DBMS_OUTPUT.PUT_LINE('Primul element are indicele ' || t.first ||
         ' si valoarea ' || nvl(t(t.first),0));
  DBMS_OUTPUT.PUT_LINE('Ultimul element are indicele ' || t.last ||
         ' si valoarea ' || nvl(t(t.last),0));
  DBMS_OUTPUT.PUT('Tabloul are ' || t.COUNT ||' elemente: ');
  FOR i IN t.FIRST..t.LAST LOOP
     IF t.EXISTS(i) THEN 
        DBMS_OUTPUT.PUT('(' || i || ', ' || nvl(t(i), 0) || ') '); 
     END IF;
  END LOOP;
  DBMS_OUTPUT.NEW_LINE;

-- punctul d
  t.delete;
  DBMS_OUTPUT.PUT_LINE('Tabloul are ' || t.COUNT ||' elemente.');
END;
/

--7
DECLARE
  TYPE tablou_imbricat IS TABLE OF CHAR(1);
  t tablou_imbricat := tablou_imbricat('m', 'i', 'n', 'i', 'm');
  i INTEGER;
BEGIN
  i := t.FIRST;
  WHILE i <= t.LAST LOOP
    DBMS_OUTPUT.PUT(t(i));
    i := t.NEXT(i);
  END LOOP;
  DBMS_OUTPUT.NEW_LINE;
  
  i := t.LAST;
  WHILE i >= t.FIRST LOOP
    DBMS_OUTPUT.PUT(t(i));
    i := t.PRIOR(i);

  END LOOP;
  DBMS_OUTPUT.NEW_LINE;

  t.delete(2); 
  t.delete(4);

-- folosind next si prior sarim peste elementele sterse
-- cum nu putem modifica pasul for-ului, vom adapta pt while
  i := t.FIRST;
  WHILE i <= t.LAST LOOP
    DBMS_OUTPUT.PUT(t(i));
    i := t.NEXT(i);
  END LOOP;
  DBMS_OUTPUT.NEW_LINE;
  
  i := t.LAST;
  WHILE i >= t.FIRST LOOP
    DBMS_OUTPUT.PUT(t(i));
    i := t.PRIOR(i);
  END LOOP;
  DBMS_OUTPUT.NEW_LINE;

END;
/

--8 (4 rezolvat cu vectori)
DECLARE
  TYPE vector IS VARRAY(20) OF NUMBER;
  t    vector := vector(); -- constructor
BEGIN
-- punctul a
  FOR i IN 1..10 LOOP
     t.extend;  -- atentie!
     t(i):=i;
  END LOOP;
  DBMS_OUTPUT.PUT('Tabloul are ' || t.COUNT ||' elemente: ');
  FOR i IN t.FIRST..t.LAST LOOP
      DBMS_OUTPUT.PUT(t(i) || ' '); 
  END LOOP;
  DBMS_OUTPUT.NEW_LINE;
-- punctul b
  FOR i IN 1..10 LOOP
    IF i mod 2 = 1 THEN t(i):=null; 
    END IF;
  END LOOP;
  DBMS_OUTPUT.PUT('Tabloul are ' || t.COUNT ||' elemente: ');
  FOR i IN t.FIRST..t.LAST LOOP
      DBMS_OUTPUT.PUT(nvl(t(i), 0) || ' '); 
  END LOOP;
  DBMS_OUTPUT.NEW_LINE;

-- punctul c
-- metodele DELETE(n), DELETE(m,n) nu sunt valabile pentru vectori!!!  
-- din vectori nu se pot sterge elemente individuale!!!

-- punctul d
  t.trim(1);
  DBMS_OUTPUT.PUT('Tabloul are ' || t.COUNT ||' elemente: ');
  FOR i IN t.FIRST..t.LAST LOOP
      DBMS_OUTPUT.PUT(nvl(t(i), 0) || ' '); 
  END LOOP;
  DBMS_OUTPUT.NEW_LINE;
  
  t.trim(2);
  DBMS_OUTPUT.PUT('Tabloul are ' || t.COUNT ||' elemente: ');
  FOR i IN t.FIRST..t.LAST LOOP
      DBMS_OUTPUT.PUT(nvl(t(i), 0) || ' '); 
  END LOOP;
  DBMS_OUTPUT.NEW_LINE;
  t.delete;
  DBMS_OUTPUT.PUT_LINE('Tabloul are ' || t.COUNT ||' elemente.');
END;
/

--9
CREATE OR REPLACE TYPE subordonati_nic AS VARRAY(10) OF NUMBER(4);
/
--drop table manageri_nic;
CREATE TABLE manageri_nic (cod_mgr NUMBER(10),
                           nume VARCHAR2(20),
                           lista subordonati_nic);

DECLARE 
  v_sub   subordonati_nic := subordonati_nic(100,200,300);
  v_lista manageri_nic.lista%TYPE;
BEGIN
  INSERT INTO manageri_nic
  VALUES (1, 'Mgr 1', v_sub);

  INSERT INTO manageri_nic
  VALUES (2, 'Mgr 2', null);
  
  INSERT INTO manageri_nic
  VALUES (3, 'Mgr 3', subordonati_nic(400,500));
  
  SELECT lista
  INTO   v_lista
  FROM   manageri_nic
  WHERE  cod_mgr=1;
  
  FOR j IN v_lista.FIRST..v_lista.LAST loop
       DBMS_OUTPUT.PUT_LINE(v_lista(j));
  END LOOP;
END;
/
SELECT * FROM manageri_nic;

select a.cod_mgr, a.nume, --b.* 
                  column_value
from   manageri_nic a, table(a.lista)(+) b;

-- rezolvare cu tabel imbricat
CREATE OR REPLACE TYPE subordonati_imb_nic AS table OF NUMBER(4);
/

select a.cod_mgr, a.nume, --b.* 
                  column_value
from   manageri_nic a, table(a.lista) b
union all
select a.cod_mgr, a.nume, null 
from   manageri_nic a
--where  a.lista is null;
--where cardinality(cast(a.lista as subordonati_imb_nic))=0;
where cardinality(cast(a.lista as subordonati_imb_nic)) is null;

DROP TABLE  manageri_nic;
DROP TYPE subordonati_nic;
DROP TYPE subordonati_imb_nic;

--10
select * from employees;
select * from emp_test_nic;

CREATE TABLE emp_test_nic AS 
      SELECT employee_id, last_name FROM employees
      WHERE ROWNUM <= 2;
      
CREATE OR REPLACE TYPE tip_telefon_nic IS TABLE OF VARCHAR(12);
/
ALTER TABLE emp_test_nic
ADD (telefon tip_telefon_nic) 
NESTED TABLE telefon STORE AS tabel_telefon_nic;

desc user_tables

select table_name, TABLESPACE_NAME, NUM_ROWS,BLOCKS ,LAST_ANALYZED ,NESTED 
from user_tables
where table_name like '%NIC';

INSERT INTO emp_test_nic
VALUES (500, 'XYZ',tip_telefon_nic('074XXX', '0213XXX', '037XXX'));

update  emp_test_nic
SET telefon = tip_telefon_nic('073XXX', '0214XXX')
WHERE employee_id=500;

SELECT  a.employee_id, a.last_name, b.*
FROM    emp_test_nic a, TABLE (a.telefon)(+) b
ORDER BY 1;

select * from emp_test_nic;

DROP TABLE emp_test_nic;
DROP TYPE  tip_telefon_nic;

--11
--Varianta 1
DECLARE
  TYPE tip_cod IS VARRAY(5) OF NUMBER(3);
  coduri tip_cod := tip_cod(205,206); 
BEGIN
  FOR i IN coduri.FIRST..coduri.LAST  LOOP
    DELETE FROM emp_nic
    WHERE  employee_id = coduri(i);
  END LOOP;
END; 
/
SELECT employee_id FROM emp_nic;
ROLLBACK;

--Varianta 2
DECLARE
  TYPE tip_cod IS VARRAY(20) OF NUMBER;
  coduri tip_cod := tip_cod(205,206);
BEGIN
-- FORALL permite ca toate liniile unei colec?ii s? fie transferate simultan printr-o singur? opera?ie. Procedeul este numit bulk bind
  FORALL i IN coduri.FIRST..coduri.LAST
    DELETE FROM emp_nic
    WHERE  employee_id = coduri (i);
END;
/
SELECT employee_id FROM emp_nic;
ROLLBACK;

--
DECLARE
  TYPE tip_cod IS VARRAY(5) OF NUMBER(3);
  coduri tip_cod := tip_cod(205,206,201,100,207);
  start_s pls_integer;
  start_ms timestamp;
  elapsed_s number;
  elapsed_ms interval day to second;
  
BEGIN
  start_s := dbms_utility.get_time;
  start_ms := localtimestamp;
  FOR i IN coduri.FIRST..coduri.LAST  LOOP
    DELETE FROM emp_nic
    WHERE  employee_id = coduri (i);
  END LOOP;
  dbms_output.put_line('FOR durata s:='||(dbms_utility.get_time-start_s)/100);
  dbms_output.put_line('FOR durata ms:='||extract (second from(localtimestamp-start_ms))*1000);
  rollback;
  
  start_s := dbms_utility.get_time;
  start_ms := localtimestamp;
  FORALL i IN coduri.FIRST..coduri.LAST
    DELETE FROM emp_nic
    WHERE  employee_id = coduri (i);
  dbms_output.put_line('FORALL durata s:='||(dbms_utility.get_time-start_s)/100);
  dbms_output.put_line('FORALL durata ms:='||extract (second from(localtimestamp-start_ms))*1000);
  rollback;
  
  
END; 
/


