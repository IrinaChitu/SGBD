-- good to read: https://docs.oracle.com/cd/B14117_01/appdev.101/b10807/05_colls.htm#i35815

SET SERVEROUTPUT ON;
SET VERIFY OFF;

-- Ex 1
select * from employees;

SELECT employee_id, salary
FROM (
       SELECT * FROM employees
       WHERE commission_pct IS NULL
       ORDER BY salary
     )
WHERE ROWNUM <=5;

DECLARE
    TYPE vector IS VARRAY(5) OF employees.employee_id%TYPE;
    emp employees%ROWTYPE;
    coduri vector := vector();
BEGIN
    SELECT employee_id
    BULK COLLECT INTO coduri
    FROM (
           SELECT * FROM employees
           WHERE commission_pct IS NULL
           ORDER BY salary
         )
    WHERE ROWNUM <=5;
    
--    FOR contor IN coduri.FIRST..coduri.LAST LOOP
--        DBMS_OUTPUT.PUT_LINE(coduri(contor));
--    END LOOP;
    
    FOR contor IN coduri.FIRST..coduri.LAST LOOP
        SElECT * INTO emp FROM employees
        WHERE employee_id = coduri(contor);
        DBMS_OUTPUT.PUT('Salariatul cu id-ul ' || emp.employee_id || ' avea salariul de ' || emp.salary || 'RON, iar in urma unei mariri, acum il are de ');
        emp.salary := emp.salary + 0.05*emp.salary;
        UPDATE employees
        SET ROW = emp
        WHERE employee_id = emp.employee_id;
        DBMS_OUTPUT.PUT_LINE(emp.salary || 'RON.');
    END LOOP;
    
END;
/
ROLLBACK;

-- Ex 2
drop table excursie_nic;
select * from excursie_nic;

CREATE OR REPLACE TYPE tip_orase_nic IS TABLE OF VARCHAR2(20);
/
CREATE TABLE excursie_nic (cod_excursie NUMBER(4),
                           denumire VARCHAR2(20),
                           orase tip_orase_nic,
                           status VARCHAR(11))
NESTED TABLE orase STORE AS orase_nic;
/

--- a)
INSERT INTO excursie_nic
VALUES (123, 'Circuit Irina', tip_orase_nic('Paris', 'Londra', 'Bucuresti'), 'disponibila');
    
INSERT INTO excursie_nic
VALUES (101, 'Circuit Europa', tip_orase_nic('Paris', 'Viena'), 'anulata');

INSERT INTO excursie_nic
VALUES (138, 'Concerete', tip_orase_nic('Praga', 'Sofia'), 'disponibila');
    
INSERT INTO excursie_nic
VALUES (145, 'Alta excursie', tip_orase_nic(), 'disponibila');
    
INSERT INTO excursie_nic
VALUES (151, 'circuit inchis', tip_orase_nic('Paris', 'Edinburgh', 'Manchester'), 'disponibila');

-- se actualizeaza automat la fiecare rulare
CREATE SEQUENCE seq_nic;
INSERT INTO excursie_nic
VALUES (seq_nic.NEXTVAL, 'E' || seq_nic.CURRVAL, tip_orase_nic('Bucuresti','Buzau','Focsani'),'disponibila');

--- b)
insert into table(select orase
                  from excursie_nic
                  where cod_excursie = 2)
values ('oras_nou');

update table(select orase
                  from excursie_nic
                  where cod_excursie = 2)
set column_value = 'alt_oras'
where column_value = 'oras_nou';


delete from table(select orase
             from excursie_nic
             where cod_excursie = 2)
where column_value = 'alt_oras';

-- SAU

DECLARE
    spec_excursie excursie_nic%ROWTYPE;
    temp_oras VARCHAR2(20);
    contor NUMBER(5);
    TYPE pair IS RECORD (indice NUMBER(5), nume VARCHAR2(20));
    oras1 pair;
    oras2 pair;
