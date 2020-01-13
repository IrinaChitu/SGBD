--create table personal_nic as select * from personal;
--create table pacienti_nic as select * from pacienti;
--create table trateaza_nic as select * from trateaza;
--create table functii_nic as select * from functii;
--create table specializare_nic as select * from specializare;

select * from personal_teo;
select * from pacienti_teo;
select * from trateaza_teo;
select * from functii_teo;
select * from specializare_teo;

-- EX 1
 CREATE OR REPLACE PACKAGE data_struct
 IS
    TYPE struct_pacient IS RECORD (
        id_pacient        pacienti_teo.id_pacient%TYPE,
        nume              pacienti_teo.nume%TYPE,
        nr_zile_internat  NUMBER(3)
    );
    
    TYPE tabel_imbricat IS TABLE OF struct_pacient;

 END data_struct;
/


CREATE OR REPLACE FUNCTION nic_get_lista_pacienti(cod_angajat NUMBER)
    RETURN data_struct.tabel_imbricat
IS
    rezultat data_struct.tabel_imbricat := data_struct.tabel_imbricat();
    CURSOR pacienti IS
        SELECT p.id_pacient, p.nume,  t.data_externare - t.data_internare
        FROM personal_teo a JOIN trateaza_teo t ON (a.id_salariat = t.id_salariat)
                        JOIN pacienti_teo p ON (t.id_pacient = p.id_pacient)
        WHERE a.id_salariat = cod_angajat;
BEGIN
    SELECT DISTINCT p.id_pacient, p.nume,  t.data_externare - t.data_internare
    BULK COLLECT INTO rezultat
    FROM personal_teo a JOIN trateaza_teo t ON (a.id_salariat = t.id_salariat)
                        JOIN pacienti_teo p ON (t.id_pacient = p.id_pacient)
    WHERE a.id_salariat = cod_angajat;
    
    RETURN rezultat;
END nic_get_lista_pacienti;
/

DECLARE
    rezultat data_struct.tabel_imbricat := data_struct.tabel_imbricat();
BEGIN
    rezultat := nic_get_lista_pacienti(1);
--    rezultat := get_lista_pacienti(2);

    DBMS_OUTPUT.PUT_LINE('Lista de pacienti pentru doctorul cu id-ul 1 este:');

    FOR i IN rezultat.FIRST..rezultat.LAST LOOP
        DBMS_OUTPUT.PUT_LINE(rezultat(i).id_pacient || 'Nume: ' || rezultat(i).nume || '. Numar de zile interat: ' || rezultat(i).nr_zile_internat);

    END LOOP;

END;
/





SELECT distinct p.id_pacient, p.nume,  t.data_externare - t.data_internare
    FROM personal_teo a JOIN trateaza_teo t ON (a.id_salariat = t.id_salariat)
                        JOIN pacienti_teo p ON (t.id_pacient = p.id_pacient)
    WHERE a.id_salariat = 1;










-- EX 2
CREATE OR REPLACE PROCEDURE get_data_function
IS
    suma NUMBER(8);
    nr NUMBER(8);
    medie NUMBER(8);
    nr_pactienti NUMBER(4);
    CURSOR functii IS
        SELECT id_functie ,nume_functie
        FROM functii;
    CURSOS angajati(func_id functii.id_functie%TYPE)
        SELECT id_salariat, nume, salariu
        FROM personal WHERE id_functie = func_id;
BEGIN
    FOR func in functii LOOP
        dbms_output.put_line(func.nume_functie);
        
        SELECT SUM(salariu), COUNT(id_salariat)
        INTO suma, nr
        FROM personal WHERE id_funcie = func.id_functie;
        
        FOR ang IN angajati(func.id_functie) LOOP
            medie := (suma - ang.salariu) / (nr-1);
            IF medie < ang.salariu THEN
                SELECT COUNT(pac.id_pacient)
                INTO nr_pacienti
                FROM personal pers JOIN trateaza t ON (pers.id_salariat = t.id_salariat)
                                   JOIN pacienti pac ON (pac.id_pacient = t.id_pacient)
                WHERE pers.id_salariat = ang.id_salariat;
                
                IF nr_pacienti >= 2 THEN
                    DBMS_OUTPUT.PUT_LINE(ang.nume);
                END IF;
            END IF;
        END LOOP;
    END LOOP;
    
--EXCEPTION
--    WHEN NO_DATA_FOUN THEN
--            RAISE_APPLICATION_ERROR(-20001, ' ');
--    WHEN TOO_MANY_ROWS THEN
END;
/

