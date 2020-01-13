SET SERVEROUTPUT ON;

create table firma_producatoare_teo (
    id_firma_producatoare           NUMBER PRIMARY KEY,
    CUI                             VARCHAR2(35),
    nume                            VARCHAR2(35),
    telefon                         VARCHAR2(35),
    adresa                          VARCHAR2(35),
    website                         VARCHAR2(35)
);

create table medicament_teo (
    id_medicament                   NUMBER PRIMARY KEY,
    nume                            VARCHAR2(35),
    concentratie                    NUMBER(8, 2),
    forma_farmaceutica              VARCHAR2(35),
    prospect                        VARCHAR2(35)
);

create table substanta_activa_teo (
    id_substanta_activa             NUMBER PRIMARY KEY,
    nume                            VARCHAR2(35),
    grupa                           VARCHAR2(35),
    indicatie_terapeutica           VARCHAR2(35)
);

create table lot_fabricatie_teo (
    id_lot_fabricatie               NUMBER PRIMARY KEY,
    data_fabricatie                 DATE,
    valabilitate                    DATE,
    nr_bucati                       NUMBER,
    cod_firma_producatoare          NUMBER,
    cod_medicament                  NUMBER
);

create table compozitie_teo (
    id_compozitie                   NUMBER PRIMARY KEY,
    cod_medicament                  NUMBER,
    cod_substanta_activa            NUMBER,
    gramaj_per_bucata               NUMBER
);

insert into firma_producatoare_teo
values (1, 'RO123', 'N1', '01234', 'GV', 'www.sgbd.com');
insert into firma_producatoare_teo
values (2, 'RO124', 'N2', '01235', 'GVG', 'www.sgbd1.com');
insert into firma_producatoare_teo
values (3, 'RO125', 'N3', '01236', 'GVGV', 'www.sgbd2.com');

insert into medicament_teo
values (1, 'M1', 0.1, 'FF1', 'P1');
insert into medicament_teo
values (2, 'M2', 0.2, 'FF2', 'P2');
insert into medicament_teo
values (3, 'M3', 0.5, 'FF3', 'P3');
insert into medicament_teo
values (4, 'M4', 0.6, 'FF4', 'P4');

insert into substanta_activa_teo
values (1, 'SA1', 'G1', 'I1');
insert into substanta_activa_teo
values (2, 'SA2', 'G2', 'I2');
insert into substanta_activa_teo
values (3, 'SA3', 'G1', 'I3');
insert into substanta_activa_teo
values (4, 'Ketoprofenum', 'G2', 'I4');

insert into lot_fabricatie_teo
values (1, SYSDATE - 10, SYSDATE, 100, 1, 1);
insert into lot_fabricatie_teo
values (2, SYSDATE - 9, SYSDATE, 101, 2, 2);
insert into lot_fabricatie_teo
values (3, SYSDATE - 5, SYSDATE, 102, 3, 3);

insert into compozitie_teo
values (1, 1, 1, 3);
insert into compozitie_teo
values (2, 2, 1, 4);
insert into compozitie_teo
values (3, 3, 2, 5);
insert into compozitie_teo
values (4, 4, 4, 6);

drop table firma_producatoare_teo;
drop table medicament_teo;
drop table substanta_activa_teo;
drop table lot_fabricatie_teo;
drop table compozitie_teo;

select * from firma_producatoare_teo;
select * from medicament_teo;
select * from substanta_activa_teo;
select * from lot_fabricatie_teo;
select * from compozitie_teo;

-- Ex 1
CREATE OR REPLACE PROCEDURE get_info_subst(cod NUMBER) --subtanta_activa.id_subtanta_activa%type)
IS
    nume_subst VARCHAR2(20);
    grupa_subst VARCHAR2(20);
    CURSOR medicamente IS
        SELECT m.nume, m.concentratie --  sa.nume, sa.grupa, 
        FROM substanta_activa_teo sa JOIN compozitie_TEO c ON (sa.id_substanta_activa = c.cod_substanta_activa)
                                JOIN medicament_TEO m ON (m.id_medicament = c.cod_medicament)
        WHERE sa.id_substanta_activa = cod;
BEGIN
    SELECT nume, grupa INTO nume_subst, grupa_subst FROM substanta_activa_teo WHERE substanta_activa_teo.id_substanta_activa = cod;
    DBMS_OUTPUT.PUT_LINE('Despre substanta: ' || nume_subst || ' '|| grupa_subst);

    FOR med IN medicamente LOOP
        DBMS_OUTPUT.PUT_LINE('Despre medicament: ' || med.nume || ' '|| med.concentratie);
    END LOOP;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nu exista nicio substanta activa cu codul intorodus');
    
END;
/

BEGIN
    get_info_subst(5);
END;
/


-- Ex 2
CREATE OR REPLACE TRIGGER check_insert
    BEFORE INSERT ON compozitie_teo
    FOR EACH ROW
DECLARE
    cod_subst NUMBER;
BEGIN
    SELECT id_substanta_activa INTO cod_subst FROM substanta_activa_teo WHERE nume = 'Ketoprofenum'; 
    DBMS_OUTPUT.PUT_LINE(cod_subst);
    IF INSERTING THEN
        IF(:NEW.cod_substanta_activa = cod_subst) THEN
            IF(:NEW.gramaj_per_bucata > 3) THEN
                RAISE_APPLICATION_ERROR(-20001, 'Gramajul introdus nu trebuie sa depaseasca 3');
            END IF;
        END IF;
    END IF;
END check_insert;
/

INSERT INTO compozitie_teo
VALUES(11, 1, 4, 6);

rollback;

DROP TRIGGER check_insert;
