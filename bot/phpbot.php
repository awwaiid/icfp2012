#!/usr/bin/php
<?php

$f = fopen('php://stdin', 'r');

// look ahead 25 moves
$move_queue = array();

while ($line = fgets($f)) {
    fwrite (STDERR, $line);
    $dir = shell_exec("lamda-miner/phpbot.php '" . $line . "'");
    fwrite(STDOUT, $dir . "\n");
}