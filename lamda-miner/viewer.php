<?php

if (isset($_POST['next_move'])) {

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

    $encoded_map = urlencode($map_string);

    $cmd = "";

    $return = array(
        'success'=>1,
        'map'=>$encoded_map
    );
    echo json_encode($return);
    exit;
}

if (isset($_GET['map'])) {
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
    $map_string = str_replace("\n", "|", $map_string);
    $map_array = explode("|", $map_string);
   // var_dump ($map_array);
    foreach ($map_array as $row) {
        echo "<div class='outer' style='display:block;clear:both' >";
        for ($i = 0; $i < strlen($row); $i++ ) {
            echo "<div class='block' style='float:left;padding:0;margin:0'><img height=60 src='images/" . $symbol_image_map[substr($row,$i, 1)] . "' ></div>";
        }
        echo "</div>";
    }
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
    sendMove('U');
}

function down() {
    sendMove('D');
}

function right() {
    sendMove('R');
}

function left() {
    sendMove('L');
}

function wait() {
    sendMove('W');
}

function abort() {
    sendMove('A');
}

function sendMove(move) {
    $.post("viewer.php", {next_move:move},
        function (data) {
            alert (data.map);
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