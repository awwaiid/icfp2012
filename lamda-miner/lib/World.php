<?php

class World {

    public $waterproofStep;
    public $waterproof;
    public $water;
    public $bonusScore;
    public $moveCount;
    public $lamdaRemain;
    public $partialScore;
    public $score;
    public $map;
    public $flooding;
    public $floodingStep;
    public $robotLoc;
    public $lamdaCount;

    function __construct($json) {
        $arr = json_decode($json, true);
        $this->setWater($arr['water']);
        $this->setWaterproof($arr['waterproof']);
        $this->setWaterproofStep($arr['waterproof_step']);
        $this->setBonusScore($arr['bonus_score']);
        $this->setMoveCount($arr['move_count']);
        $this->setScore($arr['score']);
        $this->setPartialScore($arr['partial_score']);
        $this->setFlooding($arr['flooding']);
        $this->setFloodingStep($arr['flooding_step']);
        $this->setRobotLoc($arr['robot_loc']);
        $this->setLamdaCount($arr['lambda_count']);
        $map = new Map(json_encode($arr['map']));
        $this->setMap($map);
    }
	/**
     * @return the $waterproofStep
     */
    public function getWaterproofStep ()
    {
        return $this->waterproofStep;
    }

	/**
     * @return the $waterproof
     */
    public function getWaterproof ()
    {
        return $this->waterproof;
    }

	/**
     * @return the $water
     */
    public function getWater ()
    {
        return $this->water;
    }

	/**
     * @return the $bonusScore
     */
    public function getBonusScore ()
    {
        return $this->bonusScore;
    }

	/**
     * @return the $moveCount
     */
    public function getMoveCount ()
    {
        return $this->moveCount;
    }

	/**
     * @return the $lamdaRemain
     */
    public function getLamdaRemain ()
    {
        return $this->lamdaRemain;
    }

	/**
     * @return the $partialScore
     */
    public function getPartialScore ()
    {
        return $this->partialScore;
    }

	/**
     * @return the $score
     */
    public function getScore ()
    {
        return $this->score;
    }

	/**
     * @return the $map
     */
    public function getMap ()
    {
        return $this->map;
    }

	/**
     * @return the $flooding
     */
    public function getFlooding ()
    {
        return $this->flooding;
    }

	/**
     * @return the $floodingStep
     */
    public function getFloodingStep ()
    {
        return $this->floodingStep;
    }

	/**
     * @return the $robotLoc
     */
    public function getRobotLoc ()
    {
        return $this->robotLoc;
    }

	/**
     * @return the $lamdaCount
     */
    public function getLamdaCount ()
    {
        return $this->lamdaCount;
    }

	/**
     * @param field_type $waterproofStep
     */
    public function setWaterproofStep ($waterproofStep)
    {
        $this->waterproofStep = $waterproofStep;
    }

	/**
     * @param field_type $waterproof
     */
    public function setWaterproof ($waterproof)
    {
        $this->waterproof = $waterproof;
    }

	/**
     * @param field_type $water
     */
    public function setWater ($water)
    {
        $this->water = $water;
    }

	/**
     * @param field_type $bonusScore
     */
    public function setBonusScore ($bonusScore)
    {
        $this->bonusScore = $bonusScore;
    }

	/**
     * @param field_type $moveCount
     */
    public function setMoveCount ($moveCount)
    {
        $this->moveCount = $moveCount;
    }

	/**
     * @param field_type $lamdaRemain
     */
    public function setLamdaRemain ($lamdaRemain)
    {
        $this->lamdaRemain = $lamdaRemain;
    }

	/**
     * @param field_type $partialScore
     */
    public function setPartialScore ($partialScore)
    {
        $this->partialScore = $partialScore;
    }

	/**
     * @param field_type $score
     */
    public function setScore ($score)
    {
        $this->score = $score;
    }

	/**
     * @param field_type $map
     */
    public function setMap ($map)
    {
        $this->map = $map;
    }

	/**
     * @param field_type $flooding
     */
    public function setFlooding ($flooding)
    {
        $this->flooding = $flooding;
    }

	/**
     * @param field_type $floodingStep
     */
    public function setFloodingStep ($floodingStep)
    {
        $this->floodingStep = $floodingStep;
    }

	/**
     * @param field_type $robotLoc
     */
    public function setRobotLoc ($robotLoc)
    {
        $this->robotLoc = $robotLoc;
    }

	/**
     * @param field_type $lamdaCount
     */
    public function setLamdaCount ($lamdaCount)
    {
        $this->lamdaCount = $lamdaCount;
    }





}