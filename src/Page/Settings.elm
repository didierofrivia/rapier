module Page.Settings exposing (Model, Msg(..), Status(..), getSettings, settingsDecoder, subscriptions, update, view)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (Decoder, field, map4, string)
import Session exposing (..)



-- MODEL


type Status
    = Failure
    | Loading
    | Success GlobalSettings


type alias Model =
    { session : Session
    , status : Status
    }



-- UPDATE


type Msg
    = GetSettings
    | GotSettings (Result Http.Error GlobalSettings)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetSettings ->
            ( { model | status = Loading }, getSettings )

        GotSettings result ->
            case result of
                Ok payload ->
                    ( { model | status = Success payload }, Cmd.none )

                Err _ ->
                    ( { model | status = Failure }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "Settings" ]
        , viewSettings model
        ]


viewSettings : Model -> Html Msg
viewSettings model =
    case model.status of
        Failure ->
            div []
                [ text "I could not load apicast settings for some reason. "
                , button [ onClick GetSettings ] [ text "Get Settings!" ]
                ]

        Loading ->
            text "Loading..."

        Success config ->
            div []
                [ h2 [] [ text "Got Settings!" ]
                , text ("Config Level: " ++ config.logLevel)
                , text ("Error Log: " ++ config.errorLog)
                , text ("Access Log: " ++ config.accessLog)
                , text ("Open Tracing Tracer: " ++ config.opentracingTracer)
                ]



-- HTTP


type alias GlobalSettings =
    { logLevel : String
    , errorLog : String
    , accessLog : String
    , opentracingTracer : String
    }


getSettings : Cmd Msg
getSettings =
    Http.get
        { url = "https://gist.githubusercontent.com/didierofrivia/de9701158b2cfddca938fd0d9c29bc91/raw/e8198ddd4e870b59a72f61eaf2b187fc0f219de5/apicast.json"
        , expect = Http.expectJson GotSettings settingsDecoder
        }


settingsDecoder : Decoder GlobalSettings
settingsDecoder =
    field "global"
        (map4 GlobalSettings
            (field "log_level" string)
            (field "error_log" string)
            (field "access_log" string)
            (field "opentracing_tracer" string)
        )
