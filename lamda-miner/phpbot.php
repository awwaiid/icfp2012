#!/usr/bin/php
<?php
require_once 'lib/World.php';
require_once 'lib/Map.php';
require_once 'lib/WorldFacade.php';
require_once 'lib/MathFacade.php';
require_once 'lib/Logging.php';

// my super cool php bot

// get the world;
$log = new Logging();
$log->lfile('out.log');

if (isset($argv[1])) $world_json = $argv[1];
else {
    $world_json = '{"waterproof_step":0,"waterproof":10,"bonus_score":0,"move_count":0,"lambda_remain":3,"partial_score":0,"score":0,"water":0,"map":[["#","#","#","#","#","#"],["#","."," ","*","R","#"],["#"," "," ","\\\",".","#"],["#","\\\"," ","*"," ","#"],["L"," "," ",".","\\\","#"],["#","#","#","#","#","#"]],"flooding":0,"flooding_step":0,"robot_loc":[4,4],"lambda_count":0}';
}
$world = new World($world_json);

$lamdas = WorldFacade::findLambdas($world->getMap());
$robot_loc = WorldFacade::findMiner($world->getMap());

$least_dist = null;
$target_lamda = null;
foreach ($lamdas as $l) {
    $d = MathFacade::findDistanceBetweenTwoPoints($robot_loc, $l);
    if (!$least_dist || $d < $least_dist) {
        $least_dist = $d;
        $target_lamda = $l;
    }
}

$diff_in_height = abs($target_lamda['h'] - $robot_loc['h']);
$diff_in_width = abs($target_lamda['w'] - $robot_loc['w']);

if ($diff_in_height > $diff_in_width) {
    // go vertical
    if ($target_lamda['h'] > $robot_loc['h']) {
        $out = 'U';
        $next = $robot_loc['w'] . ',' . ($robot_loc['h'] + 1);
    }
    else {
        $out = 'D';
        $next = $robot_loc['w'] . ',' . ($robot_loc['h'] - 1);
    }
}
else if ($diff_in_height == $diff_in_width) {
    // compare options
    $ver = ($target_lamda['h'] > $robot_loc['h'])
        ? WorldFacade::whatIsAt($world->getMap(), array('w'=>$robot_loc['w'], 'h'=>$robot_loc['h'] + 1))
        : WorldFacade::whatIsAt($world->getMap(), array('w'=>$robot_loc['w'], 'h'=>$robot_loc['h'] - 1));
    $hor = ($target_lamda['w'] > $robot_loc['w'])
        ? WorldFacade::whatIsAt($world->getMap(), array('w'=>$robot_loc['w'] + 1, 'h'=>$robot_loc['h']))
        : WorldFacade::whatIsAt($world->getMap(), array('w'=>$robot_loc['w'] - 1, 'h'=>$robot_loc['h']));

    $best = compare($ver, $hor);
    if ($best == $ver) {
        if ($target_lamda['h'] > $robot_loc['h']) {
            $out = 'U';
            $next = $robot_loc['w'] . ',' . ($robot_loc['h'] + 1);
        }
        else {
            $out = 'D';
            $next = $robot_loc['w'] . ',' . ($robot_loc['h'] - 1);
        }
    }
    if ($best == $hor) {
        if ($target_lamda['w'] > $robot_loc['w']) {
            $out = 'R';
            $next = ($robot_loc['w'] + 1) . ',' . $robot_loc['h'];
        }
        else {
            $out = 'L';
            $next = ($robot_loc['w'] - 1) . ',' . $robot_loc['h'];
        }
    }
}

else {
    // go horizontal
    if ($target_lamda['w'] > $robot_loc['w']) {
        $out = 'R';
        $next = ($robot_loc['w'] + 1) . ',' . $robot_loc['h'];
    }
    else {
        $out = 'L';
        $next = ($robot_loc['w'] - 1) . ',' . $robot_loc['h'];
    }
}
$log->lwrite('going ' . $out . ' to (' . $next . ') towards (' . $target_lamda['w'] . ',' . $target_lamda['h'] . ') from (' . $robot_loc['w'] . ',' . $robot_loc['h'] . ')');

echo $out;

function compare($a,$b) {
    if ($a == ' ') return $a;
    if ($b == ' ') return $b;
    if ($a == '.') return $a;
    if ($b == '.') return $b;
    return $a;
}

?>