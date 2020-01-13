--create table personal_nic as select * from personal;
--create table pacienti_nic as select * from pacienti;
--create table trateaza_nic as select * from trateaza;
--create table functii_nic as select * from functii;
--create table specializare_nic as select * from specializare;

select * from personal_nic;
select * from pacienti_nic;
select * from trateaza_nic;
select * from functii_nic;
select * from specializare_nic;



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

