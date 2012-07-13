<?php

if (isset($_POST['next_move'])) {
    $cmd = "./lifter2 " . $_POST['old_map'] . " " . $_POST['next_move'];
    $new_map = shell_exec($cmd);
    $return = array(
        'success'=>1,
        'map'=>urlencode($new_map),
        'command'=>$cmd
    );
    echo json_encode($return);
    exit;
}

if (isset($_GET['map'])) {
    var_dump ($_GET['map']);
    generateMap(urldecode($_GET['map']));
    exit;
}


function generateMap($map_string) {
    $symbol_image_map = array(
        '#' => 'wall.jpg',
        '*' => 'rock.jpg',
        'R' => 'miner.jpg',
        '.' => 'earth.jpg',
        'L' => 'lift_closed.jpg',
        '\\' => 'lambda.jpg',
        ' ' => 'empty.jpg',
        'O' => 'lift_open.jpg'
    );
    //$map_string = str_replace("\n", "|", $map_string);
    $map_array = explode("\n", $map_string);
   // var_dump ($map_array);
    foreach ($map_array as $row) {
        echo "<div class='outer' style='display:block;clear:both' >";
        for ($i = 0; $i < strlen($row); $i++ ) {
            echo "<div class='block' style='float:left;padding:0;margin:0'><img height=60 src='images/" . $symbol_image_map[substr($row,$i, 1)] . "' ></div>";
        }
        echo "</div>";
    }
    echo "<input type='hidden' id='old_map' value='" . urlencode($map_string) . "' />";
}
// lamda miner viewer

$map_string = "
#########
#.*..#\.#
#.\..#\.L
#.R .##.#
#.\  ...#
#..\  ..#
#...\  ##
#....\ \#
#########
";

?>

<html>

<head>

<script src="//ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js" type="text/javascript"></script>

<script>

function up() {
    sendMove('U', $("#old_map").val());
}

function down() {
    sendMove('D', $("#old_map").val());
}

function right() {
    sendMove('R', $("#old_map").val());
}

function left() {
    sendMove('L', $("#old_map").val());
}

function wait() {
    sendMove('W', $("#old_map").val());
}

function abort() {
    sendMove('A');
}

function sendMove(move, map) {
    $.post("viewer.php", {next_move:move, old_map:map},
        function (data) {
            alert(data.map);
            if (data.success == 1) {
                $("#map_container").load("viewer.php?map=" + data.map);
            }
        }, "json");
    return false;
}


</script>


<title>lamda miner viewer</title>
</head>

<body>
<?php



?>

<input id="down" type="button" value="down" onClick="down(); return false;" />
<input id="up" type="button" value="up" onClick="up(); return false;" />
<input id="right" type="button" value="right" onClick="right(); return false;" />
<input id="left" type="button" value="left" onClick="left(); return false;" />
<input id="wait" type="button" value="wait" onClick="wait(); return false;" />
<input id="abort" type="button" value="abort" onClick="abort(); return false;" />

<div id="map_container">
<?php

generateMap($map_string);

?>
</div>
</body>
</html>