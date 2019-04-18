port module Page.Settings exposing (Model, Msg(..), Status(..), getSettings, subscriptions, update, view)

import Browser
import Browser.Navigation as Nav
import Bulma.Columns exposing (..)
import Bulma.Components as Components exposing (..)
import Bulma.Elements as Elements exposing (content, title)
import Bulma.Form as Form exposing (controlInput, controlInputModifiers, controlModifiers, controlText, field, help, label)
import Bulma.Layout as Layout exposing (..)
import Bulma.Modifiers exposing (Color(..), Size(..), Width(..))
import Debug exposing (log, toString)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode exposing (Decoder, Value, decodeValue, field, int, string)
import Json.Encode as E
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
                    ( { model | status = Success payload }, renderForm payload.configuration )

                Err error ->
                    ( { model | status = Failure }, logThisShit (toString error) )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- PORTS


port renderForm : E.Value -> Cmd msg


port logThisShit : String -> Cmd msg



-- VIEW


view : Model -> Html Msg
view model =
    content Large
        []
        [ container []
            [ columns columnsModifiers
                []
                [ column columnModifiers
                    []
                    [ viewSettings model
                    , viewFormContainer
                    ]
                ]
            ]
        ]


viewFormContainer : Html Msg
viewFormContainer =
    div [ id "SettingsForm" ] []


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
            globalSettingsView settings.configuration


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


globalSettingsView : Value -> Html msg
globalSettingsView settings =
    div [ style "margin-top" "0.5em" ] [ div [] [ text (toString settings) ] ]


myControlInputModifiers =
    { controlInputModifiers
        | disabled = True
    }



-- HTTP


type alias Settings =
    { configuration : Value
    }


getSettings : Cmd Msg
getSettings =
    Http.get
        { -- url = "https://gist.githubusercontent.com/didierofrivia/de9701158b2cfddca938fd0d9c29bc91/raw/e8198ddd4e870b59a72f61eaf2b187fc0f219de5/apicast.json"
          url = "https://raw.githubusercontent.com/3scale/APIcast/master/gateway/src/apicast/policy/headers/apicast-policy.json"
        , expect = Http.expectJson GotSettings configurationDecoder
        }


configurationDecoder =
    Decode.map Settings (field "configuration" Decode.value)
