<?php

$dead_miner = false;
if (isset($_POST['next_move'])) {
    $cmd = "./lifter2 '" . $_POST['old_world'] . "' " . $_POST['next_move'];
    $shell_return = shell_exec($cmd);
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

if (isset($_POST['play_bot'])) {

    $cmd = "./" . $_POST['play_bot'] ." '" . $_POST['old_world'] . "'";
    $shell_return = shell_exec($cmd);
    $return = array(
        'success'=>1,
        'next_move'=>$shell_return,
        'command'=>$cmd
    );
    echo json_encode($return);
    exit;
}

if (isset($_POST['play_map'])) {
    $cmd = "./get_initial_map.pl " . $_POST['play_map'];
    $shell_return = shell_exec($cmd);
    $generated_state = generateState($shell_return);
    $generated_map = generateMapFromJSON($shell_return);
    $return = array(
        'success' => 1,
        'map_json'=>$shell_return,
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
    foreach ($state_parts as $k => $r) {
        if (!in_array($k, array('score','lamda_count','robot_loc','lambda_remain','ending', 'move_count',
        	'flooding_step', 'waterproof', 'waterproof_step', 'water', 'trampoline_loc','trampoline_forward','trampoline_back', 'map'))) continue;
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
        '+' => 'rock.jpg',
        'A' => 'trampoline1.jpg',
        'B' => 'trampoline2.jpg',
        'C' => 'trampoline3.jpg',
        'D' => 'trampoline4.jpg',
        'E' => 'trampoline5.jpg',
        'F' => 'trampoline6.jpg',
        'G' => 'trampoline7.jpg',
        'H' => 'trampoline8.jpg',
        'I' => 'trampoline9.jpg',
        '1' => 'target1.jpg',
        '2' => 'target2.jpg',
        '3' => 'target3.jpg',
        '4' => 'target4.jpg',
        '5' => 'target5.jpg',
        '6' => 'target6.jpg',
        '7' => 'target7.jpg',
        '8' => 'target8.jpg',
        '9' => 'target9.jpg'
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
        '+' => 'rock.jpg',
        'A' => 'trampoline1.jpg',
        'B' => 'trampoline2.jpg',
        'C' => 'trampoline3.jpg',
        'D' => 'trampoline4.jpg',
        'E' => 'trampoline5.jpg',
        'F' => 'trampoline6.jpg',
        'G' => 'trampoline7.jpg',
        'H' => 'trampoline8.jpg',
        'I' => 'trampoline9.jpg',
        '1' => 'target1.jpg',
        '2' => 'target2.jpg',
        '3' => 'target3.jpg',
        '4' => 'target4.jpg',
        '5' => 'target5.jpg',
        '6' => 'target6.jpg',
        '7' => 'target7.jpg',
        '8' => 'target8.jpg',
        '9' => 'target9.jpg'
    );
    $world_array = json_decode($world, true);
    $map_array = $world_array['map'];
    $out = "";
    $row_count = count($map_array);
    $water_row = $world_array['water'];

    foreach ($map_array as $key=>$row) {

        if ($row_count - $key  <= $water_row) { $water_css = "background-color:aqua;"; $tran_css = "opacity:0.4;filter:alpha(opacity=40);"; }
        else { $water_css = ''; $tran_css = ''; }

        if (ctype_space($row)) continue;
        $out .= "<div class='outer' style='display:block;clear:both' >";
        foreach ($row as $r) {
            $symbol = isset($symbol_image_map[$r]) ? $symbol_image_map[$r] : 'empty.jpg';
            if ($symbol == 'miner.jpg' && $dead_miner == true) $symbol = 'dead_miner.jpg';
            $out .= "<div class='block'
            	style='" . $water_css ."float:left;padding:0;margin:0;height:60;width:60'>";
            $out .= "<img height=60 style='" . $tran_css . "' src='images/" . $symbol . "' >";
            $out .= "</div>";
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

$world = '
{"waterproof_step":0,"waterproof":10,"bonus_score":0,"lambda_remain":8,"partial_score":0,"score":0,"water":0,"map":[["#","#","#","#","#","#","#","#","#"],["#",".","*",".",".","#","\\\",".","#"],["#",".","\\\",".",".","#","\\\",".","L"],["#",".","R"," ",".","#","#",".","#"],["#",".","\\\"," "," ",".",".",".","#"],["#",".",".","\\\"," "," ",".",".","#"],["#",".",".",".","\\\"," "," ","#","#"],["#",".",".",".",".","\\\"," ","\\\","#"],["#","#","#","#","#","#","#","#","#"]],"flooding":0,"flooding_step":0,"robot_loc":[2,5],"lambda_count":0}
'

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
    sendMove('A', $("#old_world").val());
}

function sendMove(move, world) {
    $.ajaxSetup({async: false});

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
    if (e.keyCode == 48) { // 0
        playBot();
        return false;
    }
    if (e.keyCode == 57) { // 9
        abort();
        return false;
    }
});

function playBot() {
    $.post("viewer.php", {play_bot:$("#play_bot").val(), old_world:$("#old_world").val()},
            function (data) {
                //alert (data.command + data.next_move);
                if (data.success == 1) {
                    sendMove(data.next_move, $("#old_world").val());
                }
            }, "json");
        return false;

}

function playMap() {
    $.post("viewer.php", {play_map:$("#play_map").val()},
            function (data) {
                //alert (data.command + "\n" + data.map_json);
                if (data.success == 1) {
                    $("#map_container").html(data.generated_map);
                    $("#state_container").html(data.generated_state);
                }
            }, "json");
        return false;

}

function playSeq() {
    var str = $("#play_seq").val();
    var moves = str.replace(/,\s+/g, ',').split(',');
    for(i=0; i<moves.length; i++) {
    	sendMove(moves[i], $("#old_world").val());
    }
    return false;
}

</script>

<title>lamda miner viewer</title>
</head>

<body>
<input style="margin-left:25px;width:40px" id="up" type="button" value="up" onClick="up(); return false;" />
<br />
<input id="right" style="width:40px" type="button" value="right" onClick="right(); return false;" />
<input id="left" style="width:40px" type="button" value="left" onClick="left(); return false;" />
<input id="wait" type="button" value="wait" onClick="wait(); return false;" />
<input id="abort" type="button" value="abort" onClick="abort(); return false;" />
<input id="play_bot" type="text" value="phpbot.php" />
<input id="submit_play_bot" type="submit" onClick="playBot(); return false;" value="Play Bot" />
<?php echo generateMapSelect(); ?>
<input id="submit_play_map" type="submit" onClick="playMap(); return false;" value="Play Map" />
<br />
<input style="margin-left:25px;width:40px" id="down" type="button" value="down" onClick="down(); return false;" />
<br />
<input type="text" style="width:500" id="play_seq" value="" />
<input type="submit" id="submit_play_seq" value="Play Sequence" onClick="playSeq(); return false;" />
<div id="map_container">
<?php

echo generateMapFromJSON($world);
//   echo generateMap($map_string);
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

<?php

function generateMapSelect() {
    echo '<select id="play_map">';
    $maps = scandir('../map');
    foreach ($maps as $m) {
        if (strpos($m, 'map')) {
            echo '<option value="' . $m . '">' . $m . '</option>';
        }
    }
    echo '</select>';
}

