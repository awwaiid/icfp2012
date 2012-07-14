<?php

class Position {

    public $x;
    public $y;

    function __construct($x, $y) {
        $this->setX($x);
        $this->setY($y);
    }

	/**
     * @return the $x
     */
    public function getX ()
    {
        return $this->x;
    }

	/**
     * @return the $y
     */
    public function getY ()
    {
        return $this->y;
    }

	/**
     * @param field_type $x
     */
    public function setX ($x)
    {
        $this->x = $x;
    }

	/**
     * @param field_type $y
     */
    public function setY ($y)
    {
        $this->y = $y;
    }

    public function __toString() {
        return "(" . $this->getX() . "," . $this->getY() . ")";
    }
}