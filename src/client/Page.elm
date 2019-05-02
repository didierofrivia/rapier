module Page exposing (view)

import Bulma.CDN exposing (..)
import Bulma.Components exposing (..)
import Bulma.Elements exposing (..)
import Bulma.Layout as Layout exposing (SectionSpacing(..), container)
import Bulma.Modifiers exposing (..)
import Bulma.Modifiers.Typography exposing (textCentered)
import Html exposing (..)
import Html.Attributes exposing (..)
import Router exposing (Route(..), Section(..))



-- VIEW
--view : Html msg -> Document msg


view page route =
    { title = "o-∫)––––––"
    , body =
        template
            page
            route
    }


headerNavbar : Route -> Html msg
headerNavbar route =
    let
        isLinkSelectedWithRoute =
            isLinkSelected route
    in
    navbar
        navbarModifiers
        []
        [ navbarBrand []
            (navbarBurger False
                []
                [ span [] []
                , span [] []
                , span [] []
                ]
            )
            [ navbarItemLink False
                [ href "/" ]
                [ text "o-∫)––––––" ]
            ]
        , navbarMenu False
            []
            [ navbarStart []
                [ navbarItemLink (isLinkSelectedWithRoute Dashboard) [ href "/" ] [ text "Dashboard" ]
                , navbarItemLink (isSettingsRoute route) [ href "/settings" ] [ text "Settings" ]
                ]
            ]
        ]


isSettingsRoute route =
    case route of
        Settings _ ->
            True

        _ ->
            False


isLinkSelected : Route -> Route -> Bool
isLinkSelected route linkRoute =
    route == linkRoute


navbarModifiers =
    { color = Dark
    , transparent = False
    }


footer : Html msg
footer =
    Layout.footer []
        [ container []
            [ content Small
                [ textCentered ]
                [ p []
                    [ a [ href "https://github.com/didierofrivia/rapier" ] [ text "o-∫)=rapier>" ]
                    , text " is an Open Source project, crafted with loads of <3 and c[_]"
                    ]
                ]
            ]
        ]


template : Html msg -> Route -> List (Html msg)
template content route =
    [ stylesheet
    , headerNavbar route
    , content
    , footer
    ]
