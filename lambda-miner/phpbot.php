#!/usr/bin/php
<?php
require_once 'lib/World.php';
require_once 'lib/Map.php';
require_once 'lib/WorldFacade.php';
require_once 'lib/MathFacade.php';
require_once 'lib/Logging.php';
require_once 'lib/Position.php';
require_once 'lib/Strategy.php';
require_once 'lib/Lifter.php';
require_once 'lib/Move.php';

// my super cool php bot

// get the world;
$log = new Logging();
// $log->lfile('out.log');
$log->lfile('/dev/null');
$GLOBALS['log'] = $log;
$cmd_log = new Logging();
// $cmd_log->lfile('cmd.log');
$cmd_log->lfile('/dev/null');

if (isset($argv[2])) {
    $f = fopen('php://stdin', 'r');
    while ($line = fgets($f)) {

    }
}

if (isset($argv[1])) {
    $world_json = $argv[1];
    $cmd_log->lwrite($world_json);
}
else {
    $world_json = file_get_contents('default_world.json');
}
$world = new World($world_json);
$strategy = new Strategy($world);
$direction = null;
$GLOBALS['log']->lwrite('**************************');
$GLOBALS['log']->lwrite('Looking for direction');
while (!$direction || !$strategy->move($direction)) {

    $GLOBALS['log']->lwrite('--------------------------');
    $my_position = $world->getRobotLoc();
    $GLOBALS['log']->lwrite('My Position: ' . $my_position);
    $closest_lambda = $strategy->findClosestLamda($my_position);
    $GLOBALS['log']->lwrite('Closest Lamda: ' . $closest_lambda);

    if (is_null($closest_lambda)) {
        $target = WorldFacade::findLift($world->getMap());
        if (!$target) {
            $GLOBALS['log']->lwrite('Aborting due to no lambda or lift targets');
            $direction = 'A';
            continue;
        }
        else {
            $GLOBALS['log']->lwrite('Target is Open Lift!: ' . $target);
        }
    }
    else {
        $target = $closest_lambda;
    }

    $direction = $strategy->findDirectionToTarget($my_position, $target);
    if ($direction) {
        $GLOBALS['log']->lwrite('Got a direction!: ' . $direction);
    }
    else {
        $GLOBALS['log']->lwrite("Could not get a direction :(");
    }
}
