<?php

class Path {

    public $route;

    function __construct() {
        $this->route = array();
    }

    public function getRoute() {
        return $this->route;
    }

    public function addToRoute(Position $p) {
        $this->route[] = $p;
    }

}