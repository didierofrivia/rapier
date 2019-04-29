port module Page.Settings exposing (Model, Msg(..), Status(..), getSchema, init, initialModel, subscriptions, update, view)

import Api
import Api.Endpoint as Endpoint exposing (Endpoint)
import Bulma.Columns exposing (..)
import Bulma.Components as Components exposing (..)
import Bulma.Elements exposing (content)
import Bulma.Layout exposing (..)
import Bulma.Modifiers exposing (Color(..), Size(..), Width(..))
import Debug exposing (toString)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode exposing (Decoder, Value)
import Router exposing (Section(..))
import Task exposing (Task)



-- MODEL


type alias Settings =
    { schema : Value
    , uiSchema : Value
    , config : Value
    }


type Status
    = Failure
    | Loading
    | Success
    | Empty


type alias Model =
    { status : Status
    , settings : Maybe Settings
    , section : Section
    }


initialModel =
    { section = Init, status = Empty, settings = Nothing }


init : Section -> Model -> ( Model, Cmd Msg )
init section model =
    case ( section, model.status ) of
        ( Init, Empty ) ->
            ( model
            , Task.attempt GotSettings getSettings
            )

        _ ->
            ( { model | section = section }, cmdRenderFormWithSettings model.settings section )



-- UPDATE


type Msg
    = GetSettings
    | GotSettings (Result Http.Error Settings)
    | ConfigChanged Value
    | ConfigSubmitted Value
    | ConfigUpdated (Result Http.Error Value)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetSettings ->
            let
                requestSettings =
                    ( { model | status = Loading }
                    , Task.attempt GotSettings getSettings
                    )
            in
            if model.status == Failure || model.status == Empty then
                requestSettings

            else
                ( model, Cmd.none )

        GotSettings result ->
            case result of
                Ok settings ->
                    ( { model | status = Success, settings = Just settings }, cmdRenderFormWithSettings (Just settings) model.section )

                Err error ->
                    ( { model | status = Failure }, logThisShit (toString error) )

        ConfigChanged config ->
            let
                newModel =
                    updateConfig model config
            in
            ( newModel, cmdRenderFormWithSettings newModel.settings newModel.section )

        ConfigSubmitted config ->
            ( updateConfig model config, Task.attempt ConfigUpdated (putConfig config) )

        ConfigUpdated result ->
            case result of
                Ok response ->
                    ( model, logThisShit (toString response) )

                Err error ->
                    ( model, logThisShit (toString error) )


updateConfig : Model -> Value -> Model
updateConfig model config =
    case model.settings of
        Just settings ->
            let
                newSettings newConfig =
                    { settings | config = newConfig }
            in
            { model | settings = Just (newSettings config) }

        Nothing ->
            model


getSettings : Task Http.Error Settings
getSettings =
    let
        settings schema uiSchema config =
            { schema = schema, uiSchema = uiSchema, config = config }
    in
    getSchema
        |> Task.andThen
            (\schema -> Task.succeed (settings schema))
        |> Task.andThen
            (\settingsWithSchema -> getUiSchema |> Task.andThen (\uiSchema -> Task.succeed (settingsWithSchema uiSchema)))
        |> Task.andThen
            (\settingsWithSchemaAndUi -> getConfig |> Task.andThen (\config -> Task.succeed (settingsWithSchemaAndUi config)))


cmdRenderFormWithSettings : Maybe Settings -> Section -> Cmd Msg
cmdRenderFormWithSettings maybeSettings section =
    case ( section, maybeSettings ) of
        ( Init, Just settings ) ->
            renderForm ( settings, "global" )

        ( Global, Just settings ) ->
            renderForm ( settings, "global" )

        ( Internal, Just settings ) ->
            renderForm ( settings, "internal" )

        ( Routes, Just settings ) ->
            renderForm ( settings, "routes" )

        ( _, _ ) ->
            Cmd.none



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch [ changeConfig ConfigChanged, submitConfig ConfigSubmitted ]



-- PORTS


port renderForm : ( Settings, String ) -> Cmd msg


port changeConfig : (Value -> msg) -> Sub msg


port submitConfig : (Value -> msg) -> Sub msg


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
                    [ columns columnsModifiers
                        []
                        [ column settingsMenuColumnModifier
                            []
                            [ settingsMenu model.section ]
                        , column columnModifiers
                            []
                            [ viewFormContainer
                            ]
                        ]
                    , viewSettings model
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
        Loading ->
            text "Loading..."

        Success ->
            globalSettingsView

        _ ->
            div []
                [ text "I could not load apicast settings for some reason. "
                , button [ onClick GetSettings ] [ text "Get Settings!" ]
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


globalSettingsView : Html msg
globalSettingsView =
    div [ style "margin-top" "0.5em" ] [ div [] [] ]


settingsMenu : Section -> Html msg
settingsMenu section =
    Components.menu []
        [ menuList []
            [ menuListItemLink (section == Global || section == Init) [ href "settings#global" ] [ text "Global" ]
            , menuListItemLink (section == Internal) [ href "settings#internal" ] [ text "Internal" ]
            , menuListItemLink (section == Routes) [ href "settings#routes" ] [ text "Routes" ]
            ]
        ]



-- HTTP


getSchema : Task Http.Error Value
getSchema =
    Api.get Endpoint.schema Decode.value


getConfig : Task Http.Error Value
getConfig =
    Api.get Endpoint.config Decode.value


getUiSchema : Task Http.Error Value
getUiSchema =
    Api.get Endpoint.uiSchema Decode.value


putConfig : Value -> Task Http.Error Value
putConfig config =
    let
        body =
            Http.jsonBody config
    in
    Api.put Endpoint.config body Decode.value
