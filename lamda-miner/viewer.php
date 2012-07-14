<?php
$dead_miner = false;
if (isset($_POST['next_move'])) {
    $cmd = "./lifter2 '" . $_POST['old_world'] . "' " . $_POST['next_move'];
    $shell_return = shell_exec($cmd);
    //$shell_return_parts = explode("\n\n", $shell_return);
    $generated_state = generateState($shell_return);
    $generated_map = generateMapFromJSON($shell_return);

    $return = array(
        'success'=>1,
        'state'=>$shell_return,
        'generated_map'=>$generated_map,
        'generated_state'=>$generated_state,
        'command'=>$cmd
    );
    echo json_encode($return);
    exit;
}

function generateState($state) {
    global $dead_miner;
    $state_parts = json_decode($state, true);
    $out = "";
    foreach ($state_parts as $k=>$r) {
        if (!in_array($k, array('score','lamda_count','robot_loc','lambda_remain','ending',
        	'flooding_step', 'waterproof', 'waterproof_step'))) continue;
        if (is_array($r)) $r = json_encode($r);
        $out .= $k . ": " . $r . "<br />";
        if ($k == 'ending' && $r != 'WIN') {
            $dead_miner = true;
        }
    }
    return $out;
}

function generateMap($map_string) {
    global $dead_miner;
    $symbol_image_map = array(
        '#' => 'wall.jpg',
        '*' => 'rock.jpg',
        'R' => 'miner.jpg',
        '.' => 'earth.jpg',
        'L' => 'lift_closed.jpg',
        '\\' => 'lambda.jpg',
        ' ' => 'empty.jpg',
        'O' => 'lift_open.jpg',
        '+' => 'rock.jpg'
    );
    $map_array = explode("\n", $map_string);
    $out = "";
    foreach ($map_array as $row) {
        if (ctype_space($row)) continue;
        $out .= "<div class='outer' style='display:block;clear:both' >";
        for ($i = 0; $i < strlen($row); $i++ ) {
            $symbol = isset($symbol_image_map[substr($row, $i, 1)]) ?
                $symbol_image_map[substr($row,$i, 1)] : 'dead_miner.jpg';
            if ($symbol == 'miner.jpg' && $dead_miner == true) $symbol = 'dead_miner.jpg';
            $out .= "<div class='block' style='float:left;padding:0;margin:0'><img height=60
            	src='images/" . $symbol . "' ></div>";
        }
        $out .= "</div>";
    }
    $out .= "<input type='hidden' id='old_map' value='" . urlencode($map_string) . "' />";
    return $out;
}

function generateMapFromJSON($world) {
    global $dead_miner;
    $symbol_image_map = array(
        '#' => 'wall.jpg',
        '*' => 'rock.jpg',
        'R' => 'miner.jpg',
        '.' => 'earth.jpg',
        'L' => 'lift_closed.jpg',
        '\\' => 'lambda.jpg',
        ' ' => 'empty.jpg',
        'O' => 'lift_open.jpg',
        '+' => 'rock.jpg'
    );
    $world_array = json_decode($world, true);
    $map_array = $world_array['map'];
    $out = "";
    //var_dump ($world);
    //var_dump ($world_array);
    foreach ($map_array as $row) {
        if (ctype_space($row)) continue;
        $out .= "<div class='outer' style='display:block;clear:both' >";
        foreach ($row as $r) {
            $symbol = isset($symbol_image_map[$r]) ? $symbol_image_map[$r] : 'dead_miner.jpg';
            if ($symbol == 'miner.jpg' && $dead_miner == true) $symbol = 'dead_miner.jpg';
            $out .= "<div class='block' style='float:left;padding:0;margin:0'><img height=60
            	src='images/" . $symbol . "' ></div>";
        }
        $out .= "</div>";
    }
    $out .= "<input type='hidden' id='old_world' value='" . $world . "' />";
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

$world = '{"waterproof_step":0,"waterproof":10,"bonus_score":0,"partial_score":0,"lambda_remain":8,"score":0,"water":0,' .
		 '"map":[["#","#","#","#","#","#","#","#","#"," "],["#",".",".",".",".",".",".",".","#"," "],["#",".",".",".","\\\","R"," ","*","#"," "],' .
        '["#",".",".","\\\"," "," ",".",".","#"," "],["#",".","\\\"," "," ",".",".",".","#"," "],["#","\\\"," "," ",".","#","#","#","#"," "],' .
        '["#"," "," ",".",".","#","\\\","\\\","#"," "],["#","\\\","#",".",".",".",".",".","#"," "],["#","#","#","#","#","#","L","#","#"," "]],' .
       	'"flooding":0,"flooding_step":0,"robot_loc":[2,5],"lambda_count":0}';

?>
<html>
<head>
<script src="//ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js" type="text/javascript">
</script>
<script>

function up() {
    sendMove('U', $("#old_world").val());
}

function down() {
    sendMove('D', $("#old_world").val());
}

function right() {
    sendMove('R', $("#old_world").val());
}

function left() {
    sendMove('L', $("#old_world").val());
}

function wait() {
    sendMove('W', $("#old_world").val());
}

function abort() {
    sendMove('A');
}

function sendMove(move, world) {
    $.post("viewer.php", {next_move:move, old_world:world},
        function (data) {
            alert(data.command);
            if (data.success == 1) {
                $("#map_container").html(data.generated_map);
                $("#state_container").html(data.generated_state);
            }
        }, "json");
    return false;
}


$(document).keydown(function(e){
    if (e.keyCode == 37) {
        left();
        return false;
    }
    if (e.keyCode == 38) {
        up();
        return false;
    }
    if (e.keyCode == 39) {
        right();
        return false;
    }
    if (e.keyCode == 40) {
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

echo generateMapFromJSON($world);

?>
</div>
<p><p>
<div id="state_container" style="clear:both;">
<?php
echo generateState($world);
?>
</div>

</body>
</html>