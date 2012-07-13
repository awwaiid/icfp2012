<?php

if (isset($_POST['next_move'])) {
    $cmd = "./lifter2 " . $_POST['old_map'] . " " . $_POST['next_move'];
    $shell_return = shell_exec($cmd);
    $shell_return_parts = explode("\n\n", $shell_return);
    $generated_map = generateMap($shell_return_parts[0]);
    $generated_state = generateState($shell_return_parts[1]);

    $return = array(
        'success'=>1,
        'state'=>$shell_return_parts[1],
        'generated_map'=>$generated_map,
        'generated_state'=>$generated_state,
        'command'=>$cmd
    );
    echo json_encode($return);
    exit;
}

function generateState($state) {
    $state_parts = json_decode($state);
    $out = "";
    foreach ($state_parts as $k=>$r) {
        if (!in_array($k, array('score','lamda_count','robot_loc','lambda_remain','ending', 'flooding_step'))) continue;
        if (is_array($r)) $r = json_encode($r);
        $out .= $k . ": " . $r . "<br />";
    }
    return $out;
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
    $map_array = explode("\n", $map_string);
    $out = "";
    foreach ($map_array as $row) {
        $out .= "<div class='outer' style='display:block;clear:both' >";
        for ($i = 0; $i < strlen($row); $i++ ) {
            $out .= "<div class='block' style='float:left;padding:0;margin:0'><img height=60 src='images/" . $symbol_image_map[substr($row,$i, 1)] . "' ></div>";
        }
        $out .= "</div>";
    }
    $out .= "<input type='hidden' id='old_map' value='" . urlencode($map_string) . "' />";
    return $out;
}


// lamda miner viewer defaults

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

$state = '{"score":0, "lambda_count":0,"robot_loc":[2,5], "lambda_remain":7}';

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
            //alert(data.state);
            if (data.success == 1) {
                $("#map_container").html(data.generated_map);
                $("#state_container").html(data.generated_state);
            }
        }, "json");
    return false;
}


$(document).keydown(function(e){
    if (e.keyCode == 37) {
        alert("left pressed");
        left();
        return false;
    }
    if (e.keyCode == 38) {
        alert("up pressed");
        up();
        return false;
    }
    if (e.keyCode == 39) {
        alert("right pressed");
        right();
        return false;
    }
    if (e.keyCode == 40) {
        alert("down pressed");
        down();
        return false;
    }
});

</script>


<title>lamda miner viewer</title>
</head>

<body>

<input id="down" type="button" value="down" onClick="down(); return false;" />
<input id="up" type="button" value="up" onClick="up(); return false;" />
<input id="right" type="button" value="right" onClick="right(); return false;" />
<input id="left" type="button" value="left" onClick="left(); return false;" />
<input id="wait" type="button" value="wait" onClick="wait(); return false;" />
<input id="abort" type="button" value="abort" onClick="abort(); return false;" />

<div id="map_container">
<?php

echo generateMap($map_string);

?>
</div>
<p><p>
<div id="state_container" style="clear:both;">
<?php
echo generateState($state);
?>
</div>

</body>
</html>