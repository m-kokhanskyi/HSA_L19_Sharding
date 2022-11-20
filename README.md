> Шардінг

```/bin/bash init.sh```

Insert 1mln

``php test.php``

Time: 2281sec

> Без шардінгу

```docker exec -it postgresql_b1_l19 psql -d postgres -U postgres -c "CREATE TABLE IF NOT EXISTS books (id serial not null primary key, category_id int not null, CONSTRAINT category_id_check CHECK (category_id = 1), author character varying not null, title character varying not null, year int not null)"```

Insert 1mln

``php test.php``

Time: 2341sec

