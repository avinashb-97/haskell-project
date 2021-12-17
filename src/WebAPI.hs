{-# LANGUAGE OverloadedStrings #-}

{-|
Module      : WebAPI
Description : Get Request API using Scooty
License     : GPL-3
-}

module WebAPI
    ( 
        startAPI
    ) where


import Database
import Web.Scotty
import Types
import Control.Monad.IO.Class
import Fetch
import Parse

-- | starts scotty server
startAPI :: IO()
startAPI = do
    putStrLn "Starting Server..."
    conn <- initialiseDB
    scotty 3000 $ do
        get "/holidays/:year/:division" $ do
            yy <- param "year"
            div <- param "division"
            holidays <- liftIO $ queryBankHolidays conn div yy
            json holidays

