<?php

$pdo = new PDO("pgsql:host=postgresql_b1_l19;port=5432;dbname=postgres;", 'postgres', '1234', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

$i    = 0;
$start = microtime(true);
while ($i < 1000000) {
    try {
        echo $i . PHP_EOL;
        $pdo->exec(sprintf(
            "
        INSERT INTO books (id, category_id, author, title, year)
        VALUES ('%s', '%s', '%s', '%s', '%s')",
            $i,
            random_int(1, 2),
            generateRandomString(),
            generateRandomString(),
            [1993, 1677, 3454][array_rand([1993, 1677, 3454])]
        ));
    } catch (Exception $exception) {
        echo $exception->getMessage();
    }

    $i++;
}
$delta = microtime(true) - $start;

echo PHP_EOL . '--------------';
echo PHP_EOL . 'time:' . $delta . PHP_EOL;
function generateRandomString($length = 10) {
    $characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    $charactersLength = strlen($characters);
    $randomString = '';
    for ($i = 0; $i < $length; $i++) {
        $randomString .= $characters[rand(0, $charactersLength - 1)];
    }
    return $randomString;
}