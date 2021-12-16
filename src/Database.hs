{-# LANGUAGE OverloadedStrings #-}


module Database
    ( 
        initialiseDB,
        saveRecords
    ) where

import Database.SQLite.Simple
import Control.Applicative
import Database.SQLite.Simple.Internal
import Database.SQLite.Simple.FromRow
import Database.SQLite.Simple.ToRow
import Types
import Types (Record(scotland))

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

instance FromRow EventEntry where
    fromRow = EventEntry <$> field <*> field <*> field <*> field

instance ToRow DivisionEntry where
    toRow (DivisionEntry id_ division_)
        = toRow (id_, division_)

instance ToRow EventEntry where
    toRow (EventEntry title_ date_ notes_ fk_division)
        = toRow (title_, date_, notes_, fk_division)

getOrCreateDivision :: Connection -> String -> IO DivisionEntry
getOrCreateDivision conn division = do
    results <- queryNamed conn "SELECT * FROM divisions WHERE division=:division" [":division" := division]    
    if length results > 0 then
        return . head $ results
    else do
        execute conn "INSERT INTO divisions (division) VALUES (?)" (Only (division::String))
        getOrCreateDivision conn division

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


saveEvent :: Connection -> String -> [Event] -> IO ()
saveEvent conn div = mapM_ (createEvent conn div)

saveRecord :: Connection -> Events -> IO ()
saveRecord conn event = saveEvent conn (division event) (events event)

saveRecords :: Connection -> Record -> IO ()
saveRecords conn record = do
    saveRecord conn (england_and_wales record)
    saveRecord conn (scotland record)
    saveRecord conn (northern_ireland record)
