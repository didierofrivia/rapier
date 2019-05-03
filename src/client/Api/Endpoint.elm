module Api.Endpoint exposing (Endpoint, config, request, schema, uiSchema, urlBuilder)

import Http
import Json.Decode exposing (Decoder, Value)
import Task exposing (Task)
import Url.Builder exposing (QueryParameter)



-- TYPES


type alias Endpoint =
    ( List String, List QueryParameter )


urlBuilder : String -> Endpoint -> String
urlBuilder baseUrl endpoint =
    let
        ( paths, params ) =
            endpoint
    in
    Url.Builder.crossOrigin baseUrl ("api" :: paths) params


request :
    { body : Http.Body
    , decoder : Decoder a
    , headers : List Http.Header
    , method : String
    , timeout : Maybe Float
    , url : String
    }
    -> Task Http.Error a
request settings =
    Http.task
        { body = settings.body
        , resolver = Http.stringResolver <| handleJsonResponse <| settings.decoder
        , headers = settings.headers
        , method = settings.method
        , timeout = settings.timeout
        , url = settings.url
        }



-- ENDPOINTS


schema : Endpoint
schema =
    ( [ "schema" ], [] )


config : Endpoint
config =
    ( [ "config" ], [] )


uiSchema : Endpoint
uiSchema =
    ( [ "ui-schema" ], [] )



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
