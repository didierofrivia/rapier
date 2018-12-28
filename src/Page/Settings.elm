module Page.Settings exposing (Model, Msg(..), Status(..), getSettings, settingsDecoder, subscriptions, update, view)

import Browser
import Browser.Navigation as Nav
import Bulma.Columns exposing (..)
import Bulma.Components as Components exposing (..)
import Bulma.Elements as Elements exposing (content, title)
import Bulma.Form as Form exposing (controlInput, controlInputModifiers, controlModifiers, controlText, field, help, label)
import Bulma.Layout as Layout exposing (..)
import Bulma.Modifiers exposing (Color(..), Size(..), Width(..))
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
    { status : Status
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
    content Large
        []
        [ container [] [ viewSettings model ] ]


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
            columns columnsModifiers
                []
                [ column settingsMenuColumnModifier
                    []
                    [ settingsMenu ]
                , column columnModifiers
                    []
                    [ globalSettingsView settings.global
                    ]
                ]


settingsMenuColumnModifier =
    { columnModifiers
        | widths =
            { mobile = Just Auto
            , tablet = Just Width3
            , desktop = Just Width3
            , widescreen = Just Width3
            , fullHD = Just Width3
            }
    }


settingsMenu : Html msg
settingsMenu =
    Components.menu []
        [ menuList []
            [ menuListItemLink True [] [ text "Global" ]
            , menuListItemLink False [] [ text "Servers" ]
            , menuListItemLink False [] [ text "Routes" ]
            ]
        ]


globalSettingsView : GlobalSettings -> Html msg
globalSettingsView settings =
    Html.form [ style "margin-top" "0.5em" ]
        [ div
            []
            [ h4 [] [ text "Global" ]
            , Form.field []
                [ Form.label [] [ text "Config Level" ]
                , controlText myControlInputModifiers [] [ value settings.logLevel ] []
                , Form.controlHelp Default [] []
                ]
            , Form.field []
                [ Form.label [] [ text "Error Log" ]
                , controlText myControlInputModifiers [] [ value settings.errorLog ] []
                , Form.controlHelp Default [] []
                ]
            , Form.field []
                [ Form.label [] [ text "Access Log" ]
                , controlText myControlInputModifiers [] [ value settings.accessLog ] []
                , Form.controlHelp Default [] []
                ]
            , Form.field []
                [ Form.label [] [ text "Open Tracing Tracer" ]
                , controlText myControlInputModifiers [] [ value settings.opentracingTracer ] []
                , Form.controlHelp Default [] []
                ]
            ]
        , div []
            [ h5 [] [ text "Upstream" ]
            , Form.field []
                [ Form.label [] [ text "Load Balancer" ]
                , controlText myControlInputModifiers [] [ value settings.upstream.loadBalancer ] []
                , Form.controlHelp Default [] []
                ]
            , Form.field []
                [ Form.label [] [ text "Retry" ]
                , controlText myControlInputModifiers [] [ value settings.upstream.retry ] []
                , Form.controlHelp Default [] []
                ]
            , Form.field []
                [ Form.label [] [ text "Retry Times" ]
                , controlText myControlInputModifiers [] [ value (String.fromInt settings.upstream.retryTimes) ] []
                , Form.controlHelp Default [] []
                ]
            ]
        ]


myControlInputModifiers =
    { controlInputModifiers
        | disabled = True
    }



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
    , retryTimes : Int
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
