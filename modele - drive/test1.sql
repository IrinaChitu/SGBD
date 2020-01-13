CREATE TABLE statie (
    cod_statie      NUMBER(3) primary key,
    denumire        VARCHAR2(20),
    nr_angajati     NUMBER(5),
    cod_companie    NUMBER(3),
    capacitate      NUMBER(5),
    oras            VARCHAR2(20)
);

CREATE TABLE produs (
    cod_produs      NUMBER(3) primary key,
    denumire        VARCHAR2(20),
    pret_vanzare    NUMBER(5)
);


CREATE TABLE achizitie (
    cod_st          NUMBER(3),
    cod_prod        NUMBER(3),
    data_achizitie  DATE,
    cantitate       NUMBER(6),
    pret_achizitie  NUMBER(5),
    CONSTRAINT fk_cod_st FOREIGN KEY (cod_st) REFERENCES statie(cod_statie),
    CONSTRAINT fk_cod_prod FOREIGN KEY (cod_prod) REFERENCES produs(cod_produs)
);  


CREATE TABLE companie (
    cod             NUMBER(3) primary key,
    denumire        VARCHAR2(20),
    capital         NUMBER(5),
    presedinte      VARCHAR2(20)
);

insert into companie
values(1, 'Companie 1', 10000, 'Irina');
insert into companie
values(2, 'Companie 2', 1000, 'Maria');

insert into statie
values(1, 'Statie 1.1', 12, 1, 13, 'Bucuresti');
insert into statie
values(2, 'Statie 1.2', 12, 1, 13, 'Bucuresti');
insert into statie
values(3, 'Statie 1.3', 12, 1, 13, 'Bucuresti');
insert into statie
values(4, 'Statie 2.1', 12, 2, 13, 'Bucuresti');
insert into statie
values(5, 'Statie 2.2', 12, 2, 13, 'Bucuresti');

insert into produs
values(1, 'Produs 1', 10);
insert into produs
values(2, 'Produs 2', 20);
insert into produs
values(3, 'Produs 3', 30);
insert into produs
values(4, 'Produs 4', 40);

insert into achizitie
values(1, 1, SYSDATE-11, 20, 9);

insert into achizitie
values(1, 2, SYSDATE-9, 20, 11);

insert into achizitie
values(2, 1, SYSDATE-11, 20, 10);

insert into achizitie
values(4, 3, SYSDATE-11, 20, 20);

SELECT * from statie;
SELECT * from achizitie;
SELECT * from produs;
SELECT * from companie;


drop table companie;
drop table achizitie;
drop table statie;
drop table produs;

-- EX 1 -- COMPANIE 1 STATIE 1.2
--- Q: cum creezi tabel cu mai multe coloane?
DECLARE 
    TYPE tabel_imbricat IS TABLE OF statie%ROWTYPE; 

    rez_statii tabel_imbricat := tabel_imbricat();

    FUNCTION get_statii (codCompanie companie.cod%TYPE)
        RETURN tabel_imbricat
    IS
        rezultat tabel_imbricat := tabel_imbricat();
        CURSOR statii IS
            SELECT s.*
            FROM companie c JOIN statie s ON (c.cod = s.cod_companie)
            WHERE cod = codCompanie;
        last_achizitie achizitie.data_achizitie%TYPE;
        nr_achizitii NUMBER(5);
        contor NUMBER :=0;
    BEGIN
        FOR st IN statii LOOP
--            DBMS_OUTPUT.PUT_LINE(st.denumire);

            SELECT MAX(data_achizitie), COUNT(a.cod_st)
            INTO last_achizitie, nr_achizitii
            FROM statie s JOIN achizitie a ON (s.cod_statie = a.cod_st)
            WHERE s.cod_statie = st.cod_statie;
            
            IF (SYSDATE - last_achizitie > 10) OR (nr_achizitii = 0) THEN
                DBMS_OUTPUT.PUT_LINE(st.denumire);
                rezultat.extend();
                contor := contor+1;
                rezultat(contor) := st;
            END IF;
        END LOOP;
        
        RETURN rezultat;
    END get_statii;
    
BEGIN
    rez_statii := get_statii(1);
END;
/

-- ALTERNATIVA ELEGANTA

SELECT s.*
FROM companie c JOIN statie s ON (c.cod = s.cod_companie)
                JOIN (
                          SELECT max(data_achizitie) latest_achizitie, cod_st
                          FROM achizitie
                          GROUP BY cod_st
                     ) a ON (a.cod_st = s.cod_statie)
WHERE c.cod = 1 AND (sysdate - a.latest_achizitie > 10);

-- EX 2
CREATE OR REPLACE FUNCTION get_cantitate_totala (codProdus NUMBER)
    RETURN NUMBER
