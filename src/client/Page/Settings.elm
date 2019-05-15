port module Page.Settings exposing (Model, Msg(..), Status(..), init, initialModel, subscriptions, update, view)

import Api
import Api.Endpoint as Endpoint exposing (Endpoint)
import Bulma.Columns exposing (..)
import Bulma.Components as Components exposing (..)
import Bulma.Elements exposing (content, notificationWithDelete)
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


type alias Config =
    { apiUrl : String, portNumber : String }


type alias Settings =
    { schema : Value
    , uiSchema : Value
    , config : Value
    }


type alias Notification =
    { text : String
    , color : Bulma.Modifiers.Color
    , visible : Bool
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
    , config : Config
    , notification : Notification
    }


initialModel config =
    { section = Init
    , status = Empty
    , settings = Nothing
    , config = config
    , notification = { visible = False, text = "", color = Bulma.Modifiers.Success }
    }


init : Section -> Model -> ( Model, Cmd Msg )
init section model =
    let
        newModel =
            { model | section = section }

        apiUrl =
            model.config.apiUrl ++ ":" ++ model.config.portNumber
    in
    if needsNewSettings model.status then
        ( newModel
        , Task.attempt GotSettings (getSettings apiUrl)
        )

    else
        ( newModel, cmdRenderFormWithSettings model.settings section )



-- UPDATE


type Msg
    = GetSettings
    | GotSettings (Result Http.Error Settings)
    | ConfigChanged Value
    | ConfigSubmitted Value
    | ConfigUpdated (Result Http.Error Value)
    | HideNotification


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetSettings ->
            if needsNewSettings model.status then
                requestSettings model

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
            let
                apiUrl =
                    model.config.apiUrl ++ ":" ++ model.config.portNumber

                putConfigWithBase =
                    putConfig apiUrl
            in
            ( updateConfig model config, Task.attempt ConfigUpdated (putConfigWithBase config) )

        ConfigUpdated result ->
            let
                notification =
                    model.notification

                newNotification color text =
                    { notification | color = color, text = text, visible = True }
            in
            case result of
                Ok _ ->
                    ( { model | notification = newNotification Bulma.Modifiers.Success "Yay! Changes saved" }, Cmd.none )

                Err error ->
                    let
                        failure =
                            "Uh Oh!: " ++ toString error
                    in
                    ( { model | notification = newNotification Bulma.Modifiers.Danger failure }, logThisShit (toString error) )

        HideNotification ->
            let
                newNotification notification =
                    { notification | visible = False }
            in
            ( { model | notification = newNotification model.notification }, Cmd.none )


needsNewSettings : Status -> Bool
needsNewSettings status =
    status == Failure || status == Empty


requestSettings : Model -> ( Model, Cmd Msg )
requestSettings model =
    let
        apiUrl =
            model.config.apiUrl ++ ":" ++ model.config.portNumber
    in
    ( { model | status = Loading }
    , Task.attempt GotSettings (getSettings apiUrl)
    )


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


getSettings : String -> Task Http.Error Settings
getSettings apiUrl =
    let
        settings schema uiSchema config =
            { schema = schema, uiSchema = uiSchema, config = config }

        getFrom endpointDecoder =
            let
                ( endpoint, decoder ) =
                    endpointDecoder
            in
            get (urlBuilder apiUrl endpoint) decoder
    in
    getFrom schemaEndpoint
        |> Task.andThen
            (\schema -> Task.succeed (settings schema))
        |> Task.andThen
            (\settingsWithSchema -> getFrom uiSchemaEndpoint |> Task.andThen (\uiSchema -> Task.succeed (settingsWithSchema uiSchema)))
        |> Task.andThen
            (\settingsWithSchemaAndUi -> getFrom configEndpoint |> Task.andThen (\config -> Task.succeed (settingsWithSchemaAndUi config)))


cmdRenderFormWithSettings : Maybe Settings -> Section -> Cmd Msg
cmdRenderFormWithSettings maybeSettings section =
    -- TODO: DRY this up
    case ( section, maybeSettings ) of
        ( Init, Just settings ) ->
            renderForm ( settings, "global" )

        ( Global, Just settings ) ->
            renderForm ( settings, "global" )

        ( Server, Just settings ) ->
            renderForm ( settings, "server" )

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
                            [ settingsNotification model.notification
                            , viewFormContainer
                            ]
                        ]
                    , viewSettings model
                    ]
                ]
            ]
        ]


settingsNotification : Notification -> Html Msg
settingsNotification notification =
    let
        cssClass =
            if notification.visible then
                ""

            else
                "hidden"
    in
    notificationWithDelete notification.color
        [ class cssClass ]
        HideNotification
        [ text notification.text
        ]


viewFormContainer : Html Msg
viewFormContainer =
    div [ id "SettingsForm" ] []


viewSettings : Model -> Html Msg
viewSettings model =
    case model.status of
        Success ->
            globalSettingsView

        Failure ->
            div []
                [ text "I could not load apicast settings for some reason. "
                , button [ onClick GetSettings ] [ text "Get Settings!" ]
                ]

        _ ->
            text "Loading..."


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
            , menuListItemLink (section == Server) [ href "settings#server" ] [ text "Server" ]
            , menuListItemLink (section == Internal) [ href "settings#internal" ] [ text "Internal Services" ]
            , menuListItemLink (section == Routes) [ href "settings#routes" ] [ text "Routes" ]
            ]
        ]



-- HTTP


urlBuilder : String -> Endpoint -> String
urlBuilder base path =
    Endpoint.urlBuilder base path


get : String -> Decoder a -> Task Http.Error a
get url decoder =
    Api.get url decoder


schemaEndpoint : ( Endpoint, Decoder Value )
schemaEndpoint =
    ( Endpoint.schema, Decode.value )


configEndpoint : ( Endpoint, Decoder Value )
configEndpoint =
    ( Endpoint.config, Decode.value )


uiSchemaEndpoint : ( Endpoint, Decoder Value )
uiSchemaEndpoint =
    ( Endpoint.uiSchema, Decode.value )


putConfig : String -> Value -> Task Http.Error Value
putConfig baseUrl config =
    let
        body =
            Http.jsonBody config

        url =
            urlBuilder baseUrl Endpoint.config
    in
    Api.put url body Decode.value
