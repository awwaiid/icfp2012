#!/usr/bin/php
<?php
require_once 'lib/World.php';
require_once 'lib/Map.php';
require_once 'lib/WorldFacade.php';
require_once 'lib/MathFacade.php';
require_once 'lib/Logging.php';
require_once 'lib/Position.php';
require_once 'lib/Strategy.php';

// my super cool php bot

// get the world;
$log = new Logging();
$log->lfile('out.log');
$GLOBALS['log'] = $log;
$cmd_log = new Logging();
$cmd_log->lfile('cmd.log');

if (isset($argv[1])) {
    $world_json = $argv[1];
    $cmd_log->lwrite($world_json);
}
else {
    $world_json = file_get_contents('default_world.json');
}
$world = new World($world_json);
$strategy = new Strategy($world);
$my_position = $world->getRobotLoc();
$closest_lambda = $strategy->findClosestLamda($my_position);

if (is_null($closest_lambda)) {
    $target = WorldFacade::findLift($world->getMap());
    if (!$target) {
        echo 'A';
        exit;
    }
}
else {
    $target = $closest_lambda;
}

$direction = $strategy->findDirectionToTarget($my_position, $target);

//determine if direction is useless;
$useful = $strategy->doesDirectionAffectMap($direction);

if (!$useful) {
    // go a different direction
    $direction = $strategy->findDirectionToTarget($my_position, $target, $direction);
    $useful = $strategy->doesDirectionAffectMap($direction);
}

if (!$useful) {
    // abort!!
    $direction = 'A';
}

echo $direction;
?>