module Main where

import Database (initialiseDB)

main :: IO ()
main =  do
    conn <- initialiseDB
    print "Hello"