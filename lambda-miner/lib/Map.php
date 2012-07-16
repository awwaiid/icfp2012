<?php

class Map {

    public $validSymbols = array('#','*','R','.','L','\\',' ', 'O','+');

    public $dimensions = array(0,0);
    public $rows = array();

	function __construct($json) {
        $arr = json_decode($json, true);
        $height = count($arr);
        $width = isset($arr[0]) ? count($arr[0]) : 0;
        $this->setDimensions(array($width, $height));
        $this->setRows($arr);
    }

    /**
     * @return the $validSymbols
     */
    public function getValidSymbols ()
    {
        return $this->validSymbols;
    }

	/**
     * @return the $dimensions
     */
    public function getDimensions ()
    {
        return $this->dimensions;
    }

	/**
     * @return the $rows
     */
    public function getRows ()
    {
        return $this->rows;
    }

	/**
     * @param field_type $validSymbols
     */
    public function setValidSymbols ($validSymbols)
    {
        $this->validSymbols = $validSymbols;
    }

	/**
     * @param field_type $dimensions
     */
    public function setDimensions ($dimensions)
    {
        $this->dimensions = $dimensions;
    }

	/**
     * @param field_type $rows
     */
    public function setRows ($rows)
    {
        $this->rows = $rows;
    }
}