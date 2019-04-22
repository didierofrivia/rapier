module Api.Endpoint exposing (Endpoint, config, request, schema)

import Http
import Json.Decode exposing (Decoder, Value)
import Url.Builder exposing (QueryParameter)



-- TYPES


type Endpoint
    = Endpoint String


url : List String -> List QueryParameter -> Endpoint
url paths queryParams =
    -- TODO: get this url from config
    Url.Builder.crossOrigin "http://localhost:3000"
        ("api" :: paths)
        queryParams
        |> Endpoint


unwrap : Endpoint -> String
unwrap (Endpoint str) =
    str


request :
    { body : Http.Body
    , msg : Result Http.Error a -> msg
    , decoder : Decoder a
    , headers : List Http.Header
    , method : String
    , timeout : Maybe Float
    , url : Endpoint
    , tracker : Maybe String
    }
    -> Cmd msg
request settings =
    Http.request
        { body = settings.body
        , expect = Http.expectJson settings.msg settings.decoder
        , headers = settings.headers
        , method = settings.method
        , timeout = settings.timeout
        , url = unwrap settings.url
        , tracker = settings.tracker
        }



-- ENDPOINTS


schema : Endpoint
schema =
    url [ "schema" ] []


config : Endpoint
config =
    url [ "config" ] []
