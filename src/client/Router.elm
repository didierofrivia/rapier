module Router exposing (Route(..), Section(..), fromUrl, parser)

import Url
import Url.Parser exposing ((</>), Parser, fragment, map, oneOf, s, top)


type Section
    = Init
    | Global
    | Routes
    | Internal
    | Server


type Route
    = Dashboard
    | Settings Section
    | NotFound


parser : Parser (Route -> a) a
parser =
    oneOf
        [ map Dashboard top
        , map Settings (s "settings" </> map sectionsParser (fragment identity))
        ]


sectionsParser : Maybe String -> Section
sectionsParser fragment =
    case fragment of
        Just "global" ->
            Global

        Just "routes" ->
            Routes

        Just "internal" ->
            Internal

        Just "server" ->
            Server

        Just _ ->
            Init

        Nothing ->
            Init


fromUrl : Url.Url -> Route
fromUrl url =
    Maybe.withDefault NotFound (Url.Parser.parse parser url)
