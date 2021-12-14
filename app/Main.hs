{-# LANGUAGE DeriveGeneric #-}

{-# LANGUAGE OverloadedStrings #-}
module Main where

import Database
import Fetch

main :: IO ()
main =  do
    -- Initialises DB and Creates Tables If not exists already
    conn <- initialiseDB

    -- url for Json Data of World University Rankings by Times Higher Education
    let url = "https://www.timeshighereducation.com/sites/default/files/the_data_rankings/world_university_rankings_2021_0__fa224219a267a5b9c4287386a97c70ea.json"
    print "Downloading..."
    json <- download url
    print json
            
