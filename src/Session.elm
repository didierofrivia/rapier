module Session exposing (Session)

import Browser.Navigation as Nav
import Router exposing (Route(..))


type alias Session =
    { key : Nav.Key
    , route : Route
    }
