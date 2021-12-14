{-# LANGUAGE OverloadedStrings #-}

module Database
    ( 
        initialiseDB
    ) where

import Database.SQLite.Simple

initialiseDB :: IO Connection
initialiseDB = do
        conn <- open "universities.sqlite"
        execute_ conn "CREATE TABLE IF NOT EXISTS country (\
            \id INTEGER PRIMARY KEY AUTOINCREMENT,\
            \country VARCHAR(80) NOT NULL \
            \)"
        execute_ conn "CREATE TABLE IF NOT EXISTS university (\
            \name VARCHAR(40) NOT NULL, \
            \rank INT DEFAULT NULL, \
            \fk_country INTEGER\
            \)"
        return conn

