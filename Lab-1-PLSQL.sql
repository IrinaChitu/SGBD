-- using HR and Video schemas

-- pentru a putea vizualiza outputul
SET SERVEROUTPUT ON;

-- Ex 1
DECLARE  
    numar number(3) := 100; 
    mesaj1 varchar2(255) := 'text 1';  
    mesaj2 varchar2(255) := 'text 2'; 
BEGIN   
    DECLARE    
        numar number(3) := 1;    
        mesaj1 varchar2(255) := 'text 2';    
        mesaj2 varchar2(255) := 'text 3'; 
    BEGIN    
        numar := numar + 1;    
        mesaj2 := mesaj2 || ' adaugat in sub-bloc';
        DBMS_OUTPUT.PUT_LINE(numar); -- PRINT merge doar cu variabile (tind sa cred)
        DBMS_OUTPUT.PUT_LINE(mesaj1);
        DBMS_OUTPUT.PUT_LINE(mesaj2);
    END;  
    numar := numar + 1;  
    mesaj1 := mesaj1 || ' adaugat un blocul principal';  
    mesaj2 := mesaj2 || ' adaugat in blocul principal';
    DBMS_OUTPUT.PUT_LINE(numar);
    DBMS_OUTPUT.PUT_LINE(mesaj1);
    DBMS_OUTPUT.PUT_LINE(mesaj2);
END;
/
-- a) Valoarea variabilei numar  în subbloc este: 2
-- b) Valoarea variabilei mesaj1  în subbloc este: text 2
-- c) Valoarea variabilei mesaj2  în subbloc este: text 3 adaugat in sub-bloc
-- d) Valoarea variabilei numar în bloc este: 101
-- e) Valoarea variabilei mesaj1 în bloc este: text 1  adaugat un blocul principal
-- f) Valoarea variabilei mesaj2 în bloc este: text 2  adaugat un blocul principal'

-- Ex 2 -- adaptat pe luna curenta (ianuarie)
--------------------- TRYOUTS ---------------------
select extract (month from sysdate-2) from dual;
select extract (day from sysdate) from dual;
SELECT  EXTRACT(DAY FROM last_day(add_months(sysdate, -3))) FROM DUAL;
select last_day(add_months(sysdate, -3)) from dual;
select (add_months(sysdate, -3) -2) from dual;
select trunc(sysdate, 'mm') from dual;
---------------------------------------------------

--- a)
select * from rental;

--SELECT COUNT(*), EXTRACT(DAY FROM book_date)
--FROM RENTAL
--WHERE EXTRACT(MONTH FROM book_date) = 1
--GROUP BY EXTRACT(DAY FROM book_date)
--ORDER BY 2;

with zile as (
                select trunc(sysdate, 'mm') + rownum - 1 zi
                from dual 
                connect by trunc(sysdate, 'mm') + rownum - 1 <= last_day(sysdate)
             )
select z.zi, (select count(*) from rental where to_char(book_date) = to_char(z.zi)) nr_imprumutari
from zile z;

--- b)
DROP TABLE octombrie_nic;

CREATE TABLE OCTOMBRIE_NIC -- IANUARIE_NIC
(id NUMBER, 
 data DATE
);

select * from OCTOMBRIE_NIC; -- IANUARIE_NIC;

DECLARE
    max_day NUMBER(2) := EXTRACT(DAY FROM last_day(add_months(sysdate, -3)));
    today Date :=  last_day(add_months(sysdate, -4)) + 1;
BEGIN
    FOR contor IN 1..max_day LOOP
        INSERT INTO octombrie_nic
        VALUES (contor, today + contor-1);
    END LOOP;
END;
/

--- a) folosindu-ne de b)
SELECT ian.data, (
                        SELECT COUNT(*)
                        FROM rental
                        WHERE TRUNC(book_date) = TO_CHAR(ian.data)
                        -- WHERE EXTRACT(DAY FROM book_date) = EXTRACT(DAY FROM ian.data)
                           -- AND EXTRACT(MONTH FROM book_date) = EXTRACT(MONTH FROM ian.data)
                      ) AS nr
