module Service.Book exposing (load, searchAmazon)

import Http
import Data.Book as Book exposing (Book)


load : Http.Request (List Book)
load =
    Http.get "https://book-list-1265b.firebaseio.com/books.json" Book.listDecoder


searchAmazon : String -> Http.Request (List Book)
searchAmazon query =
    Http.get ("https://us-central1-book-list-e82a4.cloudfunctions.net/app/books?q=" ++ query) Book.amazonListDecoder
