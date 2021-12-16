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
import Database.SQLite.Simple
import System.IO

-- Downloads, Parses and Saves the data from given api
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
                    saveRecords conn recs
                    print "Saved data to DB!"


-- Gets and prints all the holidays in the division in current year
bankHolidaysForCurrentYear :: Connection  -> IO ()
bankHolidaysForCurrentYear conn = do
    holiday <- queryBankHolidaysForCurrentYear conn
    mapM_ uprint holiday

-- Gets and prints all the holidays in the division in a given year
bankHolidaysForGivenYear :: Connection  -> IO ()
bankHolidaysForGivenYear conn = do
    holiday <- queryBankHolidaysForGivenYear conn
    mapM_ uprint holiday

-- Gets and prints next bank holiday
nextBankHoliday :: Connection  -> IO ()
nextBankHoliday conn = do
    holiday <- queryNextBankHoliday conn
    mapM_ uprint holiday

main :: IO ()
main = withUtf8 $ do
    putStrLn "-----------------------------------------------"
    putStrLn "  Welcome to the UK Bank Holidays app          "
    putStrLn "  (1) Download data                            "
    putStrLn "  (2) View all Bank Holidays for current year  "
    putStrLn "  (3) View all Bank Holidays for given year    "
    putStrLn "  (4) Find next Bank Holiday                   "
    putStrLn "  (5) Quit                                     "
    putStrLn "-----------------------------------------------"
    hSetBuffering stdout NoBuffering
    putStr "Choose an option > "
    option <- readLn :: IO Int
    print option

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
        5 -> putStrLn "Thank you for using UK Bank Holidays app."
        otherwise -> print "You've chosen an invalid option!"
    
            
