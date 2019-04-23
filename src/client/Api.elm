module Api exposing (delete, get, post, put)

import Api.Endpoint as Endpoint exposing (Endpoint)
import Http exposing (Body, Expect)
import Json.Decode exposing (Decoder, Value)
import Task exposing (Task)



-- HTTP


get : Endpoint -> Decoder a -> Task Http.Error a
get url decoder =
    Endpoint.request
        { method = "GET"
        , url = url
        , decoder = decoder
        , headers = []
        , body = Http.emptyBody
        , timeout = Nothing
        }


put : Endpoint -> Body -> Decoder a -> Task Http.Error a
put url body decoder =
    Endpoint.request
        { method = "PUT"
        , url = url
        , decoder = decoder
        , headers = []
        , body = body
        , timeout = Nothing
        }


post : Endpoint -> Body -> Decoder a -> Task Http.Error a
post url body decoder =
    Endpoint.request
        { method = "POST"
        , url = url
        , decoder = decoder
        , headers = []
        , body = body
        , timeout = Nothing
        }


delete : Endpoint -> Body -> Decoder a -> Task Http.Error a
delete url body decoder =
    Endpoint.request
        { method = "DELETE"
        , url = url
        , decoder = decoder
        , headers = []
        , body = body
        , timeout = Nothing
        }
