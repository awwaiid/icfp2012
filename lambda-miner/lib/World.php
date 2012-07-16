<?php

class World {

    public $waterproofStep;
    public $waterproof;
    public $water;
    public $bonusScore;
    public $moveCount;
    public $lambdaRemain;
    public $partialScore;
    public $score;
    public $map;
    public $flooding;
    public $floodingStep;
    public $robotLoc;
    public $lambdaCount;
    public $ending = null;
    public $robotLocPrev = null;
    public $json;

	function __construct($json) {
        $this->json = $json;
        $arr = json_decode($json, true);
        $this->setWater($arr['water']);
        $this->setWaterproof($arr['waterproof']);
        $this->setWaterproofStep($arr['waterproof_step']);
        $this->setBonusScore($arr['bonus_score']);
        if (isset($arr['move_count'])) $this->setMoveCount($arr['move_count']);
        $this->setScore($arr['score']);
        $this->setPartialScore($arr['partial_score']);
        $this->setFlooding($arr['flooding']);
        $this->setFloodingStep($arr['flooding_step']);
        $this->setRobotLoc($arr['robot_loc']);
        if (!$this->getRobotLoc() instanceof Position) {
            throw new Exception('Must be a Position object');
        }
        if (isset($arr['robot_loc_prev'])) $this->setRobotLocPrev($arr['robot_loc_prev']);
        $this->setLamdaCount($arr['lambda_count']);
        $map = new Map(json_encode($arr['map']));
        $this->setMap($map);

        if (isset($arr['ending'])) $this->setEnding($arr['ending']);
    }
    /**
     * @return the $robot_loc_prev
     */
    public function getRobotLocPrev ()
    {
        return $this->robotLocPrev;
    }

	/**
     * @param field_type $robot_loc_prev
     */
    public function setRobotLocPrev ($robotLocPrev)
    {
        if (is_array($robotLocPrev)) {
            $this->robotLocPrev = new Position($robotLocPrev[0], $robotLocPrev[1]);
        }
        else {
            $this->robotLocPrev = $robotLocPrev;
        }
    }

    public function getEnding() {
        return $this->ending;
    }

    public function setEnding($ending) {
        $this->ending = $ending;
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
     * @return the $lambdaRemain
     */
    public function getLamdaRemain ()
    {
        return $this->lambdaRemain;
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
     * @return the $lambdaCount
     */
    public function getLamdaCount ()
    {
        return $this->lambdaCount;
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
     * @param field_type $lambdaRemain
     */
    public function setLamdaRemain ($lambdaRemain)
    {
        $this->lambdaRemain = $lambdaRemain;
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
        if (is_array($robotLoc)) {
            $this->robotLoc = new Position($robotLoc[0], $robotLoc[1]);
        }
        else {
            $this->robotLoc = $robotLoc;
        }
    }

	/**
     * @param field_type $lambdaCount
     */
    public function setLamdaCount ($lambdaCount)
    {
        $this->lambdaCount = $lambdaCount;
    }





}