IS
--    numeStatie statie.denumire %TYPE;
--    numeOras statie.oras%TYPE;
    cantitateTotala NUMBER(5);

    CURSOR statii IS
        SELECT s.denumire, s.oras, a.cantitate, a.pret_achizitie, p.pret_vanzare
        FROM produs p JOIN achizitie a ON (p.cod_produs = a.cod_prod)
                      JOIN statie s ON (a.cod_st = s.cod_statie)
        WHERE p.cod_produs = codProdus;
BEGIN
    -- pt generare exceptii
    SELECT COUNT(cod_produs) INTO cantitateTotala FROM produs WHERE cod_produs = codProdus;
    IF cantitateTotala = 0 THEN
        -- RAISE NO_DATA_FOUND; ->in ambele cazuri si le catchuiesc daca vreau dupa in exception
        RAISE_APPLICATION_ERROR(-20001, 'Nu exista niciun produs cu codul introdus');
    END IF;
    SELECT COUNT(cod_st) INTO cantitateTotala FROM achizitie WHERE cod_prod = codProdus;
    IF cantitateTotala = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nu exista nicio achizitie a acestui produs');
    END IF;
    SELECT cod_produs INTO cantitateTotala FROM produs WHERE cod_produs = codProdus;
    
    -- rezolvare
    cantitateTotala := 0;
    FOR st IN statii LOOP
        IF st.pret_achizitie < st.pret_vanzare THEN
            DBMS_OUTPUT.PUT_LINE(st.denumire ||' '|| st.oras);
        END IF;
        cantitateTotala := cantitateTotala + st.cantitate;

    END LOOP;
--    DBMS_OUTPUT.PUT_LINE(cantitateTotala);
    RETURN cantitateTotala;
EXCEPTION
    WHEN TOO_MANY_ROWS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Exista mai multe produse cu codul introdus');
    -- cazurile in care nu eixsta codul sau nu e achizitionat de nimeni
            -- => IF deoarece multiple no data found
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(SQLCODE, SQLERRM); -- trimite codul si textul erorii
END;
/

BEGIN 
    DBMS_OUTPUT.PUT_LINE(get_cantitate_totala(4));
END;
/


-- COD PRODUS => denumire, oras statie
-- where PRET_ACHIZITIE < PRET_VANZARE

--SELECT denumire, oras
--FROM produs p JOIN achizitie a ON (p.cod_produs = a.cod_prod)
--              JOIN statie s ON (a.cod_st = s.cod_statie)
--WHERE p.cod_produs = codProdus AND
--          a.pret_achizitie < p.pret_vanzare;
--    
--    
--SELECT SUM(a.cantitate)
--FROM produs p JOIN achizitie a ON (p.cod_produs = a.cod_prod)
--              JOIN statie s ON (a.cod_st = s.cod_statie)
--WHERE p.cod_produs = codProdus;

--SELECT get_cantitate_totala(4) FROM DUAL;


-- EX 3
ALTER TABLE statie
ADD stoc NUMBER DEFAULT 0; -- cantitatea totala de produse achizitionate de fiecare statie

SELECT NVL(SUM(cantitate),0)
FROM statie s JOIN achizitie a ON (s.cod_statie = a.cod_st)
WHERE s.cod_statie = 3;

DECLARE
    quantity NUMBER(6);
--    CURSOR statii IS
--        SELECT cod_statie FROM statie;
BEGIN
     FOR st IN (SELECT cod_statie FROM statie) LOOP
--    FOR st IN statii LOOP
        SELECT nvl(SUM(cantitate),0)
        INTO quantity
        FROM statie s JOIN achizitie a ON (s.cod_statie = a.cod_st)
        WHERE s.cod_statie = st.cod_statie;
        
        UPDATE statie
        SET stoc = quantity
        WHERE st.cod_statie = cod_statie;
    END LOOP;
END;
/


CREATE OR REPLACE TRIGGER actualizeaza_stoc
    AFTER INSERT OR UPDATE OR DELETE OF cod_st, cantitate ON achizitIe
    FOR EACH ROW
BEGIN
    IF INSERTING THEN
        UPDATE statie
        SET stoc = stoc + :NEW.cantitate
        WHERE cod_statie = :NEW.cod_st;
    
    ELSIF UPDATING('cantitate') THEN
        UPDATE statie
        SET stoc = stoc -:OLD.cantitate + :NEW.cantitate
        WHERE cod_statie = :OLD.cod_st; 

    ELSIF UPDATING('cod_st') THEN
        UPDATE statie
        SET stoc = stoc - :OLD.cantitate
        WHERE cod_statie = :OLD.cod_st; 
        
        UPDATE statie
        SET stoc = stoc + :NEW.cantitate
        WHERE cod_statie = :NEW.cod_st; 
    
    ELSIF DELETING THEN
        UPDATE statie
        SET stoc = stoc - :OLD.cantitate
        WHERE cod_statie = :OLD.cod_st; 
    
    END IF;
END;
/

SELECT * FROM statie;

insert into achizitie
values(3, 1, sysdate, 5, 10);

