{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Database
import Fetch
import Parse
import Types
import Text.Show.Unicode
import Main.Utf8 (withUtf8)
import Types

main :: IO ()
main = withUtf8 $ do
    -- Initialises DB and Creates Tables If not exists already
    conn <- initialiseDB
    -- url for JSON data for bank holidays in UK
    let url = "https://www.gov.uk/bank-holidays.json"
    print "Downloading..."
    json <- download url
    print "Parsing..."
    case (parseRecords json) of
                Left err -> print err
                Right recs -> do
                    print "Parsing Done"
                    print (scotland recs)
                    print "Saved!"
            
