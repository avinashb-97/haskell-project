{-# LANGUAGE OverloadedStrings #-}

{-|
Module      : Main
Description : Handles the user interaction and showing data to user
License     : GPL-3
-}

module Main where

import Database
import Fetch
import Parse
import Types
import Text.Show.Unicode
import Main.Utf8 (withUtf8)
import Types
import Database.SQLite.Simple
import System.IO
import WebAPI

-- | Downloads, Parses and Saves the data to the DB from Bank Holidays API
downloadData :: Connection -> IO ()
downloadData conn = do
    -- url for JSON data for bank holidays in UK from 2017 to 2023
    let url = "https://www.gov.uk/bank-holidays.json"
    print "Downloading..."
    json <- download url
    print "Parsing..."
    case (parseRecords json) of
                Left err -> print err
                Right recs -> do
                    print "Parsing Done"
                    print "Saving Data to DB..."
                    saveRecords conn recs
                    print "Data saved to DB"
                    print "Writing data to file"
                    writeToFile recs
                    print "Created bank_holidays.json successfully"


-- | Fetches from DB and prints all the holidays for the current year for chosen division
bankHolidaysForCurrentYear :: Connection  -> IO ()
bankHolidaysForCurrentYear conn = do
    holiday <- queryBankHolidaysForCurrentYear conn
    mapM_ uprint holiday

-- | Fetches from DB and prints all the holidays in a given year for chosen division
bankHolidaysForGivenYear :: Connection  -> IO ()
bankHolidaysForGivenYear conn = do
    holiday <- queryBankHolidaysForGivenYear conn
    mapM_ uprint holiday

-- | Fetches from DB and prints next bank holiday for chosen division
nextBankHoliday :: Connection  -> IO ()
nextBankHoliday conn = do
    holiday <- queryNextBankHoliday conn
    mapM_ uprint holiday

-- | Main function
main :: IO ()
main = withUtf8 $  do
    putStrLn "------------------------------------------------------------------"
    putStrLn "  Welcome to the UK Bank Holidays app                             "
    putStrLn "  (1) Download data                                               "
    putStrLn "  (2) View all Bank Holidays for current year                     "
    putStrLn "  (3) View all Bank Holidays for given year                       "
    putStrLn "  (4) Find next Bank Holiday                                      "
    putStrLn "  (5) Start local server to fetch holidays (Additional Feature)   "
    putStrLn "  (6) Quit                                                        "
    putStrLn "------------------------------------------------------------------"
    hSetBuffering stdout NoBuffering
    putStr "Choose an option > "
    option <- readLn :: IO Int

    -- Initialises DB and Creates Tables If not exists already
    conn <- initialiseDB

    case option of
        1 -> do
            downloadData conn
            main
        2 -> do
            bankHolidaysForCurrentYear conn
            main
        3 -> do
            bankHolidaysForGivenYear conn
            main
        4 -> do
            nextBankHoliday conn
            main
        5 -> do 
            startAPI
        6 -> putStrLn "Thank you for using UK Bank Holidays app."
        otherwise -> print "You've chosen an invalid option!"
    
            
