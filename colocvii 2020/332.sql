-- 2:28 - 2:45 (incep inserare date)
-- 4:00
CREATE TABLE expozitie(
    id_expozitie    NUMBER(3) PRIMARY KEY,
    denumire        VARCHAR2(20),
    data_inceput    DATE,
    data_sfarsit    DATE,
    oras            VARCHAR2(20)
);

CREATE TABLE artist(
    id_artist       NUMBER(3) PRIMARY KEY,
    nume            VARCHAR2(20),
    data_nasterii   DATE,
    nationalitate   VARCHAR2(20)
);

CREATE TABLE fotografie(
    id_fotografie   NUMBER(3) PRIMARY KEY,
    titlu           VARCHAR2(20),
    id_artist       NUMBER(3),
    data_crearii    DATE,
    CONSTRAINT fk_iid_artist FOREIGN KEY (id_artist) REFERENCES artist(id_artist)
);

-- cheie primara compusa?
CREATE TABLE expusa(
    id_fotografie   NUMBER(3),
    id_expozitie    NUMBER(3),
    data_inceput    DATE,
    nr_zile         NUMBER(3),
    CONSTRAINT fk_id_fotografie FOREIGN KEY (id_fotografie) REFERENCES fotografie(id_fotografie),
    CONSTRAINT fk_id_expozitie FOREIGN KEY (id_expozitie) REFERENCES expozitie(id_expozitie)
);

insert into artist
values(1, 'Irina', sysdate, 'ro');
insert into artist
values(2, 'Maria', sysdate, 'ro');
insert into artist
values(3, 'Teo', sysdate, 'ro');

insert into fotografie
values(1, 'Titlu 1.1', 1, SYSDATE);
insert into fotografie
values(2, 'Titlu 1.2', 1, SYSDATE);
insert into fotografie
values(3, 'Titlu 1.3', 1, SYSDATE);
insert into fotografie
values(4, 'Titlu 3.1', 3, SYSDATE);
insert into fotografie
values(5, 'Titlu 3.2', 3, SYSDATE);

insert into expozitie
values(1, 'Expo 1', SYSDATE-6, SYSDATE-3, 'Bucuresti');
insert into expozitie
values(2, 'Expo 2', SYSDATE-6, SYSDATE-3, 'Oslo');
insert into expozitie
values(3, 'Expo 2', SYSDATE-6, SYSDATE-3, 'Viena');
insert into expozitie
values(4, 'Expo 2', SYSDATE-6, SYSDATE-3, 'Viena');


insert into expusa
values(1, 1, SYSDATE-4, 1);
insert into expusa
values(2, 2, SYSDATE-4, 1);
insert into expusa
values(3, 2, SYSDATE-4, 1);
insert into expusa
values(4, 1, SYSDATE-4, 1);
insert into expusa
values(5, 1, SYSDATE-4, 1);



drop table expusa;
drop table fotografie;
drop table artist;
drop table expozitie;


-- EX 1
CREATE OR REPLACE TYPE tabel_imbricat IS TABLE OF VARCHAR2(20);
/

CREATE OR REPLACE FUNCTION get_artisti (numeOras VARCHAR2)
    RETURN tablou_imbricat
IS
    id_expo expozitie.id_expozitie%type;
    total_foto number(5);

    rezultat tablou_imbricat := tablou_imbricat(); 
    contor NUMBER(4) := 0;
    
    cursor artisti_expo_foto(id_exp NUMBER) is
        select f.id_artist, count(f.id_fotografie) nr
        from expozitie expo JOIN expusa e on (expo.id_expozitie = e.id_expozitie)
                            JOIN fotografie f on (f.id_fotografie = e.id_fotografie)
        where expo.id_expozitie = id_expo
        group by f.id_artist;   
BEGIN
      -- get expo id
    select id_expozitie
    into id_expo
    from expozitie
    where oras = numeOras;
    
    DBMS_OUTPUT.PUT_LINE('Expo id: ' || id_expo);

    FOR art IN artisti_expo_foto(id_expo) LOOP
        DBMS_OUTPUT.PUT_LINE('Id artist: ' || art.id_artist);
        DBMS_OUTPUT.PUT_LINE('Nr foto: ' || art.nr);

    
        select COUNT(id_fotografie)
        into total_foto
        from expozitie JOIN expusa USING (id_expozitie)
                       JOIN fotografie USING(id_fotografie)
        where  id_artist = art.id_artist
        group by id_artist;
    
        IF art.nr = total_foto THEN
            rezultat.extend();
            contor := contor + 1;
            select nume 
            into rezultat(contor)
            from artist where id_artist = art.id_artist;
            
            DBMS_OUTPUT.PUT_LINE(rezultat(contor));

        END IF;
    END LOOP;
    
    RETURN rezultat;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001,'Nu exista orasul');
    WHEN TOO_MANY_ROWS THEN
        RAISE_APPLICATION_ERROR(-20001,'Exista mai multe expozitii in acelasi oras');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(SQLCODE, SQLERRM);
END get_artisti;
/


--Teo
declare
    rezultat tablou_imbricat := tablou_imbricat(); 
begin
    rezultat := get_artisti('Bucuresti');
end;
/

--nimeni
declare
    rezultat tablou_imbricat := tablou_imbricat(); 
begin
    rezultat := get_artisti('Oslo');
end;
/

--error too_many_rows
declare
    rezultat tablou_imbricat := tablou_imbricat(); 
begin
    rezultat := get_artisti('Viena');
end;
/

-- error no_data_found
declare
    rezultat tablou_imbricat := tablou_imbricat(); 
begin
    rezultat := get_artisti('dfd');
end;
/


-- EX 2
create or replace function get_data_sfarsit(id_expo NUMBER)
    return date
IS
    rezultat date;
begin
    SELECT data_sfarsit 
    into rezultat
    FROM expozitie WHERE id_expozitie = id_expo;
    
    RETURN rezultat;
end;
/

CREATE OR REPLACE TRIGGER modif_expo
    BEFORE UPDATE OR INSERT ON expusa
    FOR EACH ROW
--IS
--    finalizare_expo DATE;
DECLARE 
    final_expo date;
BEGIN
    IF UPDATING THEN
        RAISE_APPLICATION_ERROR(-20000,'Nu este permisa modificarea unei expuneri deja existente');
    ELSIF INSERTING THEN
        SELECT data_sfarsit 
        into final_expo
        FROM expozitie WHERE id_expozitie = :NEW.id_expozitie;
        IF (final_expo < :NEW.data_inceput ) THEN
            RAISE_APPLICATION_ERROR(-20001,'Expozitia s-a incheiat deja');
        END IF;
    END IF;
END;
/


update expusa
set nr_zile = 5;

insert into expusa
values(5, 2, SYSDATE, 1);

DROP TRIGGER modif_expo;
