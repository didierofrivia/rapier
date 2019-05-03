module Api exposing (get, put)

import Api.Endpoint as Endpoint exposing (Endpoint)
import Http exposing (Body, Expect)
import Json.Decode exposing (Decoder, Value)
import Task exposing (Task)



-- HTTP


get : String -> Decoder a -> Task Http.Error a
get url decoder =
    Endpoint.request
        { method = "GET"
        , url = url
        , decoder = decoder
        , headers = []
        , body = Http.emptyBody
        , timeout = Nothing
        }


put : String -> Body -> Decoder a -> Task Http.Error a
put url body decoder =
    Endpoint.request
        { method = "PUT"
        , url = url
        , decoder = decoder
        , headers = []
        , body = body
        , timeout = Nothing
        }
