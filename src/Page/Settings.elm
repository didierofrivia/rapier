module Page.Settings exposing (Model, Msg(..), Status(..), getSettings, settingsDecoder, subscriptions, update, view)

import Browser
import Browser.Navigation as Nav
import Bulma.Elements as Elements exposing (TitleSize(..), content, title)
import Bulma.Modifiers exposing (Size(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode exposing (Decoder, field, int, string)
import Json.Decode.Pipeline exposing (required)
import Session exposing (..)



-- MODEL


type Status
    = Failure
    | Loading
    | Success Settings


type alias Model =
    { session : Session
    , status : Status
    }



-- UPDATE


type Msg
    = GetSettings
    | GotSettings (Result Http.Error Settings)


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
    content Standard
        []
        [ Elements.title H2 [] [ text "Settings" ]
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

        Success settings ->
            div []
                [ text ("Config Level: " ++ settings.global.logLevel)
                , text ("Error Log: " ++ settings.global.errorLog)
                , text ("Access Log: " ++ settings.global.accessLog)
                , text ("Open Tracing Tracer: " ++ settings.global.opentracingTracer)
                ]



-- HTTP


type alias Settings =
    { global : GlobalSettings
    }


type alias GlobalSettings =
    { logLevel : String
    , errorLog : String
    , accessLog : String
    , opentracingTracer : String
    , upstream : Upstream
    }


type alias Upstream =
    { loadBalancer : String
    , retry : String
    , retry_times : Int
    }


getSettings : Cmd Msg
getSettings =
    Http.get
        { url = "https://gist.githubusercontent.com/didierofrivia/de9701158b2cfddca938fd0d9c29bc91/raw/e8198ddd4e870b59a72f61eaf2b187fc0f219de5/apicast.json"
        , expect = Http.expectJson GotSettings settingsDecoder
        }


settingsDecoder : Decoder Settings
settingsDecoder =
    Decode.succeed Settings |> required "global" globalSettings


globalSettings : Decoder GlobalSettings
globalSettings =
    Decode.succeed
        GlobalSettings
        |> required "log_level" string
        |> required "error_log" string
        |> required "access_log" string
        |> required "opentracing_tracer" string
        |> required "upstream" upstreamDecoder


upstreamDecoder : Decoder Upstream
upstreamDecoder =
    Decode.succeed Upstream
        |> required "load_balancer" string
        |> required "retry" string
        |> required "retry_times" int
