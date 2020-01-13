/*
    Link la fisier: http://193.226.51.37/down/SGBD/test_plsql_1.pdf
*/

/* Schemele relaţionale ale modelului folosit sunt:
 STATIE(cod_statie, denumire,nr_angajati, cod_companie, capacitate, oras)
 ACHIZITIE (cod_st, cod_prod, data_achizitie, cantitate, pret_achizitie)
 PRODUS (cod_produs, denumire, pret_vanzare)
 COMPANIE (cod, denumire, capital, presedinte)  */

/* 1. Subprogram care primeşte ca parametru un cod de companie şi întoarce lista staţiilor
companiei care nu au mai achiziţionat produse în ultimele 10 zile. Apelaţi. (3p) */

DECLARE
    TYPE ANS IS VARRAY(100) OF STATIE%ROWTYPE;
    FUNCTION solve(v_cod_companie IN COMPANIE.COD%TYPE) 
    RETURN ANS 
    IS
        v_raspuns ANS := ANS();
    BEGIN
        SELECT s.* 
        BULK COLLECT INTO v_raspuns
        FROM COMPANIE c
        JOIN STATIE s
            ON s.cod_companie = c.cod
        JOIN (
            SELECT MAX(data_achizitie) data_achizitie, cod_st
            FROM ACHIZITIE
            GROUP BY cod_st
        ) a
            ON s.cod_statie = a.cod_st 
        WHERE
            c.cod = v_cod_companie AND
            a.data_achizitie < (SELECT sysdate - 10 FROM DUAL);
        
        return v_raspuns;
    END;
    
    v_cod_companie  COMPANIE.COD%TYPE := &v_cod_companie;
    v_raspuns       ANS := ANS();
BEGIN
    v_raspuns = solve(v_cod_companie);
    FOR itr IN t.FIRST .. t.LAST LOOP
        DBMS_OUTPUT.PUT_LINE('Statie ' || itr.cod_statie);
    END LOOP;
END;