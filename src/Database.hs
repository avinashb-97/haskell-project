{-# LANGUAGE OverloadedStrings #-}
{-|
Module      : Database
Description : Handles adding and fetching the data
License     : GPL-3
-}

module Database
    ( 
        initialiseDB,
        saveRecords,
        queryBankHolidaysForCurrentYear,
        queryBankHolidaysForGivenYear,
        queryNextBankHoliday,
        queryBankHolidays
    ) where

import Database.SQLite.Simple
import Control.Applicative
import Database.SQLite.Simple.Internal
import Database.SQLite.Simple.FromRow
import Database.SQLite.Simple.ToRow
import Types
import System.IO
import Date


-- | Initialises the SQLite DB and creates table Divisions and Events if not exists
initialiseDB :: IO Connection
initialiseDB = do
        conn <- open "bankHolidays.sqlite"
        execute_ conn "CREATE TABLE IF NOT EXISTS divisions (\
            \id INTEGER PRIMARY KEY AUTOINCREMENT,\
            \division VARCHAR(225) NOT NULL \
            \)"
        execute_ conn "CREATE TABLE IF NOT EXISTS events (\
            \title VARCHAR(225) NOT NULL, \
            \date DATE NOT NULL, \
            \notes VARCHAR(225) DEFAULT NULL, \
            \fk_division INTEGER\
            \)"
        return conn


instance FromRow DivisionEntry where
    fromRow = DivisionEntry <$> field <*> field
    
instance FromRow Event where
    fromRow = Event <$> field <*> field <*> field

instance ToRow DivisionEntry where
    toRow (DivisionEntry id_ division_)
        = toRow (id_, division_)

instance ToRow EventEntry where
    toRow (EventEntry title_ date_ notes_ fk_division)
        = toRow (title_, date_, notes_, fk_division)

-- | Gets the division data if already present or creates and insert the given division
getOrCreateDivision :: Connection -> String -> IO DivisionEntry
getOrCreateDivision conn division = do
    results <- queryNamed conn "SELECT * FROM divisions WHERE division=:division" [":division" := division]    
    if length results > 0 then
        return . head $ results
    else do
        execute conn "INSERT INTO divisions (division) VALUES (?)" (Only (division::String))
        getOrCreateDivision conn division

-- | Creates and insert a event entry in DB 
createEvent :: Connection -> String -> Event -> IO ()
createEvent conn division event = do
    divisionData <- getOrCreateDivision conn division
    let entry = EventEntry {
        title_ = title event,
        date_ = date event,
        notes_ = notes event,
        fk_division = id_ divisionData
    }
    execute conn "INSERT INTO events VALUES (?,?,?,?)" (entry)

-- | Saves data of all event in a division given division name and list of event
saveEvent :: Connection -> String -> [Event] -> IO ()
saveEvent conn div = mapM_ (createEvent conn div)

-- | Saves data of all the events in a division
saveRecord :: Connection -> Events -> IO ()
saveRecord conn event = saveEvent conn (division event) (events event)

-- | Saves all the bank holiday data to the DB with given connection
saveRecords :: Connection -> Record -> IO ()
saveRecords conn record = do
    saveRecord conn (england_and_wales record)
    saveRecord conn (scotland record)
    saveRecord conn (northern_ireland record)

-- | Gets the input from user for choosing a division
getDivisonFromUser :: IO String
getDivisonFromUser = do
    putStrLn "----------------------"
    putStrLn "Choose a division     "
    putStrLn "1. England and Wales  "
    putStrLn "2. Scotland           "
    putStrLn "3. Northern Ireland   "
    putStrLn "----------------------"
    hSetBuffering stdout NoBuffering
    putStr "Option > "
    option <- readLn :: IO Int
    let divisions = ["england-and-wales","scotland","northern-ireland"]  
    let division = if option <=3  then (divisions !! (option-1)) else "" 
    return $ divisions !! (option-1)

-- | Gets all the bank holidays in a division in current year
queryBankHolidaysForCurrentYear :: Connection -> IO [Event]
queryBankHolidaysForCurrentYear conn = do
    yy <- getCurrentYear 
    let year = show yy
    queryBankHolidaysWithYear conn year

-- | Gets Input from user and Fetches data of all the bank holidays in a chosen division for a given year
queryBankHolidaysForGivenYear :: Connection -> IO [Event]
queryBankHolidaysForGivenYear conn = do
    putStrLn "Enter a year between 2017 and 2023 : "
    hSetBuffering stdout NoBuffering
    option <- getLine
    queryBankHolidaysWithYear conn option

-- | Gets Input from user and Fetches data of all the bank holidays in a chosen division for a given year
queryBankHolidaysWithYear :: Connection -> String -> IO [Event]
queryBankHolidaysWithYear conn year = do
    division <- getDivisonFromUser
    putStrLn $ "Looking for bank holidays in " ++ division++" for the year "++year++"..."
    queryBankHolidays conn division year

-- | Gets Input from user and Fetches data from DB for the next Bank Holiday
queryNextBankHoliday :: Connection -> IO [Event]
queryNextBankHoliday conn = do
    division <- getDivisonFromUser
    date <- getCurrentDate
    putStrLn $ "Looking for next bank holiday in " ++ division++"..."
    query conn "SELECT title,date,notes FROM events inner join divisions on events.fk_division == divisions.id WHERE division=? and date(events.date) > ? limit 1" [division::String, date::String]

-- | Fetches Bank holiday for the given year
queryBankHolidays :: Connection -> String -> String -> IO [Event]
queryBankHolidays conn division year = do
    query conn "SELECT title,date,notes FROM events inner join divisions on events.fk_division == divisions.id WHERE division=? and strftime('%Y', events.date) = ?" [division::String, year::String]
