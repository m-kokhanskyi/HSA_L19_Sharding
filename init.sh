#!/bin/bash

docker-compose down -v
rm -rf ./data/*
docker-compose build
docker-compose up -d

sleep 10

echo 'Init shard tables'

docker exec -it postgresql_b2_l19 psql -d postgres -U postgres -c "CREATE TABLE IF NOT EXISTS books (id serial not null primary key, category_id int not null, CONSTRAINT category_id_check CHECK (category_id = 1), author character varying not null, title character varying not null, year int not null)"
docker exec -it postgresql_b3_l19 psql -d postgres -U postgres -c "CREATE TABLE IF NOT EXISTS books (id serial not null primary key, category_id int not null, CONSTRAINT category_id_check CHECK (category_id = 2), author character varying not null, title character varying not null, year int not null)"

docker exec -it postgresql_b2_l19 psql -d postgres -U postgres -c "CREATE INDEX books_category_id_idx ON books USING btree(category_id)"
docker exec -it postgresql_b3_l19 psql -d postgres -U postgres -c "CREATE INDEX books_category_id_idx ON books USING btree(category_id)"

echo 'Finish'

echo 'Init main table'

docker exec -it postgresql_b1_l19 psql -d postgres -U postgres -c "CREATE EXTENSION postgres_fdw;"

docker exec -it postgresql_b1_l19 psql -d postgres -U postgres -c "CREATE SERVER books_1_server FOREIGN DATA WRAPPER postgres_fdw OPTIONS( host 'postgresql_b2_l19', port '5432', dbname 'postgres' );"
docker exec -it postgresql_b1_l19 psql -d postgres -U postgres -c "CREATE SERVER books_2_server FOREIGN DATA WRAPPER postgres_fdw OPTIONS( host 'postgresql_b3_l19', port '5432', dbname 'postgres' );"

docker exec -it postgresql_b1_l19 psql -d postgres -U postgres -c "CREATE USER MAPPING FOR postgres SERVER books_1_server OPTIONS (user 'postgres', password '1234');"
docker exec -it postgresql_b1_l19 psql -d postgres -U postgres -c "CREATE USER MAPPING FOR postgres SERVER books_2_server OPTIONS (user 'postgres', password '1234');"

docker exec -it postgresql_b1_l19 psql -d postgres -U postgres -c "CREATE FOREIGN TABLE books_1 (id SERIAL, category_id int not null, author character varying not null, title character varying not null, year int not null ) SERVER books_1_server OPTIONS (schema_name 'public', table_name 'books');"
docker exec -it postgresql_b1_l19 psql -d postgres -U postgres -c "CREATE FOREIGN TABLE books_2 (id SERIAL, category_id int not null, author character varying not null, title character varying not null, year int not null ) SERVER books_2_server OPTIONS (schema_name 'public', table_name 'books');"

docker exec -it postgresql_b1_l19 psql -d postgres -U postgres -c "CREATE VIEW books AS SELECT * FROM books_1 UNION ALL SELECT * FROM books_2"

docker exec -it postgresql_b1_l19 psql -d postgres -U postgres -c "CREATE RULE books_insert AS ON INSERT TO books DO INSTEAD NOTHING; CREATE RULE books_update AS ON UPDATE TO books DO INSTEAD NOTHING; CREATE RULE books_delete AS ON DELETE TO books DO INSTEAD NOTHING;"
docker exec -it postgresql_b1_l19 psql -d postgres -U postgres -c "CREATE RULE books_insert_to_1 AS ON INSERT TO books WHERE ( category_id = 1 ) DO INSTEAD INSERT INTO books_1 VALUES (NEW.*); CREATE RULE books_insert_to_2 AS ON INSERT TO books WHERE ( category_id = 2 ) DO INSTEAD INSERT INTO books_2 VALUES (NEW.*);"
echo 'Finish'