BEGIN
    SELECT *
    INTO spec_excursie
    FROM excursie_nic
    WHERE cod_excursie = '&p_cod';
    
    -- adauga la final
    spec_excursie.orase.EXTEND;
    contor := spec_excursie.orase.LAST;
    spec_excursie.orase(contor) := 'Munchen';
    DBMS_OUTPUT.PUT_LINE('Orasul Munchen a fost adaugat la final');


    -- adauga al doilea element
    spec_excursie.orase.EXTEND;
    contor := spec_excursie.orase.LAST;
    WHILE contor >= 2 LOOP
        spec_excursie.orase(contor) := spec_excursie.orase(contor-1);
        contor := spec_excursie.orase.PRIOR(contor);
    END LOOP;
    spec_excursie.orase(2) := 'Oslo';
    DBMS_OUTPUT.PUT_LINE('Orasul Oslo a fost adaugat al doilea');

    
    -- switch la 2 elemente
    oras1.nume := '&switch_oras1';
    oras2.nume := '&switch_oras2';
    contor := spec_excursie.orase.FIRST;
    WHILE contor <= spec_excursie.orase.LAST LOOP
        IF spec_excursie.orase(contor) = oras1.nume THEN
            oras1.indice := contor;
        ELSIF spec_excursie.orase(contor) = oras2.nume THEN
            oras2.indice := contor;
        END IF;
        contor := spec_excursie.orase.NEXT(contor);
    END LOOP;
    temp_oras := spec_excursie.orase(oras1.indice);
    spec_excursie.orase(oras1.indice) := spec_excursie.orase(oras2.indice);
    spec_excursie.orase(oras2.indice) := temp_oras;
    DBMS_OUTPUT.PUT_LINE('Orasele ' || oras1.nume || ' si ' || oras2.nume || ' au fost inversate.');

    
    -- elimina un oras
    contor := spec_excursie.orase.FIRST;
    oras1.nume := '&oras_de_sters';
    WHILE contor <= spec_excursie.orase.LAST LOOP
        IF spec_excursie.orase(contor) = oras1.nume THEN
            spec_excursie.orase.DELETE(contor);
            DBMS_OUTPUT.PUT_LINE('Orasul ' || oras1.nume || ' a fost sters.');

        END IF;
        contor := spec_excursie.orase.NEXT(contor);
    END LOOP;
    
    UPDATE excursie_nic
    SET ROW = spec_excursie
    WHERE cod_excursie = spec_excursie.cod_excursie;
END;
/

--- c)
select a.cod_excursie, a.denumire, nvl(CARDINALITY(a.orase), 0) numar_orase, a.orase
from excursie_nic a;

select a.cod_excursie, a.denumire, nvl(cardinality(a.orase), 0) numar_orase, column_value oras
from excursie_nic a, table(a.orase)(+) b;

-- SAU

DECLARE
    orase_vizitate excursie_nic.orase%TYPE;
    contor NUMBER(3);
BEGIN
    SELECT orase
    INTO orase_vizitate
    FROM excursie_nic
    WHERE cod_excursie = '&cod';
    
    DBMS_OUTPUT.PUT('In lista sunt '|| orase_vizitate.COUNT() || ' orase de vizitat, si anume: ');
    contor := orase_vizitate.FIRST;
    WHILE contor <= orase_vizitate.LAST LOOP
        DBMS_OUTPUT.PUT(orase_vizitate(contor)|| ' ');
        contor := orase_vizitate.NEXT(contor);
    END LOOP;
    DBMS_OUTPUT.NEW_LINE;
    
END;
/

--- d)
-- SELECT min(nvl(cardinality(orase), 0)) from excursie_nic;
SELECT a.cod_excursie, a.denumire, column_value oras
FROM excursie_nic a, TABLE(a.orase)(+) b
WHERE NVL(CARDINALITY(orase), 0) <> (SELECT MIN(NVL(CARDINALITY(orase), 0)) FROM excursie_nic);


DECLARE
    TYPE tabel_excursii IS TABLE OF excursie_nic%ROWTYPE;
    lista_excursii tabel_excursii;
    contor NUMBER(5);
BEGIN
    SELECT * BULK COLLECT INTO lista_excursii FROM excursie_nic;
    
    FOR i IN 1..lista_excursii.COUNT LOOP
        DBMS_OUTPUT.PUT('Excursia cu id-ul: ' || lista_excursii(i).cod_excursie || ' include urmatoarele orase: ');
        contor := lista_excursii(i).orase.FIRST;
        WHILE contor <= lista_excursii(i).orase.LAST LOOP
            DBMS_OUTPUT.PUT(lista_excursii(i).orase(contor)|| ' ');
            contor := lista_excursii(i).orase.NEXT(contor);
        END LOOP;
        DBMS_OUTPUT.NEW_LINE;
    END LOOP;
END;
/

--- e)
DECLARE
    TYPE tabel_excursii IS TABLE OF excursie_nic%ROWTYPE;
    lista_excursii tabel_excursii;
    excursie excursie_nic%ROWTYPE;
    contor NUMBER(5);
    minim NUMBER(3) := 900;

BEGIN
    SELECT * BULK COLLECT INTO lista_excursii FROM excursie_nic;
    
    FOR i IN 1..lista_excursii.COUNT LOOP
        IF minim > lista_excursii(i).orase.COUNT THEN
            minim := lista_excursii(i).orase.COUNT;
        END IF;
    END LOOP;
    
    FOR i IN 1..lista_excursii.COUNT LOOP
        IF minim = lista_excursii(i).orase.COUNT THEN
            SELECT * INTO excursie FROM excursie_nic WHERE cod_excursie = lista_excursii(i).cod_excursie;
            excursie.status := 'anulata';
            UPDATE excursie_nic SET ROW = excursie WHERE cod_excursie = lista_excursii(i).cod_excursie;
            DBMS_OUTPUT.PUT_LINE('Excursia cu id-ul ' || lista_excursii(i).cod_excursie || ' care include ' || minim || ' tari de vizitat a fost anulata.'); 
        END IF;    
    END LOOP;

END;
/

select * from excursie_nic;


