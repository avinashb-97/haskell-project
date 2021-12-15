{-# LANGUAGE OverloadedStrings #-}

module Database
    ( 
        initialiseDB
    ) where

import Database.SQLite.Simple

import Database.SQLite.Simple.Internal
import Database.SQLite.Simple.FromRow
import Database.SQLite.Simple.ToRow
import Types

initialiseDB :: IO Connection
initialiseDB = do
        conn <- open "bankHolidays.sqlite"
        execute_ conn "CREATE TABLE IF NOT EXISTS divisions (\
            \id INTEGER PRIMARY KEY AUTOINCREMENT,\
            \division VARCHAR(80) NOT NULL \
            \)"
        execute_ conn "CREATE TABLE IF NOT EXISTS events (\
            \title VARCHAR(40) NOT NULL, \
            \date DATE NOT NULL, \
            \notes VARCHAR(40) DEFAULT NULL, \
            \fk_division INTEGER\
            \)"
        return conn

instance FromRow DivisionEntry where
    fromRow = DivisionEntry <$> field

instance FromRow EventEntry where
    fromRow = EventEntry <$> field <*> field <*> field

getOrCreateDivision :: Connection -> String -> IO DivisionEntry
getOrCreateDivision conn division = do
    results <- queryNamed conn "SELECT * FROM divisions WHERE division=:division" [":division" := division]    
    if length results > 0 then
        return . head $ results
    else do
        execute conn "INSERT INTO division (division) VALUES (?, ?, ?)" (division)
        getOrCreateCountry conn division

createEvent :: Connection -> String -> Event -> IO ()
createEvent conn division event = do
    division <- getOrCreateDivision conn division
    let entry = EventEntry {
        title_ = title event,
        date_ = date event,
        notes_ = notes event,
        fk_division = id_ division
    }
    execute conn "INSERT INTO events VALUES (?,?,?,?)" entry


saveEvent :: Connection -> String -> [Event] -> IO ()
saveEvent div conn = mapM_ (createEvent conn div)

saveRecord :: Connection -> Events -> IO ()
saveRecord conn event = saveEvent conn (division event) (events event)
