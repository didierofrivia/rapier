module Api.Endpoint exposing (Endpoint, config, request, schema)

import Http
import Json.Decode exposing (Decoder, Value)
import Task exposing (Task)
import Url.Builder exposing (QueryParameter)



-- TYPES


type Endpoint
    = Endpoint String


toUrl : List String -> List QueryParameter -> Endpoint
toUrl paths queryParams =
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
    , decoder : Decoder a
    , headers : List Http.Header
    , method : String
    , timeout : Maybe Float
    , url : Endpoint
    }
    -> Task Http.Error a
request settings =
    Http.task
        { body = settings.body
        , resolver = Http.stringResolver <| handleJsonResponse <| settings.decoder
        , headers = settings.headers
        , method = settings.method
        , timeout = settings.timeout
        , url = unwrap settings.url
        }



-- ENDPOINTS


schema : Endpoint
schema =
    toUrl [ "schema" ] []


config : Endpoint
config =
    toUrl [ "config" ] []



-- HELPERS


handleJsonResponse : Decoder a -> Http.Response String -> Result Http.Error a
handleJsonResponse decoder response =
    case response of
        Http.BadUrl_ url ->
            Err (Http.BadUrl url)

        Http.Timeout_ ->
            Err Http.Timeout

        Http.BadStatus_ { statusCode } _ ->
            Err (Http.BadStatus statusCode)

        Http.NetworkError_ ->
            Err Http.NetworkError

        Http.GoodStatus_ _ body ->
            case Json.Decode.decodeString decoder body of
                Err _ ->
                    Err (Http.BadBody body)

                Ok result ->
                    Ok result
