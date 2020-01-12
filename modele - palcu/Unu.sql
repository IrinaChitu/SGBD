set serveroutput on;

CREATE TABLE prezentare (
    cod_pr  NUMBER(3) PRIMARY KEY,
    data    DATE,
    oras    VARCHAR2(20),
    nume    VARCHAR2(20)
);
drop table prezentare;

CREATE TABLE sponsor (
    cod_sponsor     NUMBER(3) PRIMARY KEY,
    nume            VARCHAR2(20),
    info            VARCHAR2(20),
    tara_origine    VARCHAR2(20)
);
drop table sponsor;

CREATE TABLE sustine (
    cod_pr  NUMBER(3),
    cod_sp  NUMBER(3),
    suma    NUMBER(8),
    CONSTRAINT fk_cod_pr FOREIGN KEY (cod_pr) REFERENCES prezentare(cod_pr),
    CONSTRAINT fk_cod_sp FOREIGN KEY (cod_sp) REFERENCES sponsor(cod_sponsor)
);
drop table sustine;

CREATE TABLE vestimentatie (
    cod_vestimentatie  NUMBER(3),
    denumire           VARCHAR2(20),
    valoare            NUMBER(8),
    cod_prezentare     NUMBER(3),
    CONSTRAINT fk_cod_prezentare FOREIGN KEY (cod_prezentare) REFERENCES prezentare(cod_pr)
);
drop table vestimentatie;

insert into prezentare
values(1, sysdate-1, 'Bucuresti', 'prezi1');

insert into prezentare
values(2, sysdate, 'Bucuresti', 'prezi2');

insert into sponsor
values(1, 'Irina', null, 'Romania');

insert into sponsor
values(2, 'Maria', null, 'Romania');

insert into sustine
values(1, 1, 10000);

insert into sustine
values(2, 1, 500);

insert into sustine
values(2, 2, 5100);

insert into vestimentatie
values(1, 'fusta', 3000, 1);

insert into vestimentatie
values(2, 'rochie', 1000, 1);

insert into vestimentatie
values(3, 'bluza', 900, 2);

update vestimentatie
set valoare = 1000
where cod_vestimentatie = 3;

select * from prezentare;
select * from sponsor;
select * from sustine;
select * from vestimentatie;


--  EX 1
CREATE TABLE city_fashion (
    city_name VARCHAR2(20) PRIMARY KEY,
    nr_prezentari NUMBER NOT NULL
);

--  EX 2
CREATE OR REPLACE PROCEDURE get_prezentari_sponsori (an IN VARCHAR2)
IS
    CURSOR prezentari IS
        SELECT nume, cod_pr
        FROM prezentare
        WHERE EXTRACT(YEAR FROM data) = an; -- VEDEM DACA TREB CA PARAM
    CURSOR sponsori(cod prezentare.cod_pr%type) IS
        SELECT sp.nume
        FROM sponsor sp JOIN sustine su ON (su.cod_sp = sp.cod_sponsor)
                        JOIN prezentare pr ON (pr.cod_pr = su.cod_pr)
        WHERE pr.cod_pr = cod;
BEGIN
    FOR prezentare IN prezentari LOOP
        dbms_output.put_line('Prezentare: ' || prezentare.nume || ' sustinuta de: ');
        FOR sponsor IN sponsori(prezentare.cod_pr) LOOP
            dbms_output.put_line(sponsor.nume);
        END LOOP;
    END LOOP;
END get_prezentari_sponsori;
/

BEGIN
    get_prezentari_sponsori('2020');
END;
/

-- EX 3
CREATE OR REPLACE FUNCTION get_latest_prezentare (cod sponsor.cod_sponsor%TYPE)
    RETURN VARCHAR2
IS
    pret vestimentatie.valoare%TYPE;
    CURSOR prezentari IS
        SELECT pr.nume, pr.cod_pr
        FROM sponsor sp JOIN sustine su ON (su.cod_sp = sp.cod_sponsor)
                        JOIN prezentare pr ON (pr.cod_pr = su.cod_pr)
        WHERE sp.cod_sponsor = cod
        ORDER BY pr.nume DESC;
BEGIN
    FOR prez IN prezentari LOOP
        SELECT MIN(valoare) INTO pret
        FROM prezentare p JOIN vestimentatie v ON(p.cod_pr = v.cod_prezentare)
        WHERE cod_pr = prez.cod_pr;
        
        IF pret < 1500 THEN
            RETURN prez.nume;
        END IF;
    END LOOP;
END;
/

BEGIN
    dbms_output.put_line(get_latest_prezentare(1));
END;
/