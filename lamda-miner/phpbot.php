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

if (isset($argv[1])) $world_json = $argv[1];
else {
    $world_json = file_get_contents('default_world.json');
}
$world = new World($world_json);
$strategy = new Strategy($world);
$my_position = $world->getRobotLoc();
$closest_lambda = $strategy->findClosestLamda($my_position);

//$log->lwrite('going ' . $out . ' to (' . $next . ') towards (' . $target_lamda['w'] . ',' . $target_lamda['h'] . ') from (' . $robot_loc['w'] . ',' . $robot_loc['h'] . ')');
$direction = $strategy->findDirectionToTarget($my_position, $closest_lambda);

//determine if direction is useless;
$useful = $strategy->doesDirectionAffectMap($direction);

if (!$useful) {
    // go a different direction
    $direction = $strategy->findDirectionToTarget($my_position, $closest_lambda, $direction);
    $useful = $strategy->doesDirectionAffectMap($direction);
}

if (!$useful) {
    // abort!!
    $direction = 'A';
}


echo $direction;
?>