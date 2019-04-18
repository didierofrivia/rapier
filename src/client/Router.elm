module Router exposing (Route(..), fromUrl, parser)

import Url
import Url.Parser exposing ((</>), Parser, map, oneOf, s, top)


type Route
    = Dashboard
    | Settings
    | NotFound


parser : Parser (Route -> a) a
parser =
    oneOf
        [ map Dashboard top
        , map Settings (s "settings")
        ]


fromUrl : Url.Url -> Route
fromUrl url =
    Maybe.withDefault NotFound (Url.Parser.parse parser url)
