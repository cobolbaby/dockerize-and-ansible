-- FUNCTION: public.find_24point_solutions(integer[])

-- DROP FUNCTION public.find_24point_solutions(integer[]);

CREATE OR REPLACE FUNCTION public.find_24point_solutions(
	elements integer[])
    RETURNS text
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    permutation_row RECORD;
    expression TEXT;
    solution TEXT;
BEGIN
    -- Generate all possible permutations
    FOR permutation_row IN (SELECT * FROM get_permutations(elements, 4)) LOOP
        -- Generate all possible arithmetic expressions
        FOR expression IN
            SELECT
                (permutation_row[1] || op1 || permutation_row[2] || op2 || permutation_row[3] || op3 || permutation_row[4])::TEXT AS expr
            FROM
                (SELECT UNNEST(ARRAY['+', '-', '*', '/']) AS op1) AS ops1,
                (SELECT UNNEST(ARRAY['+', '-', '*', '/']) AS op2) AS ops2,
                (SELECT UNNEST(ARRAY['+', '-', '*', '/']) AS op3) AS ops3
        LOOP
            -- Find a solution that satisfies the condition
            BEGIN
                EXECUTE 'SELECT (' || expression || ')::NUMERIC = 24' INTO solution;
                IF solution THEN
                    RETURN expression;
                END IF;
            EXCEPTION WHEN others THEN
                -- Ignore division by zero errors
                CONTINUE;
            END;
        END LOOP;
    END LOOP;

    RETURN NULL;
END;
$BODY$;

-- FUNCTION: public.get_permutations(integer[], integer)

-- DROP FUNCTION public.get_permutations(integer[], integer);

CREATE OR REPLACE FUNCTION public.get_permutations(
	elements integer[],
	r integer)
    RETURNS SETOF integer[] 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE
    n INT;
    i INT;
BEGIN
    n := array_length(elements, 1);

    IF r > n THEN
        RETURN;
    ELSIF r = 0 THEN
        RETURN NEXT ARRAY[]::INT[]; -- Explicitly cast to the desired type
    ELSE
        FOR i IN 1..n LOOP
            RETURN QUERY
            SELECT ARRAY[elements[i]] || perm
            FROM get_permutations(elements[1:i-1] || elements[i+1:n], r - 1) AS perm;
        END LOOP;
    END IF;

    RETURN;
END;
$BODY$;

-- select * from find_24point_solutions(ARRAY[1, 2, 3, 4, 5, 6 ,7 ,8, 9, 10, 11, 12, 13])