FROM ianuarie_nic ian;

-- Ex 3
select * from member;
select * from RESERVATION;

-- Observatie: Daca folosim JOIN, codul nu va arunca exceptie, deci nu putem trata folosind EXCEPTION
SELECT COUNT(DISTINCT r.title_id)
FROM member m JOIN reservation r ON (m.member_id = r.member_id)
WHERE m.last_name = 'Ngao';
  
DECLARE
    name member.last_name%TYPE := '&p_member';
    id member.member_id%TYPE;
    result NUMBER(3);
BEGIN
    SELECT member_id
    INTO id
    FROM member
    WHERE last_name = name;

    SELECT COUNT(DISTINCT title_id)
    INTO result
    FROM reservation
    WHERE member_id = id;
    
    DBMS_OUTPUT.PUT_LINE(name || ' a imprumutat ' || result);
    EXCEPTION 
        WHEN TOO_MANY_ROWS THEN DBMS_OUTPUT.PUT_LINE('Au fost gasiti mai multi membri cu acest nume.');
        WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Nu a fost gasit niciun membru cu acest nume.');
END;
/

-- Ex 4
--INSERT INTO member VALUES
--(110,'Velasquez','Carmen','283 King Street','Seattle','587-99-6666',TO_DATE('03-MAR-1990','DD-MON-YYYY'));  
DECLARE
    name member.last_name%TYPE := '&p_member';
    id member.member_id%TYPE;
    nr_titles NUMBER(1);
    result NUMBER(3);
BEGIN
    SELECT COUNT(DISTINCT title_id)
    INTO nr_titles
    FROM title;

    SELECT member_id
    INTO id
    FROM member
    WHERE last_name = name;

    SELECT COUNT(DISTINCT title_id)
    INTO result
    FROM reservation
    WHERE member_id = id;
    
    DBMS_OUTPUT.PUT_LINE(name || ' a imprumutat ' || result);
    CASE
        WHEN result >= 0.75*nr_titles THEN DBMS_OUTPUT.PUT_LINE('Categoria 1');
        WHEN result >= 0.5*nr_titles THEN DBMS_OUTPUT.PUT_LINE('Categoria 2');
        WHEN result >= 0.25*nr_titles THEN DBMS_OUTPUT.PUT_LINE('Categoria 3');
        ELSE DBMS_OUTPUT.PUT_LINE('Categoria 4');
    END CASE;
    EXCEPTION 
        WHEN TOO_MANY_ROWS THEN DBMS_OUTPUT.PUT_LINE('Au fost gasiti mai multi membri cu acest nume.');
        WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Nu a fost gasit niciun membru cu acest nume.');
        WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLCODE || ' --- ' || SQLERRM);
END;
/

-- Ex 5
DROP TABLE member_nic;
CREATE TABLE member_nic AS SELECT * FROM member;

ALTER TABLE member_nic
ADD discount NUMBER(2);

SELECT * FROM member_nic;

DECLARE
    id member.member_id%TYPE := '&p_member';
    nr_titles NUMBER(3);
    reservations NUMBER(3);
    discount_category member_nic.discount%TYPE;
BEGIN
    SELECT COUNT(DISTINCT title_id)
    INTO nr_titles
    FROM title;

    SELECT COUNT(*)
    INTO reservations
    FROM reservation
    WHERE member_id = id;

    CASE
        WHEN reservations >= 0.75*nr_titles THEN discount_category := 10;
        WHEN reservations >= 0.5*nr_titles THEN discount_category := 5;
        WHEN reservations >= 0.25*nr_titles THEN discount_category := 3;
        ELSE discount_category := 0;
    END CASE;

    UPDATE member_nic
    SET discount = discount_category
    WHERE member_id = id;
END;
/