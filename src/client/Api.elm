module Api exposing (delete, get, post, put)

import Api.Endpoint as Endpoint exposing (Endpoint)
import Http exposing (Body, Expect)
import Json.Decode exposing (Decoder, Value)



-- HTTP


get : Endpoint -> (Result Http.Error a -> msg) -> Decoder a -> Cmd msg
get url msg decoder =
    Endpoint.request
        { method = "GET"
        , url = url
        , msg = msg
        , decoder = decoder
        , headers = []
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        }


put : Endpoint -> (Result Http.Error a -> msg) -> Body -> Decoder a -> Cmd msg
put url msg body decoder =
    Endpoint.request
        { method = "PUT"
        , url = url
        , msg = msg
        , decoder = decoder
        , headers = []
        , body = body
        , timeout = Nothing
        , tracker = Nothing
        }


post : Endpoint -> (Result Http.Error a -> msg) -> Body -> Decoder a -> Cmd msg
post url msg body decoder =
    Endpoint.request
        { method = "POST"
        , url = url
        , msg = msg
        , decoder = decoder
        , headers = []
        , body = body
        , timeout = Nothing
        , tracker = Nothing
        }


delete : Endpoint -> (Result Http.Error a -> msg) -> Body -> Decoder a -> Cmd msg
delete url msg body decoder =
    Endpoint.request
        { method = "DELETE"
        , url = url
        , msg = msg
        , decoder = decoder
        , headers = []
        , body = body
        , timeout = Nothing
        , tracker = Nothing
        }